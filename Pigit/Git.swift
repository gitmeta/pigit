import Foundation

public class Git {
    public class func repository(_ url: URL) -> Bool {
        var directory: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/refs").path, isDirectory: &directory),
            directory.boolValue,
            FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects").path, isDirectory: &directory),
            directory.boolValue,
            let head = try? Data(contentsOf: url.appendingPathComponent(".git/HEAD")),
            String(decoding: head, as: UTF8.self).contains("ref: refs/") {
            return true
        }
        return false
    }
    
    public class func create(_ url: URL) throws -> Repository {
        let root = url.appendingPathComponent(".git")
        let objects = root.appendingPathComponent("objects")
        let refs = root.appendingPathComponent("refs")
        let head = root.appendingPathComponent("HEAD")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
        try FileManager.default.createDirectory(at: refs, withIntermediateDirectories: false)
        try FileManager.default.createDirectory(at: objects, withIntermediateDirectories: false)
        try Data("ref: refs/heads/master".utf8).write(to: head, options: .atomic)
        return Repository(root)
    }
    
    public class func delete(_ repository: Repository) throws {
        try FileManager.default.removeItem(at: repository.url)
    }
}
