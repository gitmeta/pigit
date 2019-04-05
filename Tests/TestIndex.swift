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
    
    func testIndex0() {
        try! (try! Data(contentsOf: Bundle(for: TestIndex.self).url(forResource: "index0", withExtension: nil)!)).write(to:
            url.appendingPathComponent(".git/index"))
        let index = Index.load(url)
        XCTAssertNotNil(index)
        XCTAssertEqual(2, index?.version)
        XCTAssertEqual(1, index?.entries.count)
        XCTAssertNotNil(index?.entries.first)
        XCTAssertEqual("483a3bef65960a1651d83168f2d1501397617472", index?.id)
        XCTAssertTrue(index?.entries.first?.conflicts == false)
        XCTAssertEqual("afile.json", index?.entries.first?.name)
        XCTAssertEqual("3b18e512dba79e4c8300dd08aeb37f8e728b8dad", index?.entries.first?.container)
        XCTAssertEqual(12, index?.entries.first?.size)
        XCTAssertEqual(Date(timeIntervalSince1970: 1554190306), index?.entries.first?.created)
        XCTAssertEqual(Date(timeIntervalSince1970: 1554190306), index?.entries.first?.modified)
        XCTAssertEqual(16777220, index?.entries.first?.device)
        XCTAssertEqual(10051196, index?.entries.first?.inode)
        XCTAssertEqual(502, index?.entries.first?.user)
        XCTAssertEqual(20, index?.entries.first?.group)
    }
    
    func testIndex1() {
        try! (try! Data(contentsOf: Bundle(for: TestIndex.self).url(forResource: "index1", withExtension: nil)!)).write(to:
            url.appendingPathComponent(".git/index"))
        let index = Index.load(url)
        XCTAssertNotNil(index)
        XCTAssertEqual(2, index?.version)
        XCTAssertEqual(22, index?.entries.count)
        XCTAssertEqual("be8343716dab3cb0a2f40813b3f0077bb0cb1a80", index?.id)
    }
    
    func testIndex2() {
        try! (try! Data(contentsOf: Bundle(for: TestIndex.self).url(forResource: "index2", withExtension: nil)!)).write(to:
            url.appendingPathComponent(".git/index"))
        let index = Index.load(url)
        XCTAssertNotNil(index)
        XCTAssertEqual(2, index?.version)
        XCTAssertEqual(22, index?.entries.count)
        XCTAssertEqual("545245450000004100323220310a9d59da034b57", index?.id)
    }
}
