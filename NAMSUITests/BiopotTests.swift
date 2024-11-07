//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


final class BiopotTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding"]
        app.launch()
    }

    func testExample() throws {
        let app = XCUIApplication()

        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Schedule"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Schedule"].tap()

        XCTAssertTrue(app.navigationBars.buttons["Nearby Devices"].waitForExistence(timeout: 0.5))
        app.navigationBars.buttons["Nearby Devices"].tap()

        XCTAssertTrue(app.navigationBars.staticTexts["Nearby Devices"].waitForExistence(timeout: 2.0))

        XCTAssertTrue(app.staticTexts["SML BIO 0xAABBCCDD"].waitForExistence(timeout: 2.0))
        app.staticTexts["SML BIO 0xAABBCCDD"].tap()


        XCTAssertTrue(app.staticTexts["SML BIO 0xAABBCCDD, Connected"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.buttons["Device Details"].waitForExistence(timeout: 2.0))
        app.buttons["Device Details"].tap()


        XCTAssertTrue(app.navigationBars.staticTexts["SML BIO 0xAABBCCDD"].waitForExistence(timeout: 2.0))

        XCTAssertTrue(app.staticTexts["Battery, 75 %, is charging"].exists)
        XCTAssertTrue(app.staticTexts["Firmware Version, 1.2.3"].exists)
        XCTAssertTrue(app.staticTexts["Hardware Version, 3.1"].exists)
        XCTAssertTrue(app.staticTexts["Serial Number, 0xAABBCCDD"].exists)

        XCTAssertTrue(app.buttons["Disconnect"].exists)
        app.buttons["Disconnect"].tap()

        XCTAssertTrue(app.navigationBars.staticTexts["Nearby Devices"].waitForExistence(timeout: 2.0))
    }
}
