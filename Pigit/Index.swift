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
            let entries = try? entries(parse)
        else { return nil }
        index.version = version
        index.entries = entries
        return index
    }
    
    private static func entries(_ parse: Parse) throws -> [Entry] {
        var entries = [Entry]()
        for _ in 0 ..< (try parse.number(4)) {
            entries.append(try Entry.make(parse))
            parse.clean()
        }
        
        print("remains: \(parse.index) ..< \(parse.data.count)")
        print(try parse.string(4))
        return entries
    }
}
