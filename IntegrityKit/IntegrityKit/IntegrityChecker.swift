//
//  IntegrityCheck.swift
//  IntegrityKit
//
//  Created by 미니 on 10/14/26.
//

import Foundation

// objective-c에서 swift 함수를 호출하기 위해 @objc 사용
@objc public final class IntegrityChecker: NSObject {
    private let makeProvider: () throws -> CodeSlotProviding
    
    
    public override convenience init() {
        self.init(makeProvider: { try MachOParser() })
    }
    
    init(makeProvider: @escaping () throws -> CodeSlotProviding) {
        self.makeProvider = makeProvider
    }
}

extension IntegrityChecker {
    @objc public var isTampered: Bool {
        checkPageHash()
    }
    
    private func checkCodeSlotHash() -> Bool {
        do {
            let codeSlotProvider = try makeProvider()
            let originCodeSlotHash = try getOriginCodeSlotHash()

            guard let codeSlotHash = codeSlotProvider.codeSlotHash?.map({ $0.hexString }) else {
                return true
            }
            guard originCodeSlotHash.count == codeSlotHash.count else {
                return true
            }
            return originCodeSlotHash != codeSlotHash
        } catch {
            print(error.localizedDescription)
            return true
        }
    }

    private func checkPageHash() -> Bool {
        do {
            let codeSlotProvider = try makeProvider()
            let originCodeSlotHash = try getOriginCodeSlotHash()

            guard let pageHash = codeSlotProvider.pageHash?.map({ $0.hexString }) else {
                return true
            }
            guard originCodeSlotHash.count == pageHash.count else {
                return true
            }
            return originCodeSlotHash != pageHash
        } catch {
            print(error.localizedDescription)
            return true
        }
    }

    private func getOriginCodeSlotHash() throws -> [String] {
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
