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
        // TODO: make new tests for basic Biopot funcitonality?
        /*
        XCTAssertTrue(app.segmentedControls.buttons["Biopot"].exists)
        app.segmentedControls.buttons["Biopot"].tap()

        XCTAssertTrue(app.buttons["Receive Device Info"].waitForExistence(timeout: 2.0))
        app.buttons["Receive Device Info"].tap()

        XCTAssertTrue(app.staticTexts["STATUS"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Battery, 80 %"].exists)
        XCTAssertTrue(app.staticTexts["Charging, No"].exists)
        XCTAssertTrue(app.staticTexts["Temperature, 23 °C"].exists)
        */
    }
}
