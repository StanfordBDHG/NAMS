//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions
import XCTHealthKit


class HealthKitUploadTests: XCTestCase {
    override func setUpWithError() throws {
        throw XCTSkip("HelathKit Tests are currently skipped!")
        try super.setUpWithError()
        
        try disablePasswordAutofill()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--showOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "NAMS")
    }
    
    
    func testHealthKitMockUpload() throws {
        throw XCTSkip("HelathKit Tests are currently skipped!")

        let app = XCUIApplication()
        
        try app.conductOnboardingIfNeeded()
        
        try navigateToMockUpload()
        
        try assertObservationCellPresent(false)
        
        try exitAppAndOpenHealth(.steps)
        
        app.activate()
        
        sleep(5)
        
        try navigateToMockUpload()
        try assertObservationCellPresent(true, pressIfPresent: true)
        try assertObservationCellPresent(true, pressIfPresent: false)
    }
    
    
    private func navigateToMockUpload() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Mock Upload"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Mock Upload"].tap()
    }
    
    private func assertObservationCellPresent(_ shouldBePresent: Bool, pressIfPresent: Bool = true) throws {
        let app = XCUIApplication()
        
        let observationText = "/Observation/"
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", observationText)
        
        if shouldBePresent {
            XCTAssertTrue(app.staticTexts.containing(predicate).firstMatch.waitForExistence(timeout: 2))
            if pressIfPresent {
                app.staticTexts.containing(predicate).firstMatch.tap()
                XCTAssert(app.navigationBars.buttons["Mock Upload"].waitForExistence(timeout: 2))
            }
        } else {
            XCTAssertFalse(app.staticTexts.containing(predicate).firstMatch.waitForExistence(timeout: 2))
        }
    }
}
