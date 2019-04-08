import Foundation

public class Repository {
    public let url: URL
    
    init(_ url: URL) {
        self.url = url
    }
    
    public func status(_ result: @escaping((Status) -> Void)) {
        DispatchQueue.main.async {
            result(Status())
        }
    }
}
