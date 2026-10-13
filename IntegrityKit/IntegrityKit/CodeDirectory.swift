//
//  CodeDirectory.swift
//  IntegrityKit
//
//  Created by 미니 on 10/14/26.
//

import Foundation
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
    private var codeSlotCount: Int { Int(UInt32(bigEndian: cd.nCodeSlots)) }
    private var specialSlotCount: Int { Int(UInt32(bigEndian: cd.nSpecialSlots)) }
    private var hashSize: Int { Int(UInt8(bigEndian: cd.hashSize)) }
    private var hashOffset: Int { Int(UInt32(bigEndian: cd.hashOffset)) }
    private var hashType: Int { Int(UInt8(bigEndian: cd.hashType)) }
    
    public var codeSlotsHash: [Data] {
        (0..<codeSlotCount).compactMap { hash(forSlot: $0) }
    }
    
    public var specialSlotsHash: [Data] {
        (-specialSlotCount..<0).compactMap { hash(forSlot: $0) }
    }
    
    func getHashType() -> Int {
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
}
