//
//  SuperBlob.swift
//  IntegrityKit
//
//  Created by 미니 on 10/14/26.
//

import Foundation

struct SuperBlob {
    private let superBlob: CS_SuperBlob
    private let data: Data
    private let offset: Int
    
    init(superBlob: CS_SuperBlob, data: Data, offset: Int) {
        self.superBlob = superBlob
        self.data = data
        self.offset = offset
    }
}

extension SuperBlob {
    var blobIndices: [CS_BlobIndex] {
        data.withUnsafeBytes {
            let startBlobIndex = Int(offset) + MemoryLayout<CS_SuperBlob>.size
            let blobSize = MemoryLayout<CS_BlobIndex>.size
            let blobCount = UInt32(bigEndian: superBlob.count)
            var result = [CS_BlobIndex]()

            for i in 0..<blobCount {
                let blob = $0.load(fromByteOffset: startBlobIndex + Int(i) * blobSize, as: CS_BlobIndex.self)
                
                result.append(blob)
            }
            return result
        }
    }
}
