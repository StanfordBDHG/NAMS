//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions

class EEGDeviceTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--testBLEDevices"]
        app.launch()
    }


    func testNearbyDevicesAndDetails() throws {
        let app = XCUIApplication()

        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Schedule"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Schedule"].tap()

        XCTAssertTrue(app.navigationBars.buttons["Nearby Devices"].waitForExistence(timeout: 0.5))
        XCTAssertFalse(app.navigationBars.buttons["EEG Recording"].waitForExistence(timeout: 0.5))


        // open nearby devices sheet
        app.navigationBars.buttons["Nearby Devices"].tap()

        XCTAssertTrue(app.navigationBars.staticTexts["Nearby Devices"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Make sure your headband is turned on and nearby."].waitForExistence(timeout: 0.5))

        // we don't check for the existence of the progress view as we probably cannot time that precisely

        XCTAssertTrue(app.buttons["Mock, Device 1"].waitForExistence(timeout: 5.0))
        app.buttons["Mock, Device 1"].tap()


        XCTAssertTrue(app.buttons["Mock, Device 1, Connected"].waitForExistence(timeout: 5.0))
        XCTAssertTrue(app.buttons["Mock, Device 2"].waitForExistence(timeout: 0.5)) // ensure not connected

        // TODO check if want to make this label unique?
        XCTAssertTrue(app.buttons["Device Details"].waitForExistence(timeout: 2.0))
        app.buttons["Device Details"].tap()


        // DEVICE DETAILS
        XCTAssertTrue(app.navigationBars.staticTexts["Device 1"].waitForExistence(timeout: 2.0)) // TODO might we display something different?


        print(app.staticTexts.debugDescription)
        XCTAssertTrue(app.staticTexts["Battery, 75 %"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.staticTexts["Issues with your battery? Troubleshooting"].waitForExistence(timeout: 0.5))

        XCTAssertTrue(app.staticTexts["HEADBAND"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.staticTexts["Wearing, Yes"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.staticTexts["Headband Fit, mediocre"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.staticTexts["Issues maintaining a good fit? Troubleshooting"].waitForExistence(timeout: 0.5))

        XCTAssertTrue(app.staticTexts["ABOUT"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.staticTexts["Serial Number, AA BB CC DD"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.staticTexts["Firmware Version, 1.2.0"].waitForExistence(timeout: 0.5))

        // DISCONNECT
        XCTAssertTrue(app.buttons["Disconnect"].waitForExistence(timeout: 0.5))
        app.buttons["Disconnect"].tap()

        XCTAssertTrue(app.buttons["Mock, Device 1"].waitForExistence(timeout: 5.0)) // ensure not connected
    }
}
