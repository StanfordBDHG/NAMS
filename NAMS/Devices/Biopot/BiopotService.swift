//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport)
import ByteCoding
import EDFFormat
import OrderedCollections
import OSLog
@_spi(TestingSupport)
import SpeziBluetooth


/// The primary Biopot service
///
/// - Note: Notation within the docs: Access properties: R: read, W: write, N: notify.
///     Naming is currently guess work.
class BiopotService: BluetoothService {
    /// The maximum amount of packets we cached when waiting for a dropped packet to be resent.
    private static let packetBufferMax = 3

    static let id: BTUUID = "FFF0"

    private let logger = Logger(subsystem: "edu.stanford.nams", category: "BiopotService")

    /// Characteristic 6, as per the manual. RN.
    @Characteristic(id: "FFF6", notify: true)
    var deviceInfo: DeviceInformation?

    /// Characteristic 1, as per the manual. RW.
    /// Note: Even though Bluetooth reports this as notify it isn't!!
    @Characteristic(id: "FFF1")
    var deviceConfiguration: DeviceConfiguration?
    /// Characteristic 5, as per the manual. RW.
    @Characteristic(id: "FFF5")
    var samplingConfiguration: SamplingConfiguration?
    /// Characteristic 2, as per the manual. RW.
    @Characteristic(id: "FFF2")
    var dataControl: DataControl?
    /// Characteristic 3, as per the manual. RW.
    @Characteristic(id: "FFF3")
    var impedanceMeasurement: ImpedanceMeasurement?

    /// Characteristic 4, as per the manual. RN.
    @Characteristic(id: "FFF4", notify: true)
    var dataAcquisition: Data? // either `DataAcquisition10` or `DataAcquisition11` depending on the configuration.


    @EEGProcessing private var recordingStream: AsyncStream<CombinedEEGSample>.Continuation? {
        willSet {
            recordingStream?.finish()
        }
    }

    @EEGProcessing private var nextExpectedSampleCount: UInt32 = 0

    /// Buffer of acquisition packets.
    ///
    /// When packets are dropped they might be received in a different order. In these cases, we detect that the received packet
    /// is not the expected one and buffer them for a certain period till we receive the retransmission.
    /// The buffer is limited to `packetBufferMax`.
    @EEGProcessing private var packetBuffer: OrderedSet<SomeDataAcquisition> = []

    init() {}

    func customConfigure() { // TODO: replace by SpeziBluetooth infrastructure!
        $dataAcquisition.onChange { [weak self] value in
            self?.handleDataAcquisition(data: value)
        }
    }

    @EEGProcessing
    private func prepareRecording() async throws {
        do {
            // make sure the value is up to date before the recording session is created
            try await $deviceConfiguration.read()
            try await $samplingConfiguration.read()

            if let deviceConfiguration = deviceConfiguration {
                logger.debug("Device configuration: \(String(describing: deviceConfiguration))")
            }
            if let samplingConfiguration = samplingConfiguration {
                logger.debug("Sampling configuration: \(String(describing: samplingConfiguration))")
            }
        } catch {
            logger.error("Failed to prepare recording for Biopot: \(error)")
            throw error
        }
    }

    @EEGProcessing
    func startRecording() async throws -> AsyncStream<CombinedEEGSample> {
        try await self.prepareRecording()
        try await self.enableRecording()
        return _makeStream()
    }

    @EEGProcessing
    func _makeStream() -> AsyncStream<CombinedEEGSample> { // swiftlint:disable:this identifier_name
        AsyncStream { continuation in
            continuation.onTermination = { [weak self] termination in
                guard case .cancelled = termination else {
                    return // we don't care about finished sequences!
                }

                Task { @EEGProcessing [weak self] in
                    do {
                        try await self?.stopRecording()
                    } catch {
                        self?.logger.error("Failed to stop recording for device: \(error)")
                    }
                }
            }
            recordingStream = continuation
        }
    }

    @EEGProcessing
    private func stopRecording() async throws {
        defer {
            recordingStream?.finish() // might already be cancelled, but just to be safe
            recordingStream = nil

            clearProcessing()
        }

        try await $dataControl.write(.paused)
    }

    @EEGProcessing
    private func enableRecording() async throws {
        // we assume prepareRecording is called first to have the latest sampling configuration
        do {
            try await $dataControl.write(.paused)

            clearProcessing()
            try await $dataControl.write(.started)
        } catch {
            logger.error("Failed to enable Biopot recording: \(error)")
            throw error
        }
    }

    @EEGProcessing
    private func clearProcessing() {
        nextExpectedSampleCount = 0
        packetBuffer.removeAll()
    }

