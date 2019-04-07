import XCTest
@testable import Pigit

class TestPress: XCTestCase {
    private var press: Press!

    override func setUp() {
        press = Press()
    }
    
    func testBlob0() {
        XCTAssertEqual("""
blob 12\u{0000}hello rorld\n
""", String(decoding: press.decompress(try!
    Data(contentsOf: Bundle(for: TestPress.self).url(forResource: "blob0", withExtension: nil)!)), as: UTF8.self))
    }
    
    func testTree0() {
        XCTAssertEqual(839, press.decompress(try!
            Data(contentsOf: Bundle(for: TestPress.self).url(forResource: "tree0", withExtension: nil)!)).count)
    }
}
