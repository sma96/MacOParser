//
//  Section.swift
//  IntegrityKit
//
//  Created by 미니 on 10/17/26.
//

import Foundation
import MachO

struct Section {
    private let section: section_64
    private let data: Data
    private let offset: Int
    
    init(section: section_64, data: Data, offset: Int) {
        self.section = section
        self.data = data
        self.offset = offset
    }
}

extension Section {
    var sectionData: Data? {
        let start = Int(section.offset)
        let end = Int(section.size)
        
        return data[start..<end]
    }
    var sectionName: String {
        .init(tuple: section.sectname)
    }
}
