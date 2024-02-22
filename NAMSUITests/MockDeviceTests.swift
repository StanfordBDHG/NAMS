//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions

class MockDeviceTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--inject-default-patient"]
        app.launch()
    }


    func testNearbyDevicesAndDetails() {
        let app = XCUIApplication()

        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Schedule"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Schedule"].tap()

        XCTAssertTrue(app.navigationBars.buttons["Nearby Devices"].waitForExistence(timeout: 0.5))
        XCTAssertFalse(app.navigationBars.buttons["EEG Recording"].waitForExistence(timeout: 0.5))


        // open nearby devices sheet
        app.navigationBars.buttons["Nearby Devices"].tap()

        XCTAssertTrue(app.navigationBars.staticTexts["Nearby Devices"].waitForExistence(timeout: 2.0))

        // we don't check for the existence of the progress view as we probably cannot time that precisely

        XCTAssertTrue(app.buttons["Mock Device 1"].waitForExistence(timeout: 5.0))
        app.buttons["Mock Device 1"].tap()


        XCTAssertTrue(app.buttons["Mock Device 1, Connected"].waitForExistence(timeout: 5.0))
        XCTAssertTrue(app.buttons["Mock Device 2"].waitForExistence(timeout: 0.5)) // ensure not connected

        XCTAssertTrue(app.buttons["Device Details"].waitForExistence(timeout: 2.0))
        app.buttons["Device Details"].tap()


        // DEVICE DETAILS
        XCTAssertTrue(app.navigationBars.staticTexts["Mock Device 1"].waitForExistence(timeout: 2.0))


        XCTAssertTrue(app.staticTexts["Battery, 75 %"].exists)
        XCTAssertTrue(app.staticTexts["Issues with your battery? Troubleshooting"].exists)

        XCTAssertTrue(app.staticTexts["HEADBAND"].exists)
        XCTAssertTrue(app.staticTexts["Wearing, Yes"].exists)
        XCTAssertTrue(app.staticTexts["Headband Fit, mediocre"].exists)
        XCTAssertTrue(app.staticTexts["Issues maintaining a good fit? Troubleshooting"].exists)

        XCTAssertTrue(app.staticTexts["ABOUT"].exists)
        XCTAssertTrue(app.staticTexts["Serial Number, 0xAABBCCDD"].exists)
        XCTAssertTrue(app.staticTexts["Firmware Version, 1.2"].exists)

        XCTAssertTrue(app.buttons["Headband Fit, mediocre"].exists)
        app.buttons["Headband Fit, mediocre"].tap()

        // HEADBAND FIT DETAILS
        XCTAssertTrue(app.navigationBars.staticTexts["Headband Fit"].waitForExistence(timeout: 2.0))

        XCTAssertTrue(app.staticTexts["Overall, mediocre"].exists)
        XCTAssertTrue(app.staticTexts["TP9, good"].exists)
        XCTAssertTrue(app.staticTexts["AF7, mediocre"].exists)
        XCTAssertTrue(app.staticTexts["AF8, poor"].exists)
        XCTAssertTrue(app.staticTexts["TP10, good"].exists)

        // back button
        app.navigationBars.buttons.firstMatch.tap()

        // DISCONNECT
        XCTAssertTrue(app.buttons["Disconnect"].waitForExistence(timeout: 0.5))
        app.buttons["Disconnect"].tap()

        XCTAssertTrue(app.buttons["Mock Device 1"].waitForExistence(timeout: 5.0)) // ensure not connected
    }

    func testEEGRecordings() {
        let app = XCUIApplication()

        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Schedule"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Schedule"].tap()

        XCTAssertTrue(app.buttons["Example Patient"].waitForExistence(timeout: 4.0))

        XCTAssertTrue(app.staticTexts["MEASUREMENTS"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.staticTexts["EEG Recording"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(
            app.staticTexts["No EEG Headband connected. You must connect to a nearby EEG device first inorder to perform an EEG."]
                .waitForExistence(timeout: 0.5)
        )
        XCTAssertTrue(app.buttons["Start Recording"].waitForExistence(timeout: 0.5))
        XCTAssertFalse(app.buttons["Start Recording"].isEnabled)

        // open nearby devices sheet
        XCTAssertTrue(app.navigationBars.buttons["Nearby Devices"].waitForExistence(timeout: 6))
        app.navigationBars.buttons["Nearby Devices"].tap()

        XCTAssertTrue(app.navigationBars.staticTexts["Nearby Devices"].waitForExistence(timeout: 2.0))

        XCTAssertTrue(app.buttons["Mock Device 1"].waitForExistence(timeout: 5.0))
        app.buttons["Mock Device 1"].tap()
        XCTAssertTrue(app.buttons["Mock Device 1, Connected"].waitForExistence(timeout: 5.0))

        XCTAssertTrue(app.navigationBars.buttons["Close"].waitForExistence(timeout: 0.5))
        app.navigationBars.buttons["Close"].tap()

        XCTAssertTrue(app.buttons["Start Recording"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.buttons["Start Recording"].isEnabled)
        app.buttons["Start Recording"].tap()

        XCTAssertTrue(app.scrollViews.buttons["Start Recording"].waitForExistence(timeout: 2.0))
        app.scrollViews.buttons["Start Recording"].tap()
        

        app.swipeUp(velocity: .fast)

        XCTAssertTrue(app.buttons["Mark completed"].waitForExistence(timeout: 6.0))
        app.buttons["Mark completed"].tap()

        XCTAssertTrue(app.staticTexts["Brain activity was collected for this patient."].waitForExistence(timeout: 4.0))
        XCTAssertTrue(app.staticTexts["Completed"].waitForExistence(timeout: 0.5))
    }
}
