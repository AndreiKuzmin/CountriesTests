//
//  CountriesChallengeTests.swift
//  CountriesChallengeTests
//

import XCTest
import Combine
@testable import CountriesChallenge

class CountriesChallengeTests: XCTestCase {
    
    // MARK: - Test Doubles
    
    class MockCountriesService: CountriesServiceProtocol {
        var shouldSucceed: Bool = true
        var mockCountries: [Country] = [
            Country(
                capital: "Berlin",
                code: "DE",
                currency: Currency(code: "EUR", name: "Euro", symbol: "€"),
                flag: "🇩🇪",
                language: Language(code: "de", name: "German"),
                name: "Germany",
                region: "Europe"
            )
        ]
        
        func fetchCountries() async throws -> [Country] {
            if shouldSucceed {
                return mockCountries
            } else {
                throw CountriesServiceError.invalidData
            }
        }
    }
    
    class MockCountriesParser: CountriesParserProtocol {
        var shouldSucceed: Bool = true
        
        func parse(_ data: Data?) -> Result<[Country]?, Error> {
            if shouldSucceed {
                let countries = [
                    Country(
                        capital: "Paris",
                        code: "FR",
                        currency: Currency(code: "EUR", name: "Euro", symbol: "€"),
                        flag: "🇫🇷",
                        language: Language(code: "fr", name: "French"),
                        name: "France",
                        region: "Europe"
                    )
                ]
                return .success(countries)
            } else {
                return .failure(CountriesParserError.decodingFailure)
            }
        }
    }
    
    // MARK: - Properties
    
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - ViewModel Tests
    
