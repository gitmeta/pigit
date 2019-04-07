import Foundation
import Compression

class Press {
    // header 7801
    func decompress(_ data: Data) -> String {
        let size = 8_000_000
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        let result = data.subdata(in: 2 ..< data.count).withUnsafeBytes ({
            let read = compression_decode_buffer(buffer, size, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1),
                                                 data.count - 2, nil, COMPRESSION_ZLIB)
            return String(decoding: Data(bytes: buffer, count:read), as: UTF8.self)
        }) as String
        buffer.deallocate()
        return result
    }
}
