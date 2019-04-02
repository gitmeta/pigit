import Foundation
import CommonCrypto

class Hasher {
    func file(_ url: URL) throws -> String {
        return {
            hash(Data(("blob \($0.count)\u{0000}" + String(decoding: $0, as: UTF8.self)).utf8))
        } (try Data(contentsOf: url))
    }
    
    private func hash(_ data: Data) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        _ = data.withUnsafeBytes { CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest) }
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
