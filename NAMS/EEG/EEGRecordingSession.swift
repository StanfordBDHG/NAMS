//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import EDFFormat
import Foundation


@Observable
class EEGRecordingSession {
    private var fileWriter: BDFFileWriter? // TODO: should this be allowed to optional?
    private(set) var measurements: [EEGFrequency: [EEGSeries]] = [:]

    private var recordingInformation: RecordingInformation {
        RecordingInformation(
            startDate: .now,
            code: "asdf",
            investigatorCode: "IN",
            equipmentCode: "MUSE/BIOPOT" // TODO: how to derive data here
        )
    }

    private var signals: [Signal] {
        [
            // TODO: properly parse signals!
            Signal(
                label: .eeg(location: .af3, prefix: .micro),
                transducerType: "EEG Electrode Sensor 1", // TODO: nums for biopot
                prefiltering: "", // TODO: get from device, HP; LP and Notch??
                sampleCount: 2,
                // TODO: these are the values for biopot signals!
                physicalMinimum: -20_000,
                physicalMaximum: 20_0000,
                digitalMinimum: -8_388_608,
                digitalMaximum: 8_388_607
            )
        ]
    }

    init(url: URL, patient: Patient, device: ConnectedDevice) {
        let patientInformation = PatientInformation(from: patient)

        let fileInformation = FileInformation(
            subject: .structured(patientInformation),
            recording: .structured(recordingInformation),
            recordDuration: 30 // TODO: what is the record duration in seconds?
        )

        // TODO: file information, and describe signals!
        // TODO: catch error!
        // TODO: always continuous recording right? (only if we want to support BDF+?) => then we need bdf+/edf+ annotations
        self.fileWriter = try? BDFFileWriter(url: url, format: .continuousRecording, information: fileInformation, signals: signals)
        self.measurements = [:]
    }


    func append(series: EEGSeries, for frequency: EEGFrequency) {
        // TODO: downsample frequency?
        measurements[frequency, default: []]
            .append(series)
        if frequency == .all {
            // TODO: add record, if file-writer is present!
        }
    }

    func append(series: [EEGSeries], for frequency: EEGFrequency) {
        measurements[frequency, default: []]
            .append(contentsOf: series)
    }
}
