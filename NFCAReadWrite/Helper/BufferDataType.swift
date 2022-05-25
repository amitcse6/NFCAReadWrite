//
//  BufferDataType.swift
//  NFCAReadWrite
//
//  Created by AMIT on 5/25/22.
//

import Foundation

enum BufferDataType : Int {
    case long_8 = 1
    case long_16 = 2
    case long_24 = 3
    case long_32 = 4
    case long_64 = 8
    case variable_length = -1
}

