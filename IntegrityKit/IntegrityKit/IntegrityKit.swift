// IntegrityKit 요구사항을 구현해주세요.

import Foundation
import MachO

final public class IntegrityHelper {
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
    
    public init?() throws {
        guard let filePath = Bundle.main.executableURL else {
            return nil
        }
        guard let data = try? Data(Data(contentsOf: filePath)) else {
            return nil
        }
        
        // mach-o header의 메모리 첫번째 주소는 magic 값을 나타냅니다. 이 magic 값을 가져와 64bit인지 체크해줍니다.
        let magic = data.withUnsafeBytes { ptr in
            ptr.load(fromByteOffset: 0, as: UInt32.self)
        }
        guard magic == MH_MAGIC_64 else {
            return nil
        }
        
        // 실행 파일의 데이터를 mach_header_64 타입으로 변환해줍니다.
        self.header = data.withUnsafeBytes { ptr in
            ptr.load(as: mach_header_64.self)
        }
        self.data = data
    }
    
    
    
    public func loadCommand() {
        print(UInt32(bigEndian: loadCommands.codeSignature?.sha256CD?.nCodeSlots ?? 0))
        
//        data.withUnsafeBytes {
//            var offset = headerSize
//            
//            for _ in 0..<header.ncmds {
//                guard data.count > offset else {
//                    return
//                }
//                let lc = $0.load(fromByteOffset: offset, as: load_command.self)
//                if lc.cmd == LC_CODE_SIGNATURE {
//                    let lit = $0.load(fromByteOffset: offset, as: linkedit_data_command.self)
//                    let blob = $0.load(fromByteOffset: Int(lit.dataoff), as: CS_SuperBlob.self)
//                    let count = Int(UInt32(bigEndian: blob.count))
//                    
//                    let startIdx = Int(lit.dataoff) + MemoryLayout<CS_SuperBlob>.size
//                    let entrySize = MemoryLayout<CS_BlobIndex>.size
//                    
//                    for i in 0..<count {
//                        let entry = $0.load(fromByteOffset: startIdx + Int(i) * entrySize,
//                                                          as: CS_BlobIndex.self)
//                        
//                        let type = UInt32(bigEndian: entry.type)
//                        let offset = UInt32(bigEndian: entry.offset)   // SuperBlob 시작 기준
//                        print("2 = \(offset)")
//                        if type == CSSLOT_CODEDIRECTORY {
//                            let cd = $0.load(fromByteOffset: Int(lit.dataoff + offset), as: CS_CodeDirectory.self)
//                            if UInt32(bigEndian: cd.magic) == CSMAGIC_CODEDIRECTORY {
//                                let codeSlotCount = UInt32(bigEndian: cd.nCodeSlots)
//                                let specialSlotCount = UInt32(bigEndian: cd.nSpecialSlots)
//                                let hashSize = UInt8(bigEndian: cd.hashSize)
//                                let hashOffset = UInt32(bigEndian: cd.hashOffset)
//                                var start = $0.baseAddress! + Int(lit.dataoff + offset) + Int(hashOffset)
//                                
//                                for i in stride(from: specialSlotCount, to: 0, by: -1) {
//                                    let slot = Data(bytes: start - Int(i) * Int(hashSize), count: Int(hashSize))
//                                    
//                                    let hash = slot.map { String(format: "%02x", $0) }.joined()
//                                    print("-\(i) = \(hash)")
//                                }
//
//                                
//                                for i in stride(from: 0, to: codeSlotCount, by: 1) {
//                                    let slot = Data(bytes: start + Int(i) * Int(hashSize), count: Int(hashSize))
//                                    let hash = slot.map { String(format: "%02x", $0) }.joined()
//                                    print("\(i) = \(hash)")
//
//                                }
//                                print("slot \(type) → offset \(offset), hashType = \(cd.hashType)")
//                            }
//                        }
//                    }
//                    
//                    print("blob magic = \(UInt32(bigEndian: blob.magic))")
//                    
////                    for i in 0..<blob.index.count {
////                        switch CSMagic(rawValue: UInt32(bigEndian: blob.index[i].type)) {
////                        case .blobWrapper:
////                            print("blobWrapper")
////                        case .codeDirectory:
////                            print("code directory")
////                        case .detachedSignature:
////                            print("detachedSignature")
////                        case .embeddedSignature:
////                            print("embedded signature")
////                        case .requirement:
////                            print("requirement")
////                        case .requirements:
////                            print("requirements")
////                        default:
////                            break
////                            
////                        }
////
////                    }
//                                        print(0xfade0c02)
//                    
//                    print("code signature = \(lit.cmd == LC_CODE_SIGNATURE)")
//                    
//                } else if lc.cmd == LC_SEGMENT_64 {
//                    print("LC_SEGMENT_64")
//                }
//                offset += Int(lc.cmdsize)
//            }
//        }
    }
    
    
}
