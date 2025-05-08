//
//  CountriesService.swift
//  CountriesChallenge
//

import Foundation

enum CountriesServiceError: Error {
    case failure(Error)
    case invalidUrl(String)
    case invalidData
    case decodingFailure
    case emptyResponse
    
    var localizedDescription: String {
        switch self {
        case .failure(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidUrl(let url):
            return "Invalid URL: \(url)"
        case .invalidData:
            return "Received invalid data"
        case .decodingFailure:
            return "Failed to decode response"
        case .emptyResponse:
            return "Received empty response"
        }
    }
}

protocol CountriesServiceProtocol {
    func fetchCountries() async throws -> [Country]
}

protocol CountriesServiceRequestDelegate: AnyObject {
    func didUpdate(error: Error?)
}

class CountriesService: CountriesServiceProtocol {
    private let urlString: String
    private let urlSession: URLSessionProtocol
    private let parser: CountriesParserProtocol
    
    init(
        urlString: String = "https://gist.githubusercontent.com/peymano-wmt/32dcb892b06648910ddd40406e37fdab/raw/db25946fd77c5873b0303b858e861ce724e0dcd0/countries.json",
        urlSession: URLSessionProtocol = URLSession.shared,
        parser: CountriesParserProtocol = CountriesParser()
    ) {
        self.urlString = urlString
        self.urlSession = urlSession
        self.parser = parser
    }
    
    func fetchCountries() async throws -> [Country] {
        guard let url = URL(string: urlString) else {
            throw CountriesServiceError.invalidUrl(urlString)
        }
        
        // Support for UI testing with mock responses
        if ProcessInfo.processInfo.arguments.contains("-mockEmptyResponse") {
            return []
        }
        
        if ProcessInfo.processInfo.arguments.contains("-mockFailure") {
            throw CountriesServiceError.invalidData
        }
        
        do {
            let (data, _) = try await urlSession.data(from: url)
            
            // For testing empty data scenarios
            if ProcessInfo.processInfo.arguments.contains("-mockEmptyData") {
                throw CountriesServiceError.emptyResponse
            }
            
            let result = parser.parse(data)
            
            switch result {
            case .success(let countries):
                return countries ?? []
            case .failure(let error):
                throw error
            }
        } catch {
            // Convert any URLSession errors to our service error type
            throw CountriesServiceError.failure(error)
        }
    }
}

// MARK: - URLSession Abstraction for Testing
protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

// MARK: - Test Helpers
#if DEBUG
class MockCountriesParser: CountriesParserProtocol {
    var mockResult: Result<[Country]?, Error> = .success([])
    
    func parse(_ data: Data?) -> Result<[Country]?, Error> {
        return mockResult
    }
}

extension CountriesService {
    static func mockService(with countries: [Country]) -> CountriesService {
        let mockParser = MockCountriesParser()
        mockParser.mockResult = .success(countries)
        return CountriesService(
            urlString: "https://mock.url",
            urlSession: MockURLSession(),
            parser: mockParser
        )
    }
    
    static func failingService(error: Error) -> CountriesService {
        let mockParser = MockCountriesParser()
        mockParser.mockResult = .failure(error)
        return CountriesService(
            urlString: "https://mock.url",
            urlSession: MockURLSession(),
            parser: mockParser
        )
    }
}

class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockError: Error?
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let mockError = mockError {
            throw mockError
        }
        
        guard let mockData = mockData else {
            throw CountriesServiceError.invalidData
        }
        
        return (mockData, URLResponse())
    }
}
#endif
