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
    
    var superBlob: CodeSignSuperBlob {
        let superBlob = data.withUnsafeBytes { $0.load(fromByteOffset: Int(linkEditData.dataoff), as: CS_SuperBlob.self) }
        
        return CodeSignSuperBlob(superBlob: superBlob, data: data, offset: Int(linkEditData.dataoff))
    }
    
    var codeDirectories: [CodeDirectory] {
        let baseOffset = Int(linkEditData.dataoff)
        
        return superBlob.blobIndices.compactMap {
            let offSet = Int($0.offset.byteSwapped)
            
            return data.withUnsafeBytes {
                let genericBlob = $0.load(fromByteOffset: baseOffset + offSet, as: CS_GenericBlob.self)
                let magic = genericBlob.magic.byteSwapped
                
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
    
    var pageHash: [Data]? {
        sha256CD?.pageHash
    }
    
    var teamId: String? {
        sha256CD?.teamId
    }
}
