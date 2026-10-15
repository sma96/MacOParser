//
//  MachOParser+CodeSlotProviding.swift
//  IntegrityKit
//
//  Created by 미니 on 10/15/26.
//

import Foundation

protocol CodeSlotProviding {
    var codeSlotHash: [Data]? { get }
    var pageHash: [Data]? { get }
}
