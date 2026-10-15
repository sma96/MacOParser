//
//  MachOParser+Error.swift
//  IntegrityKit
//
//  Created by 미니 on 10/14/26.
//

import Foundation

enum MachOError: Error {
    case fileNotFound
    case invalidHeader
    case codeSignatureNotFound
    case codeDirectoryNotFound
    case pageHashNotFound
}

extension MachOError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "실행 파일을 찾을 수 없습니다."
        case .invalidHeader:
            return "64bit Mach-O 파일이 아닙니다."
        case .codeSignatureNotFound:
            return "코드 서명을 찾을 수 없습니다."
        case .codeDirectoryNotFound:
            return "Code Directory를 찾을 수 없습니다."
        case .pageHashNotFound:
            return "페이지 해시를 찾을 수 없습니다."
        }
    }
}

