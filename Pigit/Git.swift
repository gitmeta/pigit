import Foundation

public class Git {
    private static let queue = DispatchQueue(label: String(), qos: .background, target: .global(qos: .background))
    
    public class func repository(_ url: URL, result: @escaping((Bool) -> Void)) {
        queue.async {
            var directory: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/refs").path, isDirectory: &directory),
                directory.boolValue,
                FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects").path, isDirectory: &directory),
                directory.boolValue,
                let head = try? Data(contentsOf: url.appendingPathComponent(".git/HEAD")),
                String(decoding: head, as: UTF8.self).contains("ref: refs/") {
                DispatchQueue.main.async { result(true) }
            } else {
                DispatchQueue.main.async { result(false) }
            }
        }
    }
    
    public class func create(_ url: URL, error: ((Error) -> Void)? = nil, result: ((Repository) -> Void)? = nil) {
        queue.async {
            repository(url) {
                if $0 {
                    error?(GitError.Repository.alreadyExists)
                } else {
                    queue.async {
                        do {
                            let root = url.appendingPathComponent(".git")
                            let objects = root.appendingPathComponent("objects")
                            let refs = root.appendingPathComponent("refs")
                            let head = root.appendingPathComponent("HEAD")
                            try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
                            try FileManager.default.createDirectory(at: refs, withIntermediateDirectories: false)
                            try FileManager.default.createDirectory(at: objects, withIntermediateDirectories: false)
                            try Data("ref: refs/heads/master".utf8).write(to: head, options: .atomic)
                            DispatchQueue.main.async { result?(Repository(root)) }
                        } catch let exception {
                            DispatchQueue.main.async { error?(exception) }
                        }
                    }
                }
            }
        }
    }
    
    public class func delete(_ repository: Repository, error: ((Error) -> Void)? = nil, result: (() -> Void)? = nil) {
        queue.async {
            do {
                try FileManager.default.removeItem(at: repository.url)
                DispatchQueue.main.async {
                    result?()
                }
            } catch let exception {
                DispatchQueue.main.async {
                    error?(exception)
                }
            }
        }
    }
}
