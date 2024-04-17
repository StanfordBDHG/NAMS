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

        sleep(1)
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--showOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "NeuroNest")
    }
    
    
    func testOnboardingFlow() throws {
        let app = XCUIApplication()
        
        try app.navigateOnboardingFlow()
        
        app.assertOnboardingComplete()
        try app.assertAccountInformation() // ensure account is deleted again
    }

    func testOnboardingFlowRepeated() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--showOnboarding"]
        app.terminate()
        app.launch()

        try app.navigateOnboardingFlow()
        app.assertOnboardingComplete()

        app.terminate()

        // Second onboarding round shouldn't display HealthKit and Notification authorizations anymore
        app.activate()

        try app.navigateOnboardingFlow(repeated: true)
        // Do not show HealthKit and Notification authorization view again
        app.assertOnboardingComplete()
        try app.assertAccountInformation() // ensure account is deleted again
    }
}


extension XCUIApplication {
    func conductOnboardingIfNeeded() throws {
        if staticTexts["Neurodevelopment Assessment and Monitoring System (NAMS)"].waitForExistence(timeout: 5) {
            try navigateOnboardingFlow()
        }
    }
    
    fileprivate func navigateOnboardingFlow(repeated skippedIfRepeated: Bool = false) throws {
        try navigateOnboardingFlowWelcome()
        if staticTexts["Your Account"].waitForExistence(timeout: 5) {
            try navigateOnboardingAccount()
        }
        if !skippedIfRepeated {
            try navigateOnboardingFlowNotification()
        }
        try navigateFinishedSetup()
    }
    
    private func navigateOnboardingFlowWelcome() throws {
        XCTAssertTrue(staticTexts["NeuroNest"].waitForExistence(timeout: 5))

        let continueButton = buttons["Continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 2))
        continueButton.tap()
    }
    
    private func navigateOnboardingAccount() throws {
        if buttons["Logout"].waitForExistence(timeout: 2) {
            buttons["Logout"].tap()
        }

        XCTAssertTrue(staticTexts["Your Account"].waitForExistence(timeout: 5))

        XCTAssertTrue(buttons["Signup"].waitForExistence(timeout: 2))
        buttons["Signup"].tap()

        XCTAssertTrue(staticTexts["Create a new Account"].waitForExistence(timeout: 2))

        try collectionViews.textFields["E-Mail Address"].enter(value: "leland@stanford.edu")
        try collectionViews.secureTextFields["Password"].enter(value: "StanfordRocks")
        try textFields["enter first name"].enter(value: "Leland")
        try textFields["enter last name"].enter(value: "Stanford")
        try textFields["Investigator Code"].enter(value: "LS1")

        XCTAssertTrue(collectionViews.buttons["Signup"].waitForExistence(timeout: 2))
        collectionViews.buttons["Signup"].tap()

        sleep(3)

        if staticTexts["Ready To Go"].waitForExistence(timeout: 5) && navigationBars.buttons["Back"].waitForExistence(timeout: 5) {
            navigationBars.buttons["Back"].tap()

            XCTAssertTrue(staticTexts["Leland Stanford"].waitForExistence(timeout: 2))
            XCTAssertTrue(staticTexts["leland@stanford.edu"].waitForExistence(timeout: 2))

            XCTAssertTrue(buttons["Continue"].waitForExistence(timeout: 2))
            buttons["Continue"].tap()
        }
    }

    private func navigateOnboardingFlowNotification() throws {
        XCTAssertTrue(staticTexts["Notifications"].waitForExistence(timeout: 5))

        XCTAssertTrue(buttons["Continue"].waitForExistence(timeout: 2))
        buttons["Continue"].tap()

        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let alertAllowButton = springboard.buttons["Allow"]
        if alertAllowButton.waitForExistence(timeout: 5) {
            alertAllowButton.tap()
        }
    }

    private func navigateFinishedSetup() throws {
        XCTAssertTrue(staticTexts["Ready To Go"].waitForExistence(timeout: 2))

        let startButton = buttons["Start"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 2))
        startButton.tap()
    }

    fileprivate func assertOnboardingComplete() {
        let tabBar = tabBars["Tab Bar"]
        XCTAssertTrue(tabBar.buttons["Schedule"].waitForExistence(timeout: 2))
        XCTAssertTrue(tabBar.buttons["Contacts"].waitForExistence(timeout: 2))
    }

    fileprivate func assertAccountInformation() throws {
        XCTAssertTrue(navigationBars.buttons["Your Account"].waitForExistence(timeout: 2))
        navigationBars.buttons["Your Account"].tap()

        XCTAssertTrue(staticTexts["Account Overview"].waitForExistence(timeout: 5.0))
        XCTAssertTrue(staticTexts["Leland Stanford"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(staticTexts["leland@stanford.edu"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(staticTexts["Investigator Code, LS1"].waitForExistence(timeout: 0.5))


        XCTAssertTrue(navigationBars.buttons["Close"].waitForExistence(timeout: 0.5))
        navigationBars.buttons["Close"].tap()

        XCTAssertTrue(navigationBars.buttons["Your Account"].waitForExistence(timeout: 2))
        navigationBars.buttons["Your Account"].tap()

        XCTAssertTrue(navigationBars.buttons["Edit"].waitForExistence(timeout: 2))
        navigationBars.buttons["Edit"].tap()

        usleep(500_00)
        XCTAssertFalse(navigationBars.buttons["Close"].exists)

        XCTAssertTrue(buttons["Delete Account"].waitForExistence(timeout: 2))
        buttons["Delete Account"].tap()

        let alert = "Are you sure you want to delete your account?"
        XCTAssertTrue(alerts[alert].waitForExistence(timeout: 6.0))
        alerts[alert].buttons["Delete"].tap()

        XCTAssertTrue(alerts["Authentication Required"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(alerts["Authentication Required"].secureTextFields["Password"].waitForExistence(timeout: 0.5))
        typeText("StanfordRocks") // the password field has focus already
        XCTAssertTrue(alerts["Authentication Required"].buttons["Login"].waitForExistence(timeout: 0.5))
        alerts["Authentication Required"].buttons["Login"].tap()

        sleep(2)

        // Login
        try textFields["E-Mail Address"].enter(value: "leland@stanford.edu")
        try secureTextFields["Password"].enter(value: "StanfordRocks")

        XCTAssertTrue(buttons["Login"].waitForExistence(timeout: 0.5))
        buttons["Login"].tap()

        XCTAssertTrue(alerts["Invalid Credentials"].waitForExistence(timeout: 2.0))
    }
}
