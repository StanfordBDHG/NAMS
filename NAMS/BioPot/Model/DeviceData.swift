//
//  DeviceData.swift
//  NAMS
//
//  Created by Mihir Joshi on 11/25/23.
//

import NIOCore

//TODO: Write parsing code based on data stream characteristic


/// Define object that contains the number of channels
struct DeviceData {
    let S1 : ByteBuffer
    let S2 : ByteBuffer
//    let S3 : [samples]
//    let S4 : [samples]
//    let S5 : [samples]
//    let S6 : [samples]
//    let S7 : [samples]
//    let S8 : [samples]
//    let S9 : [samples]
}

extension DeviceData: ByteCodable {
    
    
    init?(from byteBuffer: inout NIOCore.ByteBuffer) {
        guard byteBuffer.readableBytes >= 232 else {
            return nil
        }
        
        // S1: 4-27, S2: 28-51
        guard let S1 = readElectrode(from: &byteBuffer, electrodeNumber: 1),
              let S2 = readElectrode(from: &byteBuffer, electrodeNumber: 2) else {
            return nil
        }
        
        self.S1 = S1
        self.S2 = S2
    }
    
    
    func readElectrode(from byteBuffer: inout ByteBuffer, electrodeNumber: Int) -> ByteBuffer? {
        
        // TODO: check if data exists and then save
        
        let startByte = 4 /// starting byte for Characteristic 4
        let stepSize = 24 /// difference between starting indices of each channel
        let startIndex = startByte + stepSize*(electrodeNumber - 1)
        //        let endIndex = startIndex + (stepSize - 1)
        
        // Start byteBuffer at start index
        byteBuffer.moveReaderIndex(to: startIndex)
        
        var electrodeData:[[UInt8?]] = []
        var currIndex = startIndex
        
        // Iterate through each channel and store (should be 12 channels per electrode sample)
        for _ in 1...stepSize/2 {
            // Read first byte
            let firstByte = byteBuffer.readInteger(as: UInt8.self)
            
            // Update currIndex
            currIndex += 1
            
            // Move to next byte
            byteBuffer.moveReaderIndex(to: currIndex)
            
            // Read second byte
            let secondByte = byteBuffer.readInteger(as: UInt8.self)
            
            // Store in electrodeData
            let tempArr:[UInt8?] = [firstByte, secondByte]
            electrodeData.append(tempArr)
            
            // Update currIndex and move to this byte
            currIndex += 1
            byteBuffer.moveReaderIndex(to: currIndex)
        }
        
        // Return byteBuffer for specified electrode
        return self.convertToByteBuffer(electrodeData: electrodeData)
        
    }
    
    
    func convertToByteBuffer(electrodeData: [[UInt8?]]) -> ByteBuffer? {
        var byteBuffer = ByteBufferAllocator().buffer(capacity: electrodeData.count * 2) // Assuming 2 bytes per UInt8
        
        for array in electrodeData {
            for element in array {
                // Append non-nil values to the byte buffer
                if let value = element {
                    byteBuffer.writeInteger(value, as: UInt8.self)
                } else {
                    // Handle nil values as needed
                }
            }
        }
        
        return byteBuffer
    }
    
    func encode(to byteBuffer: inout NIOCore.ByteBuffer) {
        byteBuffer.writeInteger(S1 as UInt8.self)
//        byteBuffer.writeInteger(S2 as FixedWidthInteger)
    }
}
