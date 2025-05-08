import Foundation

protocol CountriesParserProtocol {
    func parse(_ data: Data?) -> Result<[Country]?, Error>
}

class CountriesParser: CountriesParserProtocol {
    func parse(_ data: Data?) -> Result<[Country]?, Error> {
        guard let data = data else { return .success(nil) }
        
        do {
            let countries = try JSONDecoder().decode([Country].self, from: data)
            return .success(countries)
        } catch {
            return .failure(CountriesParserError.decodingFailure)
        }
    }
}

enum CountriesParserError: Error {
    case decodingFailure
}
