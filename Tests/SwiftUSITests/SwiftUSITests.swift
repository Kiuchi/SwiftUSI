import XCTest
@testable import SwiftUSI

final class SwiftUSITests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftUSI().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
