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
    }
}
