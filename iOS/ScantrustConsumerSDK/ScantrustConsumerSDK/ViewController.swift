import UIKit
import WebKit
import AVFoundation

class ViewController: UIViewController, ScanResultViewControllerDelegate {

    private var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadURL()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkCameraPermission { _ in }
    }

    @objc private func appDidBecomeActive() {
        checkCameraPermission { _ in }
    }

    deinit {
        // Remove observer to avoid memory leaks
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    // MARK: - ScanResultViewControllerDelegate

    func scanResultViewControllerDidDismiss() {
        loadURL()
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self

        view.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadURL() {
        if let url = URL(string: "https://verify.scantrust.com/video/") {
            webView.load(URLRequest(url: url))
        }
    }
}

extension ViewController: WKUIDelegate, WKNavigationDelegate {

    func webView(
        _ webView: WKWebView,
        requestMediaCapturePermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo,
        type: WKMediaCaptureType,
        decisionHandler: @escaping @MainActor (WKPermissionDecision) -> Void
    ) {
        if type == .camera || type == .cameraAndMicrophone {
            checkCameraPermission { granted in
                if granted {
                    decisionHandler(.grant)
                } else {
                    decisionHandler(.deny)
                }
            }
        }
        else {
            decisionHandler(.grant)
        }
    }

    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async {
                completion(true)
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if (!granted) {
                        self.showCameraPermissionAlert()
                    }
                    completion(granted)
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                // Optionally show an alert directing to Settings
                self.showCameraPermissionAlert()
                completion(false)
            }
        @unknown default:
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("🚀 Navigation Policy Decision:")
        print("   URL: \(navigationAction.request.url?.absoluteString ?? "nil")")

        // Check if this is a Scantrust redirect URL
        if let url = navigationAction.request.url?.absoluteString,
           url.hasPrefix("https://stc.scantrust.com/") {
            print("🎯 Scantrust redirect detected, intercepting...")

            // Extract parameters from the URL
            if let (uid, apiKey) = extractScantrustParameters(from: url) {
                print("   UID: \(uid)")
                print("   API Key: \(apiKey)")

                // Navigate to ScanResultViewController
                DispatchQueue.main.async {
                    self.navigateToScanResult(uid: uid, apiKey: apiKey)
                }

                // Cancel the webview navigation
                decisionHandler(.cancel)
                return
            } else {
                print("❌ Failed to extract parameters from Scantrust URL")
            }
        }

        decisionHandler(.allow)
    }

    private func showCameraPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Access Required",
            message: "Please grant camera access in Settings to use this feature",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        present(alert, animated: true)
    }

    // MARK: - URL Parameter Extraction

    private func extractScantrustParameters(from urlString: String) -> (uid: String, apiKey: String)? {
        // Parse URL with fragment-based query parameters
        // URL format: https://stc.scantrust.com/global/#/0?uid=...&qr=...&api_key=...

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL format")
            return nil
        }

        // Extract the fragment part (everything after #)
        guard let fragment = url.fragment else {
            print("❌ No fragment found in URL")
            return nil
        }

        // Find the query part after #/0?
        let queryPrefix = "/0?"
        guard let queryStartIndex = fragment.range(of: queryPrefix)?.upperBound else {
            print("❌ Query parameters not found after fragment")
            return nil
        }

        let queryString = String(fragment[queryStartIndex...])

        // Parse query parameters
        var components = URLComponents()
        components.query = queryString

        guard let queryItems = components.queryItems else {
            print("❌ Failed to parse query parameters")
            return nil
        }

        var uid: String?
        var apiKey: String?

        for item in queryItems {
            switch item.name {
            case "uid":
                uid = item.value
            case "api_key":
                apiKey = item.value
            default:
                break
            }
        }

        guard let extractedUid = uid, let extractedApiKey = apiKey else {
            print("❌ Missing required parameters (uid or api_key)")
            return nil
        }

        return (uid: extractedUid, apiKey: extractedApiKey)
    }

    private func navigateToScanResult(uid: String, apiKey: String) {
        let scanResultVC = ScanResultViewController(uid: uid, apiKey: apiKey)
        scanResultVC.delegate = self
        present(scanResultVC, animated: true)
    }

}
