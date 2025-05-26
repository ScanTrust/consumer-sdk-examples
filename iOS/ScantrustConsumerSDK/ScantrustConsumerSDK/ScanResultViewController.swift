import UIKit
import Foundation

protocol ScanResultViewControllerDelegate: AnyObject {
    func scanResultViewControllerDidDismiss()
}

class ScanResultViewController: UIViewController {

    weak var delegate: ScanResultViewControllerDelegate?

    private let uid: String
    private let apiKey: String

    // API Response
    var scanResult: ScanResultResponse? {
        didSet {
            updateScanInfoUI()
        }
    }

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Scan Results"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scanInfoCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let scanInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(uid: String, apiKey: String) {
        self.uid = uid
        self.apiKey = apiKey
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGroupedBackground
        setupUI()
        fetchScanResults()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(scanInfoCardView)
        scanInfoCardView.addSubview(scanInfoStackView)
        view.addSubview(backButton)
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: backButton.topAnchor, constant: -20),
            
            // ContentView constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Card view constraints
            scanInfoCardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            scanInfoCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            scanInfoCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            scanInfoCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Stack view constraints
            scanInfoStackView.topAnchor.constraint(equalTo: scanInfoCardView.topAnchor, constant: 20),
            scanInfoStackView.leadingAnchor.constraint(equalTo: scanInfoCardView.leadingAnchor, constant: 20),
            scanInfoStackView.trailingAnchor.constraint(equalTo: scanInfoCardView.trailingAnchor, constant: -20),
            scanInfoStackView.bottomAnchor.constraint(equalTo: scanInfoCardView.bottomAnchor, constant: -20),
            
            // Back button constraints
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            backButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func updateScanInfoUI() {
        // Clear existing views
        scanInfoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let scanResult = scanResult else {
            let noDataLabel = createInfoLabel(title: "No scan info available", value: "", isError: true)
            scanInfoStackView.addArrangedSubview(noDataLabel)
            return
        }
        
        let scan = scanResult.scan
        
        // Add scan info rows
        scanInfoStackView.addArrangedSubview(createInfoRow(title: "App", value: scan.app))
        scanInfoStackView.addArrangedSubview(createSeparatorView())
        
        scanInfoStackView.addArrangedSubview(createInfoRow(title: "Reason", value: scan.reason))
        scanInfoStackView.addArrangedSubview(createSeparatorView())
        
        scanInfoStackView.addArrangedSubview(createInfoRow(title: "Result", value: scan.result))
        scanInfoStackView.addArrangedSubview(createSeparatorView())
        
        scanInfoStackView.addArrangedSubview(createInfoRow(title: "Auth Failure Mode", value: scan.authFailureMode))
        scanInfoStackView.addArrangedSubview(createSeparatorView())
        
        scanInfoStackView.addArrangedSubview(createInfoRow(title: "Country", value: scan.country))
    }
    
    private func createInfoRow(title: String, value: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = UIColor.secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 16)
        valueLabel.textColor = UIColor.label
        valueLabel.numberOfLines = 0
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func createSeparatorView() -> UIView {
        let separator = UIView()
        separator.backgroundColor = UIColor.separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    private func createInfoLabel(title: String, value: String, isError: Bool = false) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = isError ? UIColor.systemRed : UIColor.label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func fetchScanResults() {
        let urlString = "https://api.scantrust.com/api/v2/consumer/scan/\(uid)/combined-info/"

        guard let url = URL(string: urlString) else {
            return
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey.removingPercentEncoding ?? apiKey, forHTTPHeaderField: "X-ScanTrust-Consumer-Api-Key")
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    return
                }

                switch httpResponse.statusCode {
                case 200:
                    guard let data = data else {
                        return
                    }

                    do {
                        let result = try JSONDecoder().decode(ScanResultResponse.self, from: data)
                        self?.scanResult = result
                    } catch {
                        // handle error
                    }

                default:
                    // handle other status codes
                    break
                }
            }
        }.resume()
    }

    @objc private func backButtonTapped() {
        delegate?.scanResultViewControllerDidDismiss()
        dismiss(animated: true)
    }

    @objc private func retryButtonTapped() {
        fetchScanResults()
    }
}
