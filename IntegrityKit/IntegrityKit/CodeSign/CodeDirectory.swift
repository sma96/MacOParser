//
//  CodeDirectory.swift
//  IntegrityKit
//
//  Created by 미니 on 10/14/26.
//

import Foundation
import CryptoKit
import MachO

struct CodeDirectory {
    private let cd: CS_CodeDirectory
    private var data: Data
    private var offset: Int
    
    init(cd: CS_CodeDirectory, data: Data, offset: Int) {
        self.cd = cd
        self.data = data
        self.offset = offset
    }
}

extension CodeDirectory {
    private var codeSlotCount: Int { Int(cd.nCodeSlots.byteSwapped) }
    private var specialSlotCount: Int { Int(cd.nSpecialSlots.byteSwapped) }
    private var hashSize: Int { Int(cd.hashSize.byteSwapped) }
    private var hashOffset: Int { Int(cd.hashOffset.byteSwapped) }
    private var hashType: Int { Int(cd.hashType.byteSwapped) }
    private var codeLimit: Int { Int(cd.codeLimit.byteSwapped) }
    private var pageSize: Int { Int(cd.pageSize.byteSwapped) }
    private var teamOffset: Int { Int(cd.teamOffset.byteSwapped) }
    
    var codeSlotsHash: [Data] {
        return (0..<codeSlotCount).compactMap { hash(forSlot: $0) }
    }
    
    var specialSlotsHash: [Data] {
        (-specialSlotCount..<0).compactMap { hash(forSlot: $0) }
    }
    
    var infoHash: Data? {
        hash(for: .INFOSLOT)
    }

    var resourceHash: Data? {
        hash(for: .RESOURCEDIR)
    }
    
    var pageHash: [Data] {
        let pageBytes = 1 << pageSize

        return stride(from: 0, to: codeLimit, by: pageBytes).map { start in
            let end = min(start + pageBytes, codeLimit)
            let page = data.subdata(in: start..<end)
            
            return Data(SHA256.hash(data: page))
        }
     }
    
    var teamId: String? {
        data.withUnsafeBytes {
            guard teamOffset > 0 else {
                return nil
            }
            
            let offset = offset + teamOffset
            
            guard let ptr = $0.baseAddress?
                .advanced(by: offset)
                .assumingMemoryBound(to: CChar.self)
            else {
                return nil
            }
            
            return String(cString: ptr)
        }
    }
    
    public func getHashType() -> Int {
        return hashType
    }
}

extension CodeDirectory {
    func hash(forSlot index: Int) -> Data? {
        guard -specialSlotCount <= index, codeSlotCount > index else {
            return nil
        }
        let base = offset + hashOffset
        let start = index * hashSize + base
        let end = start + hashSize
        let hash = data.subdata(in: start..<end)
        
        return hash
    }

    func hash(for slot: SpecialSlot) -> Data? {
        hash(forSlot: -slot.rawValue)
    }
}


extension CodeDirectory {
    enum SpecialSlot: Int {
        case INFOSLOT      = 1
        case REQUIREMENTS  = 2
        case RESOURCEDIR   = 3
        case APPLICATION   = 4
        case ENTITLEMENTS  = 5
    }
}
