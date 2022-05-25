//
//  NfcResponseFactory.swift
//  NFCAReadWrite
//
//  Created by AMIT on 5/25/22.
//

import Foundation

public class NfcResponseFactory {
    
    func getNfcResponse(_ bytes:[UInt8]) -> NfcConnectResponse {
        let buffer = NfcDataBuffer(bytes: bytes)
        
        let messageCntr = buffer.getNextByte()
        let responseType = buffer.getNext(dataType: BufferDataType.variable_length)
        
        switch responseType {
        case NfcResponseType.CONNECT:
            return NfcConnectResponse(messageCntr, buffer)
            
        default:
            break
        }
        return NfcConnectResponse(messageCntr, buffer)
    }
    
}
