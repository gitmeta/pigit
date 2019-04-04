import Foundation

struct Index {
    private(set) var version = Int()
    private(set) var entries = [Entry]()
    
    static func load(_ url: URL) -> Index? {
        var index = Index()
        guard
            let parse = Parse(url.appendingPathComponent(".git/index")),
            "DIRC" == (try? parse.string(4)),
            let version = try? parse.number(4),
            let entries = try? parse.number(4)
        else { return nil }
        index.version = version
        index.entries = entries
        return index
    }
    
    private static func header(_ parse: Parse) -> Bool {
        guard (try? parse.string(4)) == "DIRC" else { return false }
        return true
    }
    
    private static func entries(_ data: Data) throws -> [Entry] {
        guard let count = Int(number(data.subdata(in: 8 ..< 12))) else { throw Failure.Index.malformed }
        var entries = [Entry]()
        var byte = 12
        for _ in 0 ..< count {
            
            print(Date(timeIntervalSince1970: TimeInterval(Int(number(data.subdata(in: byte ..< byte + 4)), radix: 16)!)))
            print(number(data.subdata(in: byte + 4 ..< byte + 8)))
//            debugPrint(number(data.subdata(in: byte ..< byte + 8)))
//            let createdSeconds = number()
//            debugPrint(createdSeconds)
            break
            debugPrint(data.subdata(in: byte ..< byte + 4).printableAscii)
            debugPrint(number(data.subdata(in: byte ..< byte + 4)))
            
            byte += 4
            
            
            
            let createdNano = number(data.subdata(in: byte ..< byte + 4))
            byte += 4
            
            print(data.subdata(in: byte ..< byte + 4).withUnsafeBytes { $0.baseAddress!.bindMemory(to: UInt32.self, capacity: 1).pointee })
            
            let modifiedSeconds = number(data.subdata(in: byte ..< byte + 4))
            byte += 4
            let modifiedNano = number(data.subdata(in: byte ..< byte + 4))
            byte += 4
            let device = number(data.subdata(in: byte ..< byte + 4))
            byte += 4
            let inode = number(data.subdata(in: byte ..< byte + 4))
            byte += 4
            let mode = number(data.subdata(in: byte ..< byte + 4))
            byte += 4
            let userId = number(data.subdata(in: byte ..< byte + 4))
            byte += 4
            let groupId = number(data.subdata(in: byte ..< byte + 4))
            byte += 4
            let fileContentLength = string(data.subdata(in: byte ..< byte + 4))
            byte += 4
            let hash = number(data.subdata(in: byte ..< byte + 20))
            byte += 20
//            let flags1 = Int(number(data.subdata(in: byte ..< byte + 2)))
//            byte += 2
            
//            let value = data.withUnsafeBytes {
//                $0.baseAddress!.bindMemory(to: Double.self, capacity: 1).pointee
//            }
            
//            print(data.subdata(in: byte ..< byte + 1).withUnsafeBytes { $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1).pointee })
            
            print(data.subdata(in: byte + 1 ..< byte + 2).withUnsafeBytes { $0.baseAddress!.bindMemory(to: Bool.self, capacity: 1).pointee })
            byte += 2
            
//            let flags2 = number(data.subdata(in: byte ..< byte + 2))
//            byte += 2
            var name = String()
            var c = String()
            repeat {
                c = string(data.subdata(in: byte ..< byte + 1))
                name += c
                byte += 1
            } while(c != "\u{0000}")
            print(name)
            print(hash)
            print(fileContentLength)
            print(mode)
        }
        return entries
    }
}
