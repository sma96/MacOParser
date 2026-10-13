//
//  LoadCommands.swift
//  IntegrityKit
//
//  Created by 미니 on 10/13/26.
//

import Foundation
import MachO

//typealias LoadCommand = load_command

struct LoadCommandInfo {
    public var loadCommand: load_command
    public var offset: Int
}

struct LoadCommands: Sequence {
    public let data: Data
    public let numberOfCommands: Int
    public let startOffset: Int
    
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
        self
            .first { $0.loadCommand.cmd == LC_CODE_SIGNATURE }
            .map { CodeSignature(data: data, offset: $0.offset) }
    }
}

struct LoadCommandsIterator: IteratorProtocol {
    typealias Element = LoadCommandInfo
    
    public let data: Data
    public let numberOfCommands: Int

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
