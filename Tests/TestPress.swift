import XCTest
@testable import Pigit

class TestPress: XCTestCase {
    private var press: Press!

    override func setUp() {
        press = Press()
    }
    
    func testBlob0() {
        XCTAssertEqual("""
blob 12\u{0000}hello rorld

""", String(decoding: press.decompress(try!
    Data(contentsOf: Bundle(for: TestPress.self).url(forResource: "blob0", withExtension: nil)!)), as: UTF8.self))
    }
    
    func testTree0() {
        XCTAssertEqual(839, press.decompress(try!
            Data(contentsOf: Bundle(for: TestPress.self).url(forResource: "tree0", withExtension: nil)!)).count)
    }
    
    func testCommit0() {
        XCTAssertEqual("""
commit 191\u{0000}tree 99ff9f93b7f0f7d300dc3c42d16cdfcdf5c2a82f
author vauxhall <zero.griffin@gmail.com> 1554638195 +0200
committer vauxhall <zero.griffin@gmail.com> 1554638195 +0200

This is my first commit.

""", String(decoding: press.decompress(try!
    Data(contentsOf: Bundle(for: TestPress.self).url(forResource: "commit0", withExtension: nil)!)), as: UTF8.self))
    }
}
