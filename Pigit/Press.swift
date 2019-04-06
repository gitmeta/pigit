import Foundation
import Compression

class Press {
    func decompress(_ data: Data) throws -> String {
        return try data.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) -> String in
            
            let base = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1)
            var stream = base.pointee
            var status = compression_stream_init(&stream, COMPRESSION_STREAM_DECODE, COMPRESSION_ZLIB)
            let size = Swift.max( Swift.min(data.count, 4096), 64)
            var buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
            stream.dst_ptr  = buffer
            stream.dst_size = size
            stream.src_ptr = pointer
            stream.src_size = data.count
            var result = Data()
            
            while stream.src_size > 0 || stream.dst_size < size {
                compression_stream_process(&stream, Int32(COMPRESSION_STREAM_FINALIZE.rawValue))
                result.append(buffer, count: size - stream.dst_size)
                stream.dst_size = size
            }
            
//            buffer.deallocate()
//            compression_stream_destroy(&stream)
//            base.deallocate()
//            return  Data(String(decoding: result, as: UTF8.self).utf8).map { String(format: "%02hhx", $0) }.joined()
            return String(decoding: result, as: UTF8.self)
        }
    }
}
