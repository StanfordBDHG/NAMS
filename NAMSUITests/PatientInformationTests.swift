//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class PatientInformationTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--inject-default-patient"]
        app.launch()
    }

    func testPatientSelection() {
        let app = XCUIApplication()

        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Schedule"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Schedule"].tap()


        XCTAssertTrue(app.buttons["Example Patient"].waitForExistence(timeout: 2.0))
        app.buttons["Example Patient"].tap()

        XCTAssertTrue(app.navigationBars["Patients"].waitForExistence(timeout: 6.0))

        XCTAssertTrue(app.buttons["Selected Patient: Example Patient"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.buttons["Example Patient, Selected"].waitForExistence(timeout: 0.5))

        app.buttons["Example Patient, Selected"].tap()

        XCTAssertTrue(app.staticTexts["No Patient selected"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.navigationBars.buttons["Select Patient"].waitForExistence(timeout: 2.0))
        app.navigationBars.buttons["Select Patient"].tap()

        XCTAssertTrue(app.navigationBars["Patients"].waitForExistence(timeout: 6.0))

        XCTAssertTrue(app.buttons["Example Patient"].waitForExistence(timeout: 0.5))
        app.buttons["Example Patient"].tap()

        XCTAssertTrue(app.buttons["Example Patient"].waitForExistence(timeout: 0.5))
    }

    func testPatientInformationDetails() {
        let app = XCUIApplication()

        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Schedule"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Schedule"].tap()


        XCTAssertTrue(app.buttons["Example Patient"].waitForExistence(timeout: 2.0))
        app.buttons["Example Patient"].tap()

        XCTAssertTrue(app.navigationBars["Patients"].waitForExistence(timeout: 6.0))

        XCTAssertTrue(app.buttons["Selected Patient: Example Patient"].waitForExistence(timeout: 0.5))
        app.buttons["Selected Patient: Example Patient"].tap()

        XCTAssertTrue(app.navigationBars.staticTexts["Patient Overview"].waitForExistence(timeout: 6.0))
        XCTAssertTrue(app.staticTexts["Example Patient"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.buttons["Delete Patient"].waitForExistence(timeout: 0.5))
        XCTAssertFalse(app.buttons["Select Patient"].waitForExistence(timeout: 0.5))

        // back button
        XCTAssertTrue(app.navigationBars.buttons["Patients"].waitForExistence(timeout: 0.5))
        app.navigationBars.buttons["Patients"].tap()


        XCTAssertTrue(app.buttons["Example Patient, Selected"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.buttons["Example Patient, Patient Details"].waitForExistence(timeout: 0.5))
        app.buttons["Example Patient, Patient Details"].tap()

        XCTAssertTrue(app.navigationBars.staticTexts["Patient Overview"].waitForExistence(timeout: 6.0))
        XCTAssertTrue(app.staticTexts["Example Patient"].waitForExistence(timeout: 0.5))

        // back button
        XCTAssertTrue(app.navigationBars.buttons["Patients"].waitForExistence(timeout: 0.5))
        app.navigationBars.buttons["Patients"].tap()

        XCTAssertTrue(app.navigationBars.staticTexts["Patients"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.navigationBars.buttons["Close"].waitForExistence(timeout: 0.5))
        app.navigationBars.buttons["Close"].tap()
    }

    func testAddPatients() throws {
        let app = XCUIApplication()

        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Schedule"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Schedule"].tap()


        XCTAssertTrue(app.buttons["Example Patient"].waitForExistence(timeout: 6.0))
        app.buttons["Example Patient"].tap()

        XCTAssertTrue(app.navigationBars["Patients"].waitForExistence(timeout: 6.0))

        XCTAssertTrue(app.navigationBars.buttons["Add Patient"].waitForExistence(timeout: 0.5))
        app.navigationBars.buttons["Add Patient"].tap()

        XCTAssertTrue(app.navigationBars.staticTexts["Add Patient"].waitForExistence(timeout: 6.0))

        XCTAssertTrue(app.textFields["enter first name"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.textFields["enter last name"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.textViews["Add Notes"].waitForExistence(timeout: 0.5))

        try app.textFields["enter first name"].enter(value: "Jane")
        try app.textFields["enter last name"].enter(value: "Stanford")
        try app.textViews["Add Notes"].enter(value: "My note ...", checkIfTextWasEnteredCorrectly: false, dismissKeyboard: false)

        XCTAssertTrue(app.navigationBars.buttons["Done"].waitForExistence(timeout: 0.5))
        app.navigationBars.buttons["Done"].tap()

        XCTAssertTrue(app.navigationBars["Patients"].waitForExistence(timeout: 6.0))

        XCTAssertTrue(app.buttons["Jane Stanford, Patient Details"].waitForExistence(timeout: 2.0))
        app.buttons["Jane Stanford, Patient Details"].tap()

        XCTAssertTrue(app.navigationBars.staticTexts["Patient Overview"].waitForExistence(timeout: 6.0))
        XCTAssertTrue(app.staticTexts["Jane Stanford"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.staticTexts["My note ..."].waitForExistence(timeout: 0.5))

        XCTAssertTrue(app.buttons["Select Patient"].waitForExistence(timeout: 0.5))
        app.buttons["Select Patient"].tap()

        XCTAssertTrue(app.buttons["Selected Patient: Jane Stanford"].waitForExistence(timeout: 0.5))
    }

    func testDeletePatient() {
        let app = XCUIApplication()

        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Schedule"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Schedule"].tap()


        XCTAssertTrue(app.buttons["Example Patient"].waitForExistence(timeout: 2.0))
        app.buttons["Example Patient"].tap()

        XCTAssertTrue(app.navigationBars["Patients"].waitForExistence(timeout: 6.0))

        XCTAssertTrue(app.buttons["Selected Patient: Example Patient"].waitForExistence(timeout: 0.5))
        app.buttons["Selected Patient: Example Patient"].tap()

        XCTAssertTrue(app.navigationBars.staticTexts["Patient Overview"].waitForExistence(timeout: 6.0))

        XCTAssertTrue(app.buttons["Delete Patient"].waitForExistence(timeout: 0.5))
        app.buttons["Delete Patient"].tap()


        XCTAssertTrue(app.staticTexts["Are you sure you want to delete this patient?"].waitForExistence(timeout: 4.0))
        XCTAssertTrue(app.buttons["Delete"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 0.5))

        app.buttons["Delete"].tap()


        XCTAssertTrue(app.navigationBars["Patients"].waitForExistence(timeout: 6.0))
        XCTAssertFalse(app.buttons["Example Patient"].waitForExistence(timeout: 0.5))
        XCTAssertFalse(app.buttons["Example Patient, Selected"].waitForExistence(timeout: 0.5))
        XCTAssertFalse(app.buttons["Selected Patient: Example Patient"].waitForExistence(timeout: 0.5))
    }
}
