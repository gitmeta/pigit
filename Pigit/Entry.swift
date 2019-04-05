import Foundation

class Entry {
    private(set) var created = Date()
    private(set) var modified = Date()
    private(set) var container = String()
    private(set) var name = String()
    private(set) var size = 0
    private(set) var device = 0
    private(set) var inode = 0
    private(set) var user = 0
    private(set) var group = 0
    private(set) var conflicts = false

    class func make(_ parse: Parse) throws -> Entry {
        let entry: Entry
        
        switch try parse.type() {
        case Tree.type: entry = Tree()
        default: entry = Blob()
        }
        
        entry.created = try parse.date()
        entry.modified = try parse.date()
        entry.device = try parse.number(4)
        entry.inode = try parse.number(4)
        
        parse.index += 4
        
        entry.user = try parse.number(4)
        entry.group = try parse.number(4)
        entry.size = try parse.number(4)
        entry.container = try parse.hash(20)
        entry.conflicts = try parse.conflict()

        try entry.name = {
            parse.index += $0 ? 4 : 2
            return try parse.string($1)
        } (try parse.version3(), try parse.length())
        
        print(entry.name)
        print(entry.container)
        return entry
    }
}

class Tree: Entry {
    fileprivate static let type = 16384
}

class Blob: Entry {
    fileprivate static let type = 33188
}
