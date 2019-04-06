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
            let tree = try? trees(parse),
            let id = try? parse.hash(),
            parse.index == parse.data.count
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
        return entry
    }
    
    private static func trees(_ parse: Parse) throws -> [Entry.Tree] {
        let limit = (try parse.tree())
        var result = [Entry.Tree]()
        while parse.index < limit { result.append(try tree(parse)) }
        return result
    }
    
    private static func tree(_ parse: Parse) throws -> Entry.Tree {
        var tree = Entry.Tree()
        tree.name = try parse.variable()
        tree.entries = try {
            if $0 == nil { throw Failure.Index.malformed }
            return $0!
        } (Int(try parse.ascii(" ")))
        tree.subtrees = try {
            if $0 == nil { throw Failure.Index.malformed }
            return $0!
        } (Int(try parse.ascii("\n")))
        tree.id = try parse.hash()
        return tree
    }
}
