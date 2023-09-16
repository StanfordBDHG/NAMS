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
        
        try app.assertOnboardingComplete()
    }

    func testOnboardingFlowRepeated() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--showOnboarding"]

        try app.navigateOnboardingFlow()
        try app.assertOnboardingComplete()

        app.terminate()

        // Second onboarding round shouldn't display HealthKit and Notification authorizations anymore
        app.activate()

        try app.navigateOnboardingFlow(repeated: true)
        // Do not show HealthKit and Notification authorization view again
        try app.assertOnboardingComplete()
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
        XCTAssertTrue(staticTexts["Neurodevelopment Assessment and Monitoring System (NAMS)"].waitForExistence(timeout: 5))

        let continueButton = buttons["Continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 2))
        continueButton.tap()
    }
    
    private func navigateOnboardingAccount() throws {
        if buttons["Continue"].waitForExistence(timeout: 2) {
            buttons["Continue"].tap()
            return
        }
        
        try navigateOnboardingWithoutAccount()
    }

    func navigateOnboardingWithoutAccount() throws {
        XCTAssertTrue(staticTexts["Your Account"].waitForExistence(timeout: 5))

        XCTAssertTrue(buttons["Sign Up"].waitForExistence(timeout: 2))
        buttons["Sign Up"].tap()

        XCTAssertTrue(navigationBars.staticTexts["Sign Up"].waitForExistence(timeout: 2))

        XCTAssertTrue(buttons["Email and Password"].waitForExistence(timeout: 2))
        buttons["Email and Password"].tap()

        try textFields["Enter your email ..."].enter(value: "leland@stanford.edu")

        try secureTextFields["Enter your password ..."].enter(value: "StanfordRocks")
        try secureTextFields["Repeat your password ..."].enter(value: "StanfordRocks")

        try textFields["Enter your first name ..."].enter(value: "Leland")
        try textFields["Enter your last name ..."].enter(value: "Stanford")

        XCTAssertTrue(buttons["Sign Up"].waitForExistence(timeout: 2))
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

    fileprivate func assertOnboardingComplete() throws {
        let tabBar = tabBars["Tab Bar"]
        XCTAssertTrue(tabBar.buttons["Schedule"].waitForExistence(timeout: 2))
        XCTAssertTrue(tabBar.buttons["Contacts"].waitForExistence(timeout: 2))
    }
}
