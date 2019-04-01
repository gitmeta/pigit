import XCTest
@testable import Pigit

class TestGit: XCTestCase {
    private var url: URL!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory())
        clear()
    }
    
    override func tearDown() {
        clear()
    }
    
    func testRepositoryFails() {
        XCTAssertFalse(Git.repository(url))
    }
    
    func testRepository() {
        XCTAssertNoThrow(try Git.create(url))
        XCTAssertTrue(Git.repository(url))
    }
    
    func testCreate() {
        let root = url.appendingPathComponent(".git")
        let refs = root.appendingPathComponent("refs")
        let objects = root.appendingPathComponent("objects")
        let head = root.appendingPathComponent("HEAD")
        XCTAssertFalse(FileManager.default.fileExists(atPath: root.path))
        XCTAssertNoThrow(try Git.create(url))
        var directory: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: root.path, isDirectory: &directory))
        XCTAssertTrue(directory.boolValue)
        XCTAssertTrue(FileManager.default.fileExists(atPath: refs.path, isDirectory: &directory))
        XCTAssertTrue(directory.boolValue)
        XCTAssertTrue(FileManager.default.fileExists(atPath: objects.path, isDirectory: &directory))
        XCTAssertTrue(directory.boolValue)
        XCTAssertTrue(FileManager.default.fileExists(atPath: head.path, isDirectory: &directory))
        XCTAssertFalse(directory.boolValue)
        
        var data = Data()
        XCTAssertNoThrow(data = try Data(contentsOf: head))
        let content = String(decoding: data, as: UTF8.self)
        XCTAssertTrue(content.contains("ref: refs/"))
    }
    
    private func clear() {
        try? FileManager.default.removeItem(at: url)
    }
}
