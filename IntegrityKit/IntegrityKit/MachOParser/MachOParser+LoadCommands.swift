//
//  LoadCommands.swift
//  IntegrityKit
//
//  Created by 미니 on 10/13/26.
//

import Foundation
import MachO

struct LoadCommandInfo {
    var loadCommand: load_command
    var offset: Int
}

// 가독성과 사용성을 고려하여 Sequence를 준수하여 구현했습니다.
struct LoadCommands: Sequence {
    private let data: Data
    private let numberOfCommands: Int
    private let startOffset: Int
    
    init(data: Data, numberOfCommands: Int, startOffset: Int) {
        self.data = data
        self.numberOfCommands = numberOfCommands
        self.startOffset = startOffset
    }
    
    func makeIterator() -> LoadCommandsIterator {
        LoadCommandsIterator(data: data, numberOfCommands: numberOfCommands, startOffset: startOffset)
    }
}

extension LoadCommands {
    var segment64: [LoadCommandInfo]? {
        self.compactMap {
            guard $0.loadCommand.cmd == LC_SEGMENT_64 else {
                return nil
            }
            return $0
        }
    }
    var codeSignature: CodeSignature? {
        self.first { $0.loadCommand.cmd == LC_CODE_SIGNATURE }
            .map { CodeSignature(data: data, offset: $0.offset) }
    }
}

struct LoadCommandsIterator: IteratorProtocol {
    typealias Element = LoadCommandInfo
    
    private let data: Data
    private let numberOfCommands: Int

    private var nextOffset: Int = 0
    private var nextIndex: Int = 0
    
    init(data: Data, numberOfCommands: Int, startOffset: Int) {
        self.data = data
        self.numberOfCommands = numberOfCommands
        self.nextOffset = startOffset
    }
    
    mutating func next() -> LoadCommandInfo? {
        guard nextOffset < data.count else {
            return nil
        }
        guard nextIndex < numberOfCommands else {
            return nil
        }
        
        return data.withUnsafeBytes {
            let loadCommand = $0.load(fromByteOffset: nextOffset, as: load_command.self)
            let info = LoadCommandInfo(loadCommand: loadCommand, offset: nextOffset)
            
            nextOffset += Int(loadCommand.cmdsize)
            nextIndex += 1
            
            return info
        }
    }
}
