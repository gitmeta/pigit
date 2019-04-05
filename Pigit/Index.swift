import Foundation

struct Index {
    private(set) var id = String()
    private(set) var version = Int()
    private(set) var entries = [Entry]()
    private(set) var tree = [Entry.Tree]()
    
    static func load(_ url: URL) -> Index? {
        var index = Index()
        guard
            let parse = Parse(url.appendingPathComponent(".git/index")),
            "DIRC" == (try? parse.string()),
            let version = try? parse.number(),
            let count = try? parse.number(),
            let entries = try? (0 ..< count).map({ _ in try entry(parse) }),
            let tree = try? tree(parse),
            let id = try? parse.hash()
        else { return nil }
        index.version = version
        index.entries = entries
        index.tree = tree
        index.id = id
        return index
    }
    
    private static func entry(_ parse: Parse) throws -> Entry {
        var entry = Entry()
        entry.created = try parse.date()
        entry.modified = try parse.date()
        entry.device = try parse.number()
        entry.inode = try parse.number()
        if (try? parse.number()) != 33188 { throw Failure.Index.malformed }
        entry.user = try parse.number()
        entry.group = try parse.number()
        entry.size = try parse.number()
        entry.container = try parse.hash()
        entry.conflicts = try parse.conflict()
        entry.name = try parse.name()
        parse.clean()
        return entry
    }
    
    private static func tree(_ parse: Parse) throws -> [Entry.Tree] {
        let limit = parse.index + (try parse.tree())
        var result = [Entry.Tree]()
        while parse.index < limit {
            debugPrint("name \(try parse.variable())")
            parse.clean()
            debugPrint("entries: \(try parse.ascii(" "))")
            //debugPrint("space: \(try parse.string(1))")
            debugPrint("subtrees: \(try parse.ascii("\n"))")
            //debugPrint("linefeed: \(try parse.string(1))")
            debugPrint("hash: \(try parse.hash())")
            print("remains: \(parse.index) ..< \(parse.data.count)")
            
            debugPrint("name \(try parse.variable())")
            parse.clean()
            debugPrint("entries: \(try parse.ascii(" "))")
            //debugPrint("space: \(try parse.string(1))")
            debugPrint("subtrees: \(try parse.ascii("\n"))")
            //debugPrint("linefeed: \(try parse.string(1))")
            debugPrint("hash: \(try parse.hash())")
            print("remains: \(parse.index) ..< \(parse.data.count)")
        }
        return result
    }
}
