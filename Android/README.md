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

## 5. Show Custom Scan Result

To create a custom scan result screen that displays product information from the Scantrust API:

First, intercept the navigation in your WebView by implementing a WebViewClient:

```kotlin
webView.webViewClient = object : WebViewClient() {
    override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
        request?.url?.let { uri ->
            if (uri.scheme == "scantrust" && uri.host == "scan-result") {
                // Extract scan ID (uid) from the URL
                val uid = uri.getQueryParameter("uid")
                if (uid != null) {
                    // Present custom result view
                    val intent = Intent(this@MainActivity, ScanResultActivity::class.java).apply {
                        putExtra("uid", uid)
                        putExtra("apiKey", "YOUR_API_KEY")
                    }
                    startActivity(intent)
                    return true
                }
            }
        }
        return false
    }
}
```

Create a custom result activity that fetches and displays scan data:

```kotlin
class ScanResultActivity : AppCompatActivity() {
    private lateinit var uid: String
    private lateinit var apiKey: String

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_scan_result)

        uid = intent.getStringExtra("uid") ?: return
        apiKey = intent.getStringExtra("apiKey") ?: return

        fetchScanResults()
    }

    private fun fetchScanResults() {
        val url = "https://api.scantrust.com/api/v2/consumer/scan/$uid/combined-info/"
        val request = Request.Builder()
            .url(url)
            .addHeader("X-ScanTrust-Consumer-Api-Key", apiKey)
            .build()

        OkHttpClient().newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                // Handle error
            }

            override fun onResponse(call: Call, response: Response) {
                // Process the response and update UI
                val responseData = response.body?.string()
                runOnUiThread {
                    // Update UI with scan results
                }
            }
        })
    }
}
```

See the API documentation at: https://devportal.scantrust.com/docs/build-with-scantrust/consumer/scantrust-consumer-api
