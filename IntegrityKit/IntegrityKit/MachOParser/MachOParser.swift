// IntegrityKit 요구사항을 구현해주세요.

import Foundation
import MachO


final internal class MachOParser {
    private let header: mach_header_64
    private let data: Data
    
    // mach-o header의 magic 값을 통해 64bit인지 체크합니다.
    private var is64Bit: Bool {
        header.magic == MH_MAGIC_64
    }
    
    // 64bit에 맞는 mach-o header의 사이즈를 가져옵니다.
    private var headerSize: Int {
        is64Bit ? MemoryLayout<mach_header_64>.size : MemoryLayout<mach_header>.size
    }
    
    private var loadCommands: LoadCommands {
        LoadCommands(data: data, numberOfCommands: Int(header.ncmds), startOffset: headerSize)
    }
    
    public init() throws {
        guard let filePath = Bundle.main.executableURL else {
            throw MachOError.fileNotFound
        }
        guard let data = try? Data(Data(contentsOf: filePath)) else {
            throw MachOError.fileNotFound
        }
        
        // mach-o header의 메모리 첫번째 주소는 magic 값을 나타냅니다. 이 magic 값을 가져와 64bit인지 체크해줍니다.
        let magic = data.withUnsafeBytes { ptr in
            ptr.load(fromByteOffset: 0, as: UInt32.self)
        }
        guard magic == MH_MAGIC_64 else {
            throw MachOError.invalidHeader
        }
        
        // 실행 파일의 데이터를 mach_header_64 타입으로 변환해줍니다.
        self.header = data.withUnsafeBytes { ptr in
            ptr.load(as: mach_header_64.self)
        }
        self.data = data
    }
}

extension MachOParser {
    public var codeSignature: CodeSignature? {
        loadCommands.codeSignature
    }
    
    public var codeSlotHash: [String]? {
        loadCommands.codeSignature?.sha256CD?.codeSlotsHash.compactMap { $0.hexString }
    }
    
    func getCodeSignature() throws -> CodeSignature {
        if let codeSignature = codeSignature {
            return codeSignature
        } else {
            throw MachOError.codeSignatureNotFound
        }
    }
}
