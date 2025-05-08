//
//  CountriesViewController.swift
//  CountriesChallenge
//

import Combine
import UIKit

class CountriesViewController: UIViewController {
    private let viewModel: CountriesViewModel
    
    // MARK: - UI Elements
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.attributedTitle = NSAttributedString(string: "Pull to refresh")
        control.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        control.accessibilityIdentifier = "refreshControl"
        return control
    }()

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "countriesTableView"
        view.dataSource = self
        view.delegate = self
        view.addSubview(refreshControl)
        return view
    }()

    private lazy var searchController: UISearchController = {
        let controller = UISearchController()
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.autocapitalizationType = .none
        controller.searchBar.accessibilityIdentifier = "countriesSearchBar"
        navigationItem.searchController = controller
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        return controller
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "loadingIndicator"
        return view
    }()

    // MARK: - Data Properties
    private var isSearchBarEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }

    private var isFiltering: Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }

    private var countries: [Country] {
        isFiltering ? filteredCountries : viewModel.countriesSubject.value
    }

    private var filteredCountries: [Country] = []
    private var tasks = Set<AnyCancellable>()

    // MARK: - Initialization
    init(viewModel: CountriesViewModel = CountriesViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupViewController()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        activityIndicator.startAnimating()
        setupSubscribers()
        viewModel.refreshCountries()
    }

    // MARK: - Setup
    private func setupViewController() {
        title = "Countries"
        tableView.register(CountryCell.self, forCellReuseIdentifier: CountryCell.identifier)
        searchController.hidesNavigationBarDuringPresentation = true
        setupViews()
    }

    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            activityIndicator.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            activityIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Actions
    @objc private func refresh(_ sender: AnyObject) {
        viewModel.refreshCountries()
    }

    // MARK: - Data Binding
    private func setupSubscribers() {
        viewModel.countriesSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] countries in
                self?.activityIndicator.stopAnimating()
                self?.refreshControl.endRefreshing()
                self?.tableView.reloadData()
            }
            .store(in: &tasks)

        viewModel.errorSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self, let error = error else { return }
                self.showErrorAlert(error: error)
            }
            .store(in: &tasks)
    }

    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.activityIndicator.startAnimating()
            self?.viewModel.refreshCountries()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - TableView DataSource & Delegate
extension CountriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CountryCell.identifier,
            for: indexPath
        ) as? CountryCell else {
            return UITableViewCell()
        }
        
        let country = countries[indexPath.row]
        cell.configure(country: country)
        return cell
    }
}

extension CountriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let country = countries[indexPath.row]
        let detailVC = CountryDetailViewController(country: country)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Search Controller
extension CountriesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        
        filteredCountries = viewModel.countriesSubject.value.filter { country in
            isSearchBarEmpty ||
            country.name.lowercased().contains(searchText) ||
            country.capital.lowercased().contains(searchText)
        }
        
        tableView.reloadData()
    }
}

// MARK: - Test Helpers
#if DEBUG
extension CountriesViewController {
    var isActivityIndicatorAnimating: Bool {
        activityIndicator.isAnimating
    }
    
    var visibleRowsCount: Int {
        tableView.numberOfRows(inSection: 0)
    }
    
    func performSearch(with text: String) {
        searchController.searchBar.text = text
        updateSearchResults(for: searchController)
    }
    
    func cellForRow(at index: Int) -> CountryCell? {
        let indexPath = IndexPath(row: index, section: 0)
        return tableView.dataSource?.tableView(tableView, cellForRowAt: indexPath) as? CountryCell
    }
    
    func simulatePullToRefresh() {
        refreshControl.sendActions(for: .valueChanged)
    }
}
#endif
