import Foundation

struct Index {
    struct Entry {
        var created = Date()
        var modified = Date()
        var container = String()
        var name = String()
        var size = 0
        var device = 0
        var inode = 0
        var user = 0
        var group = 0
        var conflicts = false
    }
    
    struct Tree {
        var id = String()
        var name = String()
        var entries = 0
        var subtrees = 0
    }
    
    private(set) var id = String()
    private(set) var version = Int()
    private(set) var entries = [Entry]()
    private(set) var trees = [Tree]()
    
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
        index.trees = tree
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
    
    private static func trees(_ parse: Parse) throws -> [Tree] {
        let limit = (try parse.tree())
        var result = [Tree]()
        while parse.index < limit { result.append(try tree(parse)) }
        return result
    }
    
    private static func tree(_ parse: Parse) throws -> Tree {
        var tree = Tree()
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
