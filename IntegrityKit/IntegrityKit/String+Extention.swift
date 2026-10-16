//
//  String+Extention.swift
//  IntegrityKit
//
//  Created by 미니 on 10/17/26.
//

import Foundation


extension String {
    public typealias CCharTuple16 = (CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar)
    
    public init(tuple: CCharTuple16) {
        self = withUnsafePointer(to: tuple) {
            let size = MemoryLayout<CCharTuple16>.size
            let data = Data(bytes: $0, count: size) + [0]
            return String(data: data, encoding: .utf8) ?? ""
        }
    }
}
