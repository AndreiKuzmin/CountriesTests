//
//  CountryDetailViewController.swift
//  CountriesChallenge
//

import UIKit

class CountryDetailViewController: UIViewController {
    private let country: Country
    
    // MARK: - Constants
    private enum Constants {
        static let insets = UIEdgeInsets(top: 8, left: 16, bottom: -8, right: -16)
        static let spacing: CGFloat = 8
    }
    
    // MARK: - UI Elements
    private lazy var mainStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = Constants.spacing
        view.distribution = .fillEqually
        view.accessibilityIdentifier = "detailMainStackView"
        return view
    }()
    
    private lazy var firstLineStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = Constants.spacing
        view.distribution = .fillProportionally
        view.accessibilityIdentifier = "detailFirstLineStack"
        return view
    }()
    
    private lazy var secondLineStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = Constants.spacing
        view.distribution = .fillProportionally
        view.accessibilityIdentifier = "detailSecondLineStack"
        return view
    }()
    
    private lazy var nameAndRegionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .preferredFont(forTextStyle: .body)
        view.numberOfLines = 0
        view.accessibilityIdentifier = "detailNameAndRegionLabel"
        return view
    }()
    
    private lazy var codeLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .right
        view.font = .preferredFont(forTextStyle: .body)
        view.accessibilityIdentifier = "detailCodeLabel"
        return view
    }()
    
    private lazy var capitalLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .preferredFont(forTextStyle: .body)
        view.numberOfLines = 0
        view.accessibilityIdentifier = "detailCapitalLabel"
        return view
    }()
    
    // MARK: - Initialization
    init(country: Country) {
        self.country = country
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
    }
    
    // MARK: - Setup
    private func setupViewController() {
        title = country.name
        setupViews()
        configureViews()
    }
    
    private func setupViews() {
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(firstLineStack)
        mainStackView.addArrangedSubview(secondLineStack)
        
        firstLineStack.addArrangedSubview(nameAndRegionLabel)
        firstLineStack.addArrangedSubview(codeLabel)
        secondLineStack.addArrangedSubview(capitalLabel)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: Constants.insets.left
            ),
            mainStackView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Constants.insets.top
            ),
            mainStackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: Constants.insets.right
            )
        ])
    }
    
    private func configureViews() {
        nameAndRegionLabel.text = "\(country.name), \(country.region)"
        codeLabel.text = country.code
        capitalLabel.text = country.capital
        
        // Set accessibility values
        nameAndRegionLabel.accessibilityValue = nameAndRegionLabel.text
        codeLabel.accessibilityValue = codeLabel.text
        capitalLabel.accessibilityValue = capitalLabel.text
    }
}

// MARK: - Test Helpers
#if DEBUG
extension CountryDetailViewController {
    var nameAndRegionText: String? {
        nameAndRegionLabel.text
    }
    
    var codeText: String? {
        codeLabel.text
    }
    
    var capitalText: String? {
        capitalLabel.text
    }
    
    func simulateViewAppearance() {
        loadViewIfNeeded()
    }
}
#endif