    @EEGProcessing
    func updateSamplingConfiguration<Value>(set keyPath: WritableKeyPath<SamplingConfiguration, Value>, to value: Value) async throws {
        var configuration: SamplingConfiguration
        if let samplingConfiguration {
            configuration = samplingConfiguration
        } else {
            do {
                configuration = try await $samplingConfiguration.read()
            } catch {
                logger.error("Failed to retrieve current sampling configuration: \(error)")
                return
            }
        }

        configuration[keyPath: keyPath] = value
        do {
            try await $samplingConfiguration.write(configuration)

            logger.debug("Successfully updated sampling configuration key \(keyPath.debugDescription) to \(String(describing: value)).")
        } catch {
            logger.error("Failed to update \(keyPath.debugDescription) of sampling configuration: \(error)")
        }
    }


    func handleDataAcquisition(data: Data) {
        guard let deviceConfiguration = deviceConfiguration,
              samplingConfiguration != nil else {
            logger.debug("Received data acquisition without having device configurations ready!")
            return
        }

        guard deviceConfiguration.dataSize == 24
                && deviceConfiguration.channelCount == 8 else {
            logger.error("Unable to process data acquisition. Unexpected configuration: \(String(describing: deviceConfiguration))")
            return
        }

        // move of the bluetooth queue as fast as possible!
        Task { @EEGProcessing in
            await self.processIncomingData(data)
        }
    }

    @EEGProcessing
    private func processIncomingData(_ data: Data) async {
        guard let deviceConfiguration else {
            return // we checked that earlier, if it is gone now, something went completely wrong
        }

        let acquisition: SomeDataAcquisition?
        if case .off = deviceConfiguration.accelerometerStatus {
            acquisition = DataAcquisition10(data: data).map { .type10($0) }
        } else {
            acquisition = DataAcquisition11(data: data).map { .type11($0) }
        }

        guard let acquisition else {
            logger.error("Failed to decode data acquisition: \(data.hexString())")
            return
        }

        guard recordingStream != nil else {
            logger.warning("Received incoming data acquisition \(acquisition.totalSampleCount) while recording session was not present anymore!")
            return
        }


        guard acquisition.totalSampleCount >= nextExpectedSampleCount else {
            logger.warning("Received stale data acquisition with total count \(acquisition.totalSampleCount) but we already expected packet \(self.nextExpectedSampleCount)")
            return
        }


        // See explanation below, this eventually clears the first received packet from the buffer
        if nextExpectedSampleCount == 0 && acquisition.totalSampleCount > 0 && packetBuffer.first?.totalSampleCount == 0 {
            processBufferedPackets()
        }


        // The initial packet (with `totalSampleCount` equals to zero) might be transmitted multiple times.
        // Therefore, we just care for the last one. Always adding the first packet to the packetBuffer will make sure it
        // replaces any previous packets with the same totalSampleCount.
        // Secondly, packets might be lost in transmission and therefore retransmitted at a later point in time.
        // Therefore, we check for the next expected sample count and buffer any packets that don't match this counter.
        // We wait for the dropped packet to be transmitted next.
        if acquisition.totalSampleCount == 0 || acquisition.totalSampleCount != nextExpectedSampleCount {
            packetBuffer.updateOrAppend(acquisition)
            packetBuffer.sort()

            if packetBuffer.count > Self.packetBufferMax {
                guard let first = packetBuffer.first else {
                    return // doesn't make sense
                }

                let previouslyExpectedCount = nextExpectedSampleCount

                // just skip to the first packet we have buffered
                nextExpectedSampleCount = first.totalSampleCount

                logger.warning("Didn't receive expected packet \(previouslyExpectedCount), skipping to \(self.nextExpectedSampleCount).")

                // Process all buffered packets, starting from the first, that are received in order.
                processBufferedPackets()
            }
            return
        }


        // Otherwise, we have the expected next packet count.

        // 1) Process packet and increment count.
        processAcquisition(acquisition)
        nextExpectedSampleCount += UInt32(deviceConfiguration.samplesPerChannel)

        // 2) Check if the next expected packet is already in the buffer
        processBufferedPackets()
    }

    @EEGProcessing
    private func processBufferedPackets() {
        guard let deviceConfiguration else {
            return
        }

        while let first = packetBuffer.first,
              first.totalSampleCount == nextExpectedSampleCount {
            packetBuffer.removeFirst() // this maintains sorted order

            processAcquisition(first)
            nextExpectedSampleCount = first.totalSampleCount + UInt32(deviceConfiguration.samplesPerChannel)
        }
    }

    @EEGProcessing
    private func processAcquisition(_ acquisition: SomeDataAcquisition) {
        guard let recordingStream else {
            return // we checked that earlier, if it is gone now, something went completely wrong
        }


        for sample in acquisition.samples {
            let combinedSample = CombinedEEGSample(channels: sample.channels)
            recordingStream.yield(combinedSample)
        }
    }
}
