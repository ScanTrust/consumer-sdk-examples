import UIKit
import WebKit
import AVFoundation

class ViewController: UIViewController {

    private var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadURL()
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.uiDelegate = self

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

extension ViewController: WKUIDelegate {

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
                    completion(granted)
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                // Optionally show an alert directing to Settings
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
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true)
                completion(false)
            }
        @unknown default:
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }

}