    func testCountriesViewModel_SuccessfulFetch() {
        // Given
        let mockService = MockCountriesService()
        let viewModel = CountriesViewModel(service: mockService)
        let expectation = XCTestExpectation(description: "Countries loaded")
        
        // When
        viewModel.countriesSubject
            .dropFirst()
            .sink { countries in
                // Then
                XCTAssertEqual(countries.count, 1)
                XCTAssertEqual(countries.first?.name, "Germany")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.refreshCountries()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCountriesViewModel_FailedFetch() {
        // Given
        let mockService = MockCountriesService()
        mockService.shouldSucceed = false
        let viewModel = CountriesViewModel(service: mockService)
        let expectation = XCTestExpectation(description: "Error received")
        
        // When
        viewModel.errorSubject
            .dropFirst()
            .sink { error in
                // Then
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.refreshCountries()
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Service Tests
    
    func testCountriesService_SuccessfulFetch() async {
        // Given
        let mockParser = MockCountriesParser()
        let service = CountriesService(parser: mockParser)
        
        do {
            // When
            let countries = try await service.fetchCountries()
            
            // Then
            XCTAssertFalse(countries.isEmpty)
        } catch {
            XCTFail("Fetch should have succeeded")
        }
    
            // Add this if testing UI updates:
            await Task.yield()
    }
    
    func testCountriesService_ParserFailure() async {
        // Given
        let mockParser = MockCountriesParser()
        mockParser.shouldSucceed = false
        let service = CountriesService(parser: mockParser)
        
        do {
            // When
            _ = try await service.fetchCountries()
            XCTFail("Fetch should have failed")
        } catch {
            // Then
            XCTAssertTrue(error is CountriesParserError)
        }
    }
    
    // MARK: - Parser Tests
    
    func testCountriesParser_Success() {
        // Given
        let parser = CountriesParser()
        let jsonData = """
        [
            {
                "capital": "Madrid",
                "code": "ES",
                "currency": {
                    "code": "EUR",
                    "name": "Euro",
                    "symbol": "€"
                },
                "flag": "🇪🇸",
                "language": {
                    "code": "es",
                    "name": "Spanish"
                },
                "name": "Spain",
                "region": "Europe"
            }
        ]
        """.data(using: .utf8)!
        
        // When
        let result = parser.parse(jsonData)
        
        // Then
        switch result {
        case .success(let countries):
            XCTAssertEqual(countries?.first?.name, "Spain")
        case .failure:
            XCTFail("Parsing should have succeeded")
        }
    }
    
    func testCountriesParser_Failure() {
        // Given
        let parser = CountriesParser()
        let invalidData = "invalid json".data(using: .utf8)!
        
        // When
        let result = parser.parse(invalidData)
        
        // Then
        switch result {
        case .success:
            XCTFail("Parsing should have failed")
        case .failure(let error):
            XCTAssertTrue(error is CountriesParserError)
        }
    }
    
    // MARK: - ViewController Tests
    
    func testCountriesViewController_InitialState() {
        // Given
        let mockService = MockCountriesService()
        let viewModel = CountriesViewModel(service: mockService)
        let vc = CountriesViewController(viewModel: viewModel)
        
        // When
        vc.loadViewIfNeeded()
        
        // Then
        XCTAssertTrue(vc.isActivityIndicatorAnimating)
        XCTAssertEqual(vc.visibleRowsCount, 0)
    }
    
    func testCountriesViewController_SuccessfulLoad() {
        // Given
        let mockService = MockCountriesService()
        let viewModel = CountriesViewModel(service: mockService)
        let vc = CountriesViewController(viewModel: viewModel)
        
        // When
        vc.loadViewIfNeeded()
        viewModel.countriesSubject.send([mockService.mockCountries.first!])
        
        // Then
        XCTAssertFalse(vc.isActivityIndicatorAnimating)
        XCTAssertEqual(vc.visibleRowsCount, 1)
    }
    
    func testCountriesViewController_CellConfiguration() {
        // Given
        let mockService = MockCountriesService()
        let viewModel = CountriesViewModel(service: mockService)
        let vc = CountriesViewController(viewModel: viewModel)
        viewModel.countriesSubject.send([mockService.mockCountries.first!])
        vc.loadViewIfNeeded()
        
        // When
        guard let cell = vc.cellForRow(at: 0) else {
            XCTFail("Cell should exist")
            return
        }
        
        // Then
        XCTAssertEqual(cell.textLabel?.text, "Germany")
        XCTAssertEqual(cell.detailTextLabel?.text, "Berlin")
    }
    
    // MARK: - CountryDetailViewController Tests
    
    func testCountryDetailViewController_Setup() {
        // Given
        let country = Country(
            capital: "Rome",
            code: "IT",
            currency: Currency(code: "EUR", name: "Euro", symbol: "€"),
            flag: "🇮🇹",
            language: Language(code: "it", name: "Italian"),
            name: "Italy",
            region: "Europe"
        )
        
        // When
        let vc = CountryDetailViewController(country: country)
        vc.loadViewIfNeeded()
        
        // Then
        XCTAssertEqual(vc.nameAndRegionText, "Italy, Europe")
        XCTAssertEqual(vc.codeText, "IT")
        XCTAssertEqual(vc.capitalText, "Rome")
    }
    
    // MARK: - Search Functionality Tests
    
    func testCountriesViewController_SearchFiltering() {
        // Given
        let mockService = MockCountriesService()
        let viewModel = CountriesViewModel(service: mockService)
        let vc = CountriesViewController(viewModel: viewModel)
        
        let testCountries = [
            Country(
                capital: "Berlin",
                code: "DE",
                currency: Currency(code: "EUR", name: "Euro", symbol: "€"),
                flag: "🇩🇪",
                language: Language(code: "de", name: "German"),
                name: "Germany",
                region: "Europe"
            ),
            Country(
                capital: "Paris",
                code: "FR",
                currency: Currency(code: "EUR", name: "Euro", symbol: "€"),
                flag: "🇫🇷",
                language: Language(code: "fr", name: "French"),
                name: "France",
                region: "Europe"
            )
        ]
        
        // When
        vc.loadViewIfNeeded()
        viewModel.countriesSubject.send(testCountries)
        vc.performSearch(with: "Ger")
        
        // Then
        XCTAssertEqual(vc.visibleRowsCount, 1)
    }
}
