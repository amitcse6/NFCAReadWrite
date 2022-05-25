//
//  NfcDataBuffer.swift
//  NFCAReadWrite
//
//  Created by AMIT on 5/25/22.
//

import Foundation

class NfcDataBuffer {
    
    private var offset = 0
    var bytes : [UInt8] = []
    var size : Int = 0
    
    
    init(bytes: [UInt8]) {
        self.bytes = bytes
        self.size = bytes.count
    }
    
    
    func hasNext() -> Bool {
        return offset < bytes.count
    }
    
    func getNextChar() -> Character {
        return Character(UnicodeScalar(getNextByte()))
    }
    
    func getNextByte() -> UInt8 {
        let byte = bytes[self.offset]
        self.offset += 1
        return byte
    }
    
    func peekNextByte() -> UInt8 {
        return bytes[offset]
    }
    
    func getNext(dataType: BufferDataType) -> UInt64 {
        if dataType == .variable_length {
            return parseNextVariableLength()
        }
        else {
            return UInt64(getNext(numberOfBytes: dataType.rawValue))
        }
    }
    
    func getNext(numberOfBytes: Int) -> UInt64 {
        var result : UInt64 = 0
        
        for _ in 0..<numberOfBytes {
            result = result << 8
            result = result | ( UInt64(bytes[offset]) & 0xff )
            offset += 1
        }
        return result
    }
    
    func slice(numberOfbytes: Int) -> NfcDataBuffer {
        _ = NfcDataBuffer(bytes: self.bytes)
        return NfcDataBuffer(bytes: [])
    }
    
    private func parseNextVariableLength() -> UInt64 {
        var b : Int = 0
        var valOffset : UInt64 = 0
        var ivalue : UInt64 = 0
        
        repeat {
            ivalue = ivalue << 7
            ivalue += valOffset
            b = Int(bytes[offset]) & 0xff
            ivalue = ivalue | UInt64(b & 0x7f)
            valOffset = 128
            offset += 1
        } while((b & 0x80) != 0 )
        return ivalue
    }
}
