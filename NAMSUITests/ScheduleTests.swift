//
// This source file is part of the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


class ScheduleTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--testSchedule", "--inject-default-patient"]
        app.deleteAndLaunch(withSpringboardAppName: "NAMS")
    }


    func testSchedule() throws {
        let app = XCUIApplication()

        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Schedule"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Schedule"].tap()

        XCTAssertTrue(app.staticTexts["SCREENING"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["M-CHAT R/F"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.staticTexts["Questionnaire, 5-10 min"].waitForExistence(timeout: 0.5))

        XCTAssertTrue(app.buttons["Start Questionnaire"].waitForExistence(timeout: 0.5))
        app.buttons["Start Questionnaire"].tap()

        XCTAssertTrue(app.navigationBars.buttons["Cancel"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["M-CHAT R/F"].waitForExistence(timeout: 0.5))

        while true {
            if app.staticTexts["Yes"].exists {
                app.staticTexts["Yes"].tap()

                if app.buttons["Next"].exists {
                    app.buttons["Next"].tap()
                    usleep(500_000)
                } else if app.buttons["Done"].exists {
                    app.buttons["Done"].tap()
                    usleep(500_000)
                    break
                } else {
                    XCTFail("Couldn't navigate questionnaire!")
                }
            } else {
                XCTFail("Couldn't navigate questionnaire!")
            }
        }


        XCTAssertTrue(app.staticTexts["Completed"].waitForExistence(timeout: 2.0))
    }
}
