# Consumer SDK iOS Example

This guide explains how to correctly integrate Scantrust Web Video Auth within a `WKWebView` in an iOS application, specifically focusing on how to handle camera permissions natively.

## 1. Configure `Info.plist` for Camera Access & Location Permissions

Your app needs to declare its intent to use the camera and potentially location services. Add the following key-value pairs to your app's `Info.plist` file:

**For Camera Access:**

- **Key:** `Privacy - Camera Usage Description`
- **Value:** (String) A message explaining to the user why your app needs camera access. For example, "This app needs access to your camera to allow video calls and photo capture within the website."

**For Location Access (choose one or both as needed):**

- **Key:** `Privacy - Location When In Use Usage Description`
- **Value:** (String) A message explaining why your app needs location access while it's being used. For example, "This app needs your location to provide location-specific features within the website."

## 2. Handle Camera Permissions in Native Code (Swift)

You must request camera permission from the user at an appropriate time in your app's lifecycle, before the `WKWebView` attempts to access the camera.

Here's an example of how to request permission using Swift:

To properly intercept and handle camera permission requests originating from the JavaScript within your `WKWebView`, you need to implement the `WKUIDelegate`.

- **Conform to `WKUIDelegate`:**
  Make sure your `UIViewController` (or the class managing your `WKWebView`) conforms to the `WKUIDelegate` protocol.

  ```swift
  class ViewController: UIViewController, WKUIDelegate {
      var webView: WKWebView!
      // ...
  }
  ```

- **Set the `uiDelegate`:**
  Assign an instance of your delegate class to the `uiDelegate` property of your `WKWebView`. This is typically done during the `WKWebView`'s initialization.

  ```swift
  override func viewDidLoad() {
      super.viewDidLoad()
      let webConfiguration = WKWebViewConfiguration()
      webView = WKWebView(frame: .zero, configuration: webConfiguration)
      webView.uiDelegate = self // Set the delegate
      // ...
  }
  ```

- **Implement `requestMediaCapturePermissionFor`:**
  Implement the `webView(_:requestMediaCapturePermissionFor:initiatedBy:type:decisionHandler:)` delegate method. This method is called when the web content requests permission to capture media (audio or video).

  ```swift
  func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
      // Check if the request is for video
      guard type == .camera || type == .cameraAndMicrophone else {
          decisionHandler(.prompt) // Or .grant / .deny based on your app's logic for other types
          return
      }

      // Now, use your native permission checking logic
      self.checkCameraPermission { [weak self] granted in
          guard self != nil else {
              decisionHandler(.deny)
              return
          }
          if granted {
              decisionHandler(.grant)
          } else {
              // If permission was denied or restricted natively,
              // you might still call .prompt() to let the user know
              // or .deny() if you don't want to show the web's prompt.
              // For a consistent UX, denying here if native permission is denied is often best.
              decisionHandler(.deny)
          }
      }
  }
  ```

The following Swift code block demonstrates the native permission check (`checkCameraPermission`), which you would call from your `WKUIDelegate` method or at an earlier appropriate point in your app's flow:

```swift
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
```

By following these steps, you can successfully integrate Scantrust Web Video Auth into an iOS app using `WKWebView` and manage camera permissions effectively.
