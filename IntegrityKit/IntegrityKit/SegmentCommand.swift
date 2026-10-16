//
//  SegmentCommand.swift
//  IntegrityKit
//
//  Created by 미니 on 10/17/26.
//

import Foundation
import MachO

struct SegmentCommand {
    private let segment: segment_command_64
    private let data: Data
    private let offset: Int
    
    init(segment: segment_command_64, data: Data, offset: Int) {
        self.segment = segment
        self.data = data
        self.offset = offset
    }
}

extension SegmentCommand {
    var segName: String {
        .init(tuple: segment.segname)
    }
    
    var sections: [Section]? {
        guard segment.nsects > 0 else {
            return nil
        }
        
        let base = offset + MemoryLayout<segment_command_64>.size
        
        return (0..<segment.nsects).map { idx in
            data.withUnsafeBytes {
                let offset = base + MemoryLayout<section_64>.size * Int(idx)
                let section = $0.load(fromByteOffset: offset, as: section_64.self)
                
                return Section(section: section, data: data, offset: offset)
            }
        }
    }
    
    var textSection: Section? {
        sections?.first {
            $0.sectionName == "__text"
        }
    }
}
