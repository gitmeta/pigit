import XCTest
@testable import Pigit

class TestPress: XCTestCase {
    private var press: Press!

    override func setUp() {
        press = Press()
    }
    
    func testTree0() {
        XCTAssertEqual("""
hello world
""", try? press.decompress(
    try! Data(contentsOf: Bundle(for: TestPress.self).url(forResource: "blob0", withExtension: nil)!)))
    }
}
