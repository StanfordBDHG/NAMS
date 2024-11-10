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
    }


    func testNearbyDevicesAndDetails() {
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--inject-default-patient"]
        app.launch()

        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Schedule"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Schedule"].tap()

        XCTAssertTrue(app.navigationBars.buttons["Nearby Devices"].waitForExistence(timeout: 0.5))
        XCTAssertFalse(app.navigationBars.buttons["EEG Recording"].waitForExistence(timeout: 0.5))


        // open nearby devices sheet
        app.navigationBars.buttons["Nearby Devices"].tap()

        XCTAssertTrue(app.navigationBars.staticTexts["Nearby Devices"].waitForExistence(timeout: 2.0))

        // we don't check for the existence of the progress view as we probably cannot time that precisely

        XCTAssertTrue(app.staticTexts["Mock Device 1"].waitForExistence(timeout: 5.0))
        app.staticTexts["Mock Device 1"].tap()


        XCTAssertTrue(app.staticTexts["Mock Device 1, Connected"].waitForExistence(timeout: 5.0))
        XCTAssertTrue(app.staticTexts["Mock Device 2"].waitForExistence(timeout: 0.5)) // ensure not connected

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

        XCTAssertTrue(app.staticTexts["Mock Device 1"].waitForExistence(timeout: 5.0)) // ensure not connected
    }

    func testSuccessfulEEGRecording() {
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--inject-default-patient"]
        app.launch()

        app.prepareAndStartRecording()

        XCTAssertTrue(app.staticTexts["In Progress"].waitForExistence(timeout: 4.0))
        XCTAssertTrue(app.staticTexts["Recording Finished"].waitForExistence(timeout: 20))
        XCTAssertTrue(app.staticTexts["Completed"].waitForExistence(timeout: 4))

        XCTAssertTrue(app.navigationBars.buttons["Done"].exists)
        app.navigationBars.buttons["Done"].tap()

        XCTAssertTrue(app.staticTexts["Brain activity was collected for this patient."].waitForExistence(timeout: 4.0))
        XCTAssertTrue(app.staticTexts["Completed"].waitForExistence(timeout: 0.5))
    }

    func testRecordingCancellation() {
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--inject-default-patient"]
        app.launch()

        app.prepareAndStartRecording()

        XCTAssertTrue(app.staticTexts["In Progress"].waitForExistence(timeout: 4.0))
        XCTAssertTrue(app.buttons["Cancel"].exists)

        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.staticTexts["Do you want to cancel the ongoing recording?"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.buttons["Cancel Recording"].exists)
        XCTAssertTrue(app.buttons["Continue Recording"].exists)

        app.buttons["Cancel Recording"].tap()
        XCTAssertTrue(app.buttons["Start Recording"].waitForExistence(timeout: 0.5))
    }

    func testChartLayoutView() {
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--inject-default-patient"]
        app.deleteAndLaunch(withSpringboardAppName: "NeuroNest")

        app.prepareAndStartRecording()

        XCTAssertTrue(app.staticTexts["In Progress"].waitForExistence(timeout: 4.0))
        XCTAssertTrue(app.navigationBars.buttons["More"].exists)
        app.navigationBars.buttons["More"].tap()

        XCTAssertTrue(app.buttons["Edit Chart Layout"].waitForExistence(timeout: 0.5))
        app.buttons["Edit Chart Layout"].tap()

        XCTAssertTrue(app.navigationBars.staticTexts["Chart Layout"].waitForExistence(timeout: 2.0))

        XCTAssertTrue(app.steppers["Display Interval, 7.0s"].exists)
        XCTAssertTrue(app.steppers["Value Interval, 6000uV"].exists)

        app.steppers["Display Interval, 7.0s"].firstMatch.buttons["Decrement"].tap()
        XCTAssertTrue(app.steppers["Display Interval, 6.5s"].waitForExistence(timeout: 0.5))
        app.steppers["Display Interval, 6.5s"].firstMatch.buttons["Increment"].tap()
        XCTAssertTrue(app.steppers["Display Interval, 7.0s"].waitForExistence(timeout: 0.5))
        app.steppers["Display Interval, 7.0s"].firstMatch.buttons["Increment"].tap()
        XCTAssertTrue(app.steppers["Display Interval, 7.5s"].waitForExistence(timeout: 0.5))
        app.steppers["Display Interval, 7.5s"].firstMatch.buttons["Decrement"].tap()
        XCTAssertTrue(app.steppers["Display Interval, 7.0s"].waitForExistence(timeout: 0.5))

        app.steppers["Value Interval, 6000uV"].firstMatch.buttons["Decrement"].tap()
        XCTAssertTrue(app.steppers["Value Interval, 5000uV"].waitForExistence(timeout: 0.5))
        app.steppers["Value Interval, 5000uV"].firstMatch.buttons["Decrement"].tap()
        XCTAssertTrue(app.steppers["Value Interval, 4500uV"].waitForExistence(timeout: 0.5))
        app.steppers["Value Interval, 4500uV"].firstMatch.buttons["Increment"].tap()
        XCTAssertTrue(app.steppers["Value Interval, 5000uV"].waitForExistence(timeout: 0.5))
        app.steppers["Value Interval, 5000uV"].firstMatch.buttons["Increment"].tap()
        XCTAssertTrue(app.steppers["Value Interval, 6000uV"].waitForExistence(timeout: 0.5))
        app.steppers["Value Interval, 6000uV"].firstMatch.buttons["Increment"].tap()
        XCTAssertTrue(app.steppers["Value Interval, 7000uV"].waitForExistence(timeout: 0.5))
    }
}


extension XCUIApplication {
    fileprivate func prepareAndStartRecording() {
        XCTAssertTrue(tabBars["Tab Bar"].buttons["Schedule"].waitForExistence(timeout: 2))
        tabBars["Tab Bar"].buttons["Schedule"].tap()

        XCTAssertTrue(buttons["Example Patient"].waitForExistence(timeout: 4.0))

        XCTAssertTrue(staticTexts["MEASUREMENTS"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(staticTexts["EEG Recording"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(
            staticTexts["No EEG Headband connected. You must connect to a nearby EEG device first inorder to perform an EEG."]
                .waitForExistence(timeout: 0.5)
        )
        XCTAssertTrue(buttons["Start Recording"].waitForExistence(timeout: 0.5))
        XCTAssertFalse(buttons["Start Recording"].isEnabled)

        // open nearby devices sheet
        XCTAssertTrue(navigationBars.buttons["Nearby Devices"].waitForExistence(timeout: 6))
        navigationBars.buttons["Nearby Devices"].tap()

        XCTAssertTrue(navigationBars.staticTexts["Nearby Devices"].waitForExistence(timeout: 2.0))

        XCTAssertTrue(staticTexts["Mock Device 1"].waitForExistence(timeout: 5.0))
        staticTexts["Mock Device 1"].tap()
        XCTAssertTrue(staticTexts["Mock Device 1, Connected"].waitForExistence(timeout: 5.0))

        XCTAssertTrue(navigationBars.buttons["Close"].waitForExistence(timeout: 0.5))
        navigationBars.buttons["Close"].tap()

        XCTAssertTrue(buttons["Start Recording"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(buttons["Start Recording"].isEnabled)
        buttons["Start Recording"].tap()

        XCTAssertTrue(scrollViews.buttons["Start Recording"].waitForExistence(timeout: 2.0))
        scrollViews.buttons["Start Recording"].tap()
    }
}
