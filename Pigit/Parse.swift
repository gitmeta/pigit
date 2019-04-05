import Foundation

class Parse {
    var index = 0
    private let data: Data
    
    init?(_ url: URL) {
        if let data = try? Data(contentsOf: url) {
            self.data = data
        } else {
            return nil
        }
    }
    
    func variable() throws -> String {
        var result = String()
        var byte = String()
        repeat {
            result += byte
            byte = try string(1)
        } while(byte != "\u{0000}")
        return result
    }
    
    func type() throws -> Int {
        guard data.count > index + 28,
        let result = Int(data.subdata(in: index + 24 ..< index + 28).map { String(format: "%02hhx", $0) }.joined(), radix: 16)
        else { throw Failure.Index.malformed }
        return result
    }
    
    func string(_ bytes: Int) throws -> String { return String(decoding: try advance(bytes), as: UTF8.self) }
    
    func hash(_ bytes: Int) throws -> String {
        return (try advance(bytes)).map { String(format: "%02hhx", $0) }.joined()
    }
    
    func number(_ bytes: Int) throws -> Int {
        if let result = Int(try advance(bytes).map { String(format: "%02hhx", $0) }.joined(), radix: 16) {
            return result
        }
        throw Failure.Index.malformed
    }
    
    func date() throws -> Date {
        let result = Date(timeIntervalSince1970: TimeInterval(try number(4)))
        index += 4
        return result
    }
    
    func bits() throws -> [Int] {
        var byte = try advance(2).withUnsafeBytes { $0.baseAddress!.bindMemory(to: UInt16.self, capacity: 1).pointee }
        return (0 ..< 16).map { _ in
            let bit = byte & 0x01
            byte >>= 1
            return bit == 0 ? 0 : 1
        }
    }
    
    private func advance(_ bytes: Int) throws -> Data {
        let index = self.index + bytes
        guard data.count >= index else { throw Failure.Index.malformed }
        let result = data.subdata(in: self.index ..< index)
        self.index = index
        return result
    }
}
