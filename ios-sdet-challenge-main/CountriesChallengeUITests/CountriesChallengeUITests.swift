//
//  CountriesChallengeUITests.swift
//  CountriesChallengeUITests
//

import XCTest

class CountriesChallengeUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Main List Tests
    
    func testCountriesListLoads() {
        // Verify initial state
        let countriesTable = app.tables["countriesTableView"]
        XCTAssertTrue(countriesTable.waitForExistence(timeout: 5), "Countries table should exist")
        
        // Verify loading indicator disappears
        let loadingIndicator = app.activityIndicators["loadingIndicator"]
        XCTAssertFalse(loadingIndicator.exists, "Loading indicator should disappear after load")
        
        // Verify at least one cell exists
        XCTAssertGreaterThan(countriesTable.cells.count, 0, "Should display at least one country")
    }
    
    func testCountryCellDisplaysCorrectInfo() {
        let firstCell = app.tables["countriesTableView"].cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        
        // Verify cell contains name and capital
        XCTAssertTrue(firstCell.staticTexts["countryNameLabel"].exists)
        XCTAssertTrue(firstCell.staticTexts["countryCapitalLabel"].exists)
    }
    
    func testPullToRefresh() {
        let countriesTable = app.tables["countriesTableView"]
        let firstCell = countriesTable.cells.element(boundBy: 0)
        let originalName = firstCell.staticTexts["countryNameLabel"].label
        
        // Pull to refresh
        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        let finish = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
        start.press(forDuration: 0, thenDragTo: finish)
        
        // Verify same cell exists (data reloaded)
        XCTAssertTrue(firstCell.staticTexts[originalName].waitForExistence(timeout: 5))
    }
    
    // MARK: - Navigation Tests
    
    func testSelectingCountryShowsDetail() {
        let firstCell = app.tables["countriesTableView"].cells.element(boundBy: 0)
        let countryName = firstCell.staticTexts["countryNameLabel"].label
        firstCell.tap()
        
        // Verify detail screen shows
        XCTAssertTrue(app.navigationBars[countryName].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["detailCountryName"].exists)
    }
    
    func testDetailViewDisplaysCorrectInfo() {
        // Navigate to detail
        app.tables["countriesTableView"].cells.element(boundBy: 0).tap()
        
        // Verify all elements exist
        XCTAssertTrue(app.staticTexts["detailCountryName"].exists)
        XCTAssertTrue(app.staticTexts["detailCapital"].exists)
        XCTAssertTrue(app.staticTexts["detailRegion"].exists)
        XCTAssertTrue(app.staticTexts["detailCode"].exists)
    }
    
    func testBackNavigationReturnsToList() {
        // Go to detail and back
        app.tables["countriesTableView"].cells.element(boundBy: 0).tap()
        app.navigationBars.buttons["Countries"].tap()
        
        // Verify back on main list
        XCTAssertTrue(app.navigationBars["Countries"].waitForExistence(timeout: 2))
    }
    
    // MARK: - Search Tests
    
    func testSearchFiltersCountries() {
        let searchField = app.searchFields["countriesSearchBar"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        
        // Get initial count
        let initialCount = app.tables["countriesTableView"].cells.count
        
        // Search for specific country
        searchField.tap()
        searchField.typeText("Germany")
        
        // Verify results filtered
        let filteredCount = app.tables["countriesTableView"].cells.count
        XCTAssertLessThan(filteredCount, initialCount)
        
        // Verify correct country shown
        XCTAssertTrue(app.staticTexts["Germany"].exists)
    }
    
    func testSearchCancelReturnsFullList() {
        let searchField = app.searchFields["countriesSearchBar"]
        searchField.tap()
        searchField.typeText("Test")
        
        // Cancel search
        app.buttons["Cancel"].tap()
        
        // Verify full list restored
        let fullCount = app.tables["countriesTableView"].cells.count
        XCTAssertGreaterThan(fullCount, 1)
    }
    
    // MARK: - Error Handling
    
    func testErrorDisplay() {
        app.launchArguments.append("--uitesting")
        app.launchArguments.append("-mockFailure")
        app.launch()
        
        // Verify error alert appears
        XCTAssertTrue(app.alerts["Error"].waitForExistence(timeout: 5))
        
        // Test retry button
        app.alerts["Error"].buttons["Retry"].tap()
        XCTAssertFalse(app.alerts["Error"].exists)
    }
    
    // MARK: - Performance Tests
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    // MARK: - Accessibility Tests
    
    func testDynamicTypeSupport() {
        app.launchArguments.append("-UITestDynamicTypeSizes")
        app.launchArguments.append("UICTContentSizeCategoryAccessibilityXL")
        app.launch()
        
        XCTAssertTrue(app.tables["countriesTableView"].cells.element(boundBy: 0).isHittable)
    }
}
