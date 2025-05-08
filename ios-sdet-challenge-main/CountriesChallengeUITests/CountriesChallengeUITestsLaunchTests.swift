//
//  CountriesChallengeUITestsLaunchTests.swift
//  CountriesChallengeUITests
//

import XCTest

class CountriesChallengeUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Basic Launch Tests
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testLaunchScreenAppearance() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Verify launch screen elements
        XCTAssertTrue(app.staticTexts["Countries"].exists)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    // MARK: - Configuration-Based Launch Tests
    
    func testLaunchWithEmptyState() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--mockEmptyResponse")
        app.launch()
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch With Empty State"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testLaunchWithErrorState() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--mockFailure")
        app.launch()
        
        // Verify error state appears
        XCTAssertTrue(app.alerts["Error"].waitForExistence(timeout: 5))
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch With Error State"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testLaunchWithDarkMode() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launchArguments.append("-UIUserInterfaceStyleDark")
        app.launch()
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch With Dark Mode"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testLaunchWithLargeText() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-UITestDynamicTypeSizes")
        app.launchArguments.append("UICTContentSizeCategoryAccessibilityXL")
        app.launch()
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch With Large Text"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    // MARK: - Orientation Tests
    
    func testLaunchInPortrait() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCUIDevice.shared.orientation = .portrait
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Portrait Orientation"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testLaunchInLandscape() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCUIDevice.shared.orientation = .landscapeLeft
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Landscape Orientation"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    // MARK: - Localization Tests
    
    func testLaunchWithEnglishLocale() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-AppleLocale")
        app.launchArguments.append("en_US")
        app.launch()
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "English Localization"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testLaunchWithGermanLocale() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-AppleLocale")
        app.launchArguments.append("de_DE")
        app.launch()
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "German Localization"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
