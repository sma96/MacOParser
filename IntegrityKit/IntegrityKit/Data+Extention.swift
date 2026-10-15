//
//  Utils.swift
//  IntegrityKit
//
//  Created by 미니 on 10/15/26.
//

import Foundation

extension Data {
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
