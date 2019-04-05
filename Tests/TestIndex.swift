import XCTest
@testable import Pigit

class TestIndex: XCTestCase {
    private var url: URL!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory())
        try? FileManager.default.createDirectory(at: url.appendingPathComponent(".git"), withIntermediateDirectories: false)
    }
    
    override func tearDown() {
        try! FileManager.default.contentsOfDirectory(atPath: url.path).forEach {
            try! FileManager.default.removeItem(at: url.appendingPathComponent($0))
        }
    }
    
    func testIndexFails() {
        try! Data().write(to: url.appendingPathComponent(".git/index"))
        XCTAssertNil(Index.load(url))
    }
    
    func testIndexNoExists() {
        XCTAssertNil(Index.load(url))
    }
    
    func testIndex() {
        try! (try! Data(contentsOf: Bundle(for: TestIndex.self).url(forResource: "index0", withExtension: nil)!)).write(to:
            url.appendingPathComponent(".git/index"))
        let index = Index.load(url)
        XCTAssertNotNil(index)
        XCTAssertEqual(2, index?.version)
        XCTAssertEqual(1, index?.entries.count)
        XCTAssertNotNil(index?.entries.first as? Blob)
        XCTAssertEqual("afile.json", index?.entries.first?.name)
        XCTAssertEqual("3b18e512dba79e4c8300dd08aeb37f8e728b8dad", index?.entries.first?.id)
        XCTAssertEqual(12, index?.entries.first?.size)
        XCTAssertEqual(Date(timeIntervalSince1970: 1554190306), index?.entries.first?.created)
        XCTAssertEqual(Date(timeIntervalSince1970: 1554190306), index?.entries.first?.modified)
        XCTAssertEqual(16777220, index?.entries.first?.device)
        XCTAssertEqual(10051196, index?.entries.first?.inode)
        XCTAssertEqual(502, index?.entries.first?.user)
        XCTAssertEqual(20, index?.entries.first?.group)
    }
}
