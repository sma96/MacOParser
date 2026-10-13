//
//  CodeSign.swift
//  IntegrityKit
//
//  Created by 미니 on 10/13/26.
//

import Foundation
import MachO

struct CodeSignature {
    private let data: Data
    private let offset: Int
    
    init(data: Data, offset: Int) {
        self.data = data
        self.offset = offset
    }
}

extension CodeSignature {
    var linkEditData: linkedit_data_command {
        data.withUnsafeBytes {
            $0.load(fromByteOffset: offset, as: linkedit_data_command.self)
        }
    }
    
    var superBlob: CS_SuperBlob {
        data.withUnsafeBytes {
            $0.load(fromByteOffset: Int(linkEditData.dataoff), as: CS_SuperBlob.self)
        }
    }
    
    var blobIndices: [CS_BlobIndex] {
        data.withUnsafeBytes {
            let startBlobIndex = Int(linkEditData.dataoff) + MemoryLayout<CS_SuperBlob>.size
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
    
    var codeDirectories: [CodeDirectory] {
        let baseOffset = Int(linkEditData.dataoff)
        
        return blobIndices.compactMap {
            let offSet = Int(UInt32(bigEndian: $0.offset))
            
            return data.withUnsafeBytes {
                let genericBlob = $0.load(fromByteOffset: baseOffset + offSet, as: CS_GenericBlob.self)
                let magic = UInt32(bigEndian: genericBlob.magic)
                
                if magic == CSMAGIC_CODEDIRECTORY {
                    let cd = $0.load(fromByteOffset: Int(linkEditData.dataoff) + offSet, as: CS_CodeDirectory.self)
                    
                    return CodeDirectory(cd: cd, data: data, offset: Int(linkEditData.dataoff) + offSet)
                } else {
                    return nil
                }
            }
        }
    }
    
    var sha256CD: CodeDirectory? {
        codeDirectories.first {
            $0.getHashType() == CS_HASHTYPE_SHA256
        }
    }
}
