import XCTest
@testable import Pigit

class TestHasher: XCTestCase {
    private var hasher: Hasher!
    private var url: URL!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("file.json")
        try! "hello world\n".write(to: url, atomically: true, encoding: .utf8)
        hasher = Hasher()
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: url)
    }
    
    func testFile() {
        XCTAssertEqual("3b18e512dba79e4c8300dd08aeb37f8e728b8dad", try? hasher.file(url))
    }
}
