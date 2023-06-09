//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions

class OnboardingTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        try disablePasswordAutofill()
        
        sleep(1)
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--showOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "NAMS")
    }
    
    
    func testOnboardingFlow() throws {
        let app = XCUIApplication()
        
        try app.navigateOnboardingFlow()
        
        let tabBar = app.tabBars["Tab Bar"]
        XCTAssertTrue(tabBar.buttons["Schedule"].waitForExistence(timeout: 2))
        XCTAssertTrue(tabBar.buttons["Contacts"].waitForExistence(timeout: 2))
        XCTAssertTrue(tabBar.buttons["Mock Upload"].waitForExistence(timeout: 2))
    }
}


extension XCUIApplication {
    func conductOnboardingIfNeeded() throws {
        if self.staticTexts["Neurodevelopment Assessment and Monitoring System (NAMS)"].waitForExistence(timeout: 5) {
            try navigateOnboardingFlow()
        }
    }
    
    func navigateOnboardingFlow() throws {
        try navigateOnboardingFlowWelcome()
        try navigateOnboardingAccount()
        try navigateFinishedSetup()
    }
    
    private func navigateOnboardingFlowWelcome() throws {
        XCTAssertTrue(staticTexts["Neurodevelopment Assessment and Monitoring System (NAMS)"].waitForExistence(timeout: 2))

        let continueButton = buttons["Continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 2))
        continueButton.tap()
    }
    
    private func navigateOnboardingAccount() throws {
        XCTAssertTrue(staticTexts["Your Account"].waitForExistence(timeout: 2))

        if buttons["Continue"].waitForExistence(timeout: 5) {
            let logoutButton = buttons["Logout"]
            XCTAssertTrue(logoutButton.waitForExistence(timeout: 2))
            logoutButton.tap()

            XCTAssertTrue(staticTexts["Your Account"].waitForExistence(timeout: 2))
        }
        
        try testOnboardingWithoutAccount()
    }

    func testOnboardingWithoutAccount() throws {
        XCTAssertTrue(staticTexts["Your Account"].waitForExistence(timeout: 2))

        XCTAssertTrue(buttons["Sign Up"].waitForExistence(timeout: 2))
        buttons["Sign Up"].tap()

        XCTAssertTrue(navigationBars.staticTexts["Sign Up"].waitForExistence(timeout: 2))
        XCTAssertTrue(images["App Icon"].waitForExistence(timeout: 2))
        XCTAssertTrue(buttons["Email and Password"].waitForExistence(timeout: 2))

        buttons["Email and Password"].tap()

        try textFields["Enter your email ..."].enter(value: "leland@stanford.edu")
        swipeUp()

        secureTextFields["Enter your password ..."].tap()
        secureTextFields["Enter your password ..."].typeText("StanfordRocks")
        swipeUp()
        secureTextFields["Repeat your password ..."].tap()
        secureTextFields["Repeat your password ..."].typeText("StanfordRocks")
        swipeUp()

        try textFields["Enter your first name ..."].enter(value: "Leland")
        staticTexts["Repeat\nPassword"].swipeUp()

        try textFields["Enter your last name ..."].enter(value: "Stanford")
        staticTexts["Repeat\nPassword"].swipeUp()

        collectionViews.buttons["Sign Up"].tap()

        sleep(3)

        if staticTexts["Ready To Go"].waitForExistence(timeout: 5) && navigationBars.buttons["Back"].waitForExistence(timeout: 5) {
            navigationBars.buttons["Back"].tap()

            XCTAssertTrue(staticTexts["Leland Stanford"].waitForExistence(timeout: 2))
            XCTAssertTrue(staticTexts["leland@stanford.edu"].waitForExistence(timeout: 2))
            XCTAssertTrue(scrollViews.otherElements.buttons["Continue"].waitForExistence(timeout: 2))
            scrollViews.otherElements.buttons["Continue"].tap()
        }
    }

    private func navigateFinishedSetup() throws {
        XCTAssertTrue(staticTexts["Ready To Go"].waitForExistence(timeout: 2))

        let startButton = buttons["Start"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 2))
        startButton.tap()
    }
}
