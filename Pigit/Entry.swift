import Foundation

class Entry {
    private var created = Date()
    private var modified = Date()
    private var id = String()
    private var name = String()

    class func make(_ parse: Parse) throws -> Entry {
        let entry: Entry
        let created = try parse.date()
        let modeified = try parse.date()
        let device = try parse.number(4)
        let inode = try parse.number(4)
        
        switch try parse.number(4) {
        case Tree.id: entry = Tree()
        case Blob.id: entry = Blob()
        default: throw Failure.Index.malformed
        }
        
        let userId = try parse.number(4)
        let groupId = try parse.number(4)
        let fileContentLength = try parse.number(4)
        let hash = try parse.string(20)
        let flags = try parse.bit()
        
        if try parse.bit() {
            let waste = try parse.bit()
            let waste2 = try parse.bit()
        }
        
        let name = try parse.variable()
        return entry
    }
}

private class Tree: Entry {
    fileprivate static let id = 0
}

private class Blob: Entry {
    fileprivate static let id = 33188
}
