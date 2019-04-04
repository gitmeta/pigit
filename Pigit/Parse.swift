import Foundation

class Parse {
    private var index = 0
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
            index += 1
            byte = try string(1)
        } while(byte != "\u{0000}")
        return result
    }
    
    func string(_ bytes: Int) throws -> String { return String(decoding: try advance(bytes), as: UTF8.self) }
    
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
    
    func bit() throws -> Bool {
        return try advance(1).withUnsafeBytes { $0.baseAddress!.bindMemory(to: Bool.self, capacity: 1).pointee }
    }
    
    private func advance(_ bytes: Int) throws -> Data {
        let index = self.index + bytes
        guard data.count >= index else { throw Failure.Index.malformed }
        let result = data.subdata(in: self.index ..< index)
        self.index = index
        return result
    }
}
