import Foundation

struct Index {
    private(set) var version = Int()
    
    static func load(_ url: URL) -> Index? {
        var index = Index()
        guard
            let data = try? Data(contentsOf: url.appendingPathComponent(".git/index")),
            header(data)
        else { return nil }
        return index
    }
    
    private static func header(_ data: Data) -> Bool {
        guard data.count > 12, string(data.subdata(in: 0 ..< 4)) == "DIRC" else { return false }
        return true
    }
    
    private static func string(_ data: Data) -> String { return String(decoding: data, as: UTF8.self) }
    private static func number(_ data: Data) -> String { return data.map { String(format: "%02hhx", $0) }.joined() }
}
