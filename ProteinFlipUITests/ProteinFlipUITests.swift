import XCTest

final class ProteinFlipUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testProteinNavigationTitleExists() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars["Protein"].exists)
    }
}
