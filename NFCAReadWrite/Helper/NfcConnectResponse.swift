//
//  NfcConnectResponse.swift
//  NFCAReadWrite
//
//  Created by AMIT on 5/25/22.
//

import Foundation

enum NfcResponseType {
    static var CONNECT = UInt64(0x0000)
    static var INITIALIZE = 0x0001
    static var ACKNOWLEDGEMENT = 0x0002
    static var COMMAND = 0x000C
    static var READ_SENSOR_DATA = 0x0011
}


open class NfcResponse{
    public var messageCntr: UInt8 = 0
    public var type: UInt64 = 0
    init(messageCntr: UInt8 ,type: UInt64){
        self.messageCntr = messageCntr
        self.type = type
    }
    
}

public class NfcConnectResponse: NfcResponse {
    var value: Int = 0
    
    init(_ messageCntr: UInt8, _ bytes: NfcDataBuffer){
        super.init(messageCntr: messageCntr, type: NfcResponseType.CONNECT)
        value = Int(bytes.getNext(numberOfBytes: BufferDataType.long_24.rawValue))
    }
}
