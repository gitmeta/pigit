import Foundation

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
    
    struct Tree {
        var id = String()
        var name = String()
        var entries = String()
        var subtrees = String()
    }
}
