# Consumer SDK Android Example

This guide explains how to correctly integrate Scantrust Web Video Auth within a `WebView` in an Android application, specifically focusing on how to handle camera permissions natively using modern Android development practices.

## 1. Configure `AndroidManifest.xml` for Camera Access & Internet Permissions

Your app needs to declare its intent to use the camera and internet access. Add the following permissions and hardware features to your app's `AndroidManifest.xml` file:

**For Camera and Internet Access:**

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />

<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
```

**For Hardware Acceleration (recommended for WebView performance):**

```xml
<application
    android:hardwareAccelerated="true"
    ... >
```

Setting `android:required="false"` for camera features ensures your app can still be installed on devices without cameras, though camera functionality won't be available.

## 2. WebView Setup and Configuration

Configure your WebView with the necessary settings to support media capture and JavaScript execution:

```kotlin
private fun setupWebView() {
    webView = findViewById(R.id.webView)

    // Configure WebView settings
    val webSettings = webView.settings
    webSettings.javaScriptEnabled = true
    webSettings.mediaPlaybackRequiresUserGesture = false
    webSettings.domStorageEnabled = true
    webSettings.allowFileAccess = true
    webSettings.allowContentAccess = true
    webSettings.mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW

    // Set WebViewClient for navigation handling
    webView.webViewClient = WebViewClient()

    // Set WebChromeClient for permission handling
    webView.webChromeClient = object : WebChromeClient() {
        override fun onPermissionRequest(request: PermissionRequest?) {
            handleWebPermissionRequest(request)
        }
    }
}
```

## 3. Handle Camera Permissions Using Modern Android Patterns

Use `ActivityResultContracts` to handle camera permission requests. This is the modern approach that replaces deprecated permission handling methods:

```kotlin
class MainActivity : AppCompatActivity() {

    private lateinit var webView: WebView
    private var pendingPermissionRequest: PermissionRequest? = null

    // Modern permission launcher
    private val cameraPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted: Boolean ->
        handleCameraPermissionResult(isGranted)
    }

    private fun checkCameraPermission() {
        when {
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.CAMERA
            ) == PackageManager.PERMISSION_GRANTED -> {
                // Permission already granted
                grantWebViewPermission()
            }
            shouldShowRequestPermissionRationale(Manifest.permission.CAMERA) -> {
                // Show rationale and request permission
                showPermissionRationale()
            }
            else -> {
                // Request permission directly
                cameraPermissionLauncher.launch(Manifest.permission.CAMERA)
            }
        }
    }
```

## 4. Bridge Web Permissions with Native Android Permissions

Implement the `WebChromeClient.onPermissionRequest` method to intercept permission requests from web content and handle them using native Android permissions:

```kotlin
private fun handleWebPermissionRequest(request: PermissionRequest?) {
    request?.let { permissionRequest ->
        val requestedResources = permissionRequest.resources

        // Check if camera permission is requested
        if (requestedResources.contains(PermissionRequest.RESOURCE_VIDEO_CAPTURE)) {
            pendingPermissionRequest = permissionRequest
            checkCameraPermission()
        } else {
            // Grant other permissions (like microphone if needed)
            permissionRequest.grant(requestedResources)
        }
    }
}

private fun grantWebViewPermission() {
    pendingPermissionRequest?.let { request ->
        request.grant(request.resources)
        pendingPermissionRequest = null
    }
}

private fun denyWebViewPermission() {
    pendingPermissionRequest?.let { request ->
        request.deny()
        pendingPermissionRequest = null
    }
}
```

By following these steps, you can successfully integrate Scantrust Web Video Auth into an Android app using `WebView` and manage camera permissions effectively with modern Android development practices.
