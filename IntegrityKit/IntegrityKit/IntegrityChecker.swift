//
//  IntegrityCheck.swift
//  IntegrityKit
//
//  Created by 미니 on 10/14/26.
//

import Foundation

// objective-c에서 swift 함수를 호출하기 위해 @objc 사용
@objc public final class IntegrityChecker: NSObject {
    private var machOParser: MachOParser?
    
    public override init() { }
    
    func loadMachOFile() throws {
        self.machOParser = try MachOParser()
    }
}

extension IntegrityChecker {
    @objc public var isTampered: Bool {
        checkCodeSlotHash()
    }
    
    func getCodeSignature() throws -> CodeSignature {
        if let codeSignature = machOParser?.codeSignature {
            return codeSignature
        } else {
            throw MachOError.codeSignatureNotFound
        }
    }
    
    public func checkCodeSlotHash() -> Bool {
        do {
            try loadMachOFile()
            
            let originCodeSlotHash = try getOriginCodeSlotHash()
            
            guard let codeSlotHash = machOParser?.codeSlotHash else {
                return true
            }
            guard originCodeSlotHash.count == codeSlotHash.count else {
                return true
            }
            
            return originCodeSlotHash != codeSlotHash
        } catch {
            print(error.localizedDescription)
        }
        return false
    }
    
    public func getOriginCodeSlotHash() throws -> [String] {
        guard let url = Bundle.main.url(forResource: "Integrity", withExtension: "plist") else {
            throw MachOError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        
        guard let arr = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String] else {
            throw MachOError.fileNotFound
        }
        
        return arr
    }
}
