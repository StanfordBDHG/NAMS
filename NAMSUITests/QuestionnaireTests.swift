//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


class QuestionnaireTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--testSchedule", "--inject-default-patient"]
        app.deleteAndLaunch(withSpringboardAppName: "NAMS")
    }


    func testMCHAT() throws {
        let app = XCUIApplication()

        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Schedule"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Schedule"].tap()

        XCTAssertTrue(app.staticTexts["SCREENING"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["M-CHAT R/F"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.staticTexts["Questionnaire, takes 5 to 10 min"].waitForExistence(timeout: 0.5))

        XCTAssertTrue(app.buttons["Start Questionnaire"].waitForExistence(timeout: 0.5))
        app.buttons["Start Questionnaire"].tap()

        XCTAssertTrue(app.navigationBars.buttons["Cancel"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["M-CHAT R/F"].waitForExistence(timeout: 0.5))

        XCTAssertTrue(app.staticTexts["Yes"].waitForExistence(timeout: 2.0))
        let yesButtons = app.staticTexts.matching(identifier: "Yes").allElementsBoundByIndex

        for button in yesButtons {
            button.tap()
            usleep(500_000)
        }

        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 2.0))
        app.buttons["Done"].tap()


        XCTAssertTrue(app.staticTexts["Completed"].waitForExistence(timeout: 2.0))
    }
}
