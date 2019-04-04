import Foundation

struct Index {
    private(set) var version = Int()
    private(set) var entries = [Entry]()
    
    static func load(_ url: URL) -> Index? {
        var index = Index()
        guard
            let data = try? Data(contentsOf: url.appendingPathComponent(".git/index")),
            header(data),
            let version = Int(number(data.subdata(in: 4 ..< 8))),
            let entries = try? entries(data)
        else { return nil }
        index.version = version
        index.entries = entries
        return index
    }
    
    private static func header(_ data: Data) -> Bool {
        guard data.count > 12, string(data.subdata(in: 0 ..< 4)) == "DIRC" else { return false }
        return true
    }
    
    private static func entries(_ data: Data) throws -> [Entry] {
        guard let count = Int(number(data.subdata(in: 8 ..< 12))) else { throw Failure.Index.malformed }
        var entries = [Entry]()
        var byte = 12
        for _ in 0 ..< count {
            let createdSeconds = Int(number(data.subdata(in: byte ..< byte + 4)))
            byte += 4
            let createdNano = number(data.subdata(in: byte ..< byte + 4))
            byte += 4
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
            let flags1 = number(data.subdata(in: byte ..< byte + 2))
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
    
    private static func string(_ data: Data) -> String { return String(decoding: data, as: UTF8.self) }
    private static func number(_ data: Data) -> String { return data.map { String(format: "%02hhx", $0) }.joined() }
}
