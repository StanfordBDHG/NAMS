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

        XCTAssertTrue(app.staticTexts["Start Questionnaire"].waitForExistence(timeout: 2))
        app.staticTexts["Start Questionnaire"].tap()

        XCTAssertTrue(app.staticTexts["M-CHAT R/F"].waitForExistence(timeout: 2))

        // TODO: navigate the questionnaire with all yes
        // TODO: assert completion!

        // TODO switch patients and check if mark goes away?
    }
}
