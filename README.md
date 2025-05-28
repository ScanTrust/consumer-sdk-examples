# Scantrust Consumer SDK Examples

This repository contains example implementations demonstrating how to integrate Scantrust Web Video Auth within mobile applications using WebViews, specifically focusing on handling camera permissions and displaying custom scan results by interacting with the Scantrust Consumer API.

These examples cover key aspects such as:

*   Configuring necessary project settings (`AndroidManifest.xml` for Android, `Info.plist` for iOS) for camera and internet access.
*   Setting up and configuring WebViews (`WebView` for Android, `WKWebView` for iOS) to support media capture and JavaScript execution.
*   Handling camera permissions using modern native patterns (`ActivityResultContracts` for Android, `AVCaptureDevice` and `WKUIDelegate` for iOS).
*   Intercepting web permission requests and bridging them with native permission handling.
*   Intercepting scan result URLs from the WebView to launch a custom native screen.
*   Fetching product information from the Scantrust Consumer API based on the scan result.

## Configuring Web Video Auth

The examples in this repository demonstrate how to integrate Scantrust Web Video Auth. The WebViews are configured to load the following URL for this purpose:

[https://verify.scantrust.com/video/](https://verify.scantrust.com/video/)

## Platform-Specific Guides

For detailed integration steps and code examples tailored to each platform, please refer to the respective README files:

*   **Android Example:** See the [guide](./Android/README.md) for instructions on integrating with `WebView` using Kotlin.
*   **iOS Example:** See the [guide](./iOS/README.md) for instructions on integrating with `WKWebView` using Swift.

## API Documentation

Both examples utilize the Scantrust Consumer API to fetch scan result information. You can find the full API documentation here:

[https://devportal.scantrust.com/docs/build-with-scantrust/consumer/scantrust-consumer-api](https://devportal.scantrust.com/docs/build-with-scantrust/consumer/scantrust-consumer-api)
