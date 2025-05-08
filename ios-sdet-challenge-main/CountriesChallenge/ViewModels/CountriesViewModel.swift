//
//  CountriesViewModel.swift
//  CountriesChallenge
//

import Combine
import Foundation

class CountriesViewModel {
    private let service: CountriesServiceProtocol
    
    // Default parameter for production use
    init(service: CountriesServiceProtocol = CountriesService()) {
        self.service = service
    }
    
    // Existing properties and methods remain unchanged
    private(set) var countriesSubject = CurrentValueSubject<[Country], Never>([])
    private(set) var errorSubject = CurrentValueSubject<Error?, Never>(nil)
    
    func refreshCountries() {
        Task { [weak self] in
            do {
                let countries = try await service.fetchCountries()
                DispatchQueue.main.async {
                    self?.countriesSubject.send(countries)
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorSubject.send(error)
                }
            }
        }
    }
}
