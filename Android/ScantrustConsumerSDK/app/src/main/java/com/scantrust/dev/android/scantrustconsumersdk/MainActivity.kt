package com.scantrust.dev.android.scantrustconsumersdk

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import android.webkit.PermissionRequest
import android.webkit.WebChromeClient
import android.webkit.WebResourceRequest
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.activity.OnBackPressedCallback
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat

class MainActivity : AppCompatActivity() {
    
    private lateinit var webView: WebView
    private var pendingPermissionRequest: PermissionRequest? = null
    
    private lateinit var cameraPermissionLauncher: ActivityResultLauncher<String>
    private lateinit var scanResultLauncher: ActivityResultLauncher<Intent>
    
    private fun setupActivityResults() {
        cameraPermissionLauncher = registerForActivityResult(
            ActivityResultContracts.RequestPermission()
        ) { isGranted: Boolean ->
            handleCameraPermissionResult(isGranted)
        }
        
        scanResultLauncher = registerForActivityResult(
            ActivityResultContracts.StartActivityForResult()
        ) {
            // Reload WebView when returning from ScanResultActivity
            loadURL()
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_main)
        
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }
        
        setupActivityResults()
        setupWebView()
        loadURL()
        setupBackPressedCallback()
    }
    
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
        
        // Set WebViewClient
        webView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest): Boolean {
                val url = request.url.toString()
                if (url.startsWith("https://stc.scantrust.com/")) {
                    // Extract parameters from URL
                    extractScantrustParameters(url)?.let { (uid, apiKey) ->
                        // Navigate to ScanResultActivity using the Activity Result API
                        scanResultLauncher.launch(ScanResultActivity.createIntent(this@MainActivity, uid, apiKey))
                        return true
                    }
                }
                return false
            }
        }
        
        // Set WebChromeClient to handle permissions
        webView.webChromeClient = object : WebChromeClient() {
            override fun onPermissionRequest(request: PermissionRequest?) {
                request?.let { permissionRequest ->
                    val requestedResources = permissionRequest.resources
                    
                    // Check if camera permission is requested
                    if (requestedResources.contains(PermissionRequest.RESOURCE_VIDEO_CAPTURE)) {
                        pendingPermissionRequest = permissionRequest
                        checkCameraPermission()
                    } else {
                        // Grant other permissions
                        permissionRequest.grant(requestedResources)
                    }
                }
            }
        }
    }
    

    
    private fun loadURL() {
        webView.loadUrl("https://verify.scantrust.com/video/")
    }

    private fun extractScantrustParameters(urlString: String): Pair<String, String>? {
        try {
            // Parse URL with fragment-based query parameters
            // URL format: https://stc.scantrust.com/global/#/0?uid=...&qr=...&api_key=...
            val uri = Uri.parse(urlString)
            val fragment = uri.fragment ?: return null

            // Find the query part after #/0?
            val queryStartIndex = fragment.indexOf("/0?")
            if (queryStartIndex == -1) return null

            val queryString = fragment.substring(queryStartIndex + 3)
            val params = Uri.parse("dummy://dummy?$queryString")

            val uid = params.getQueryParameter("uid")
            val apiKey = params.getQueryParameter("api_key")

            if (uid != null && apiKey != null) {
                return Pair(uid, apiKey)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
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
    
    private fun showPermissionRationale() {
        AlertDialog.Builder(this)
            .setTitle("Camera Permission Required")
            .setMessage("This app needs camera access to scan QR codes and verify products.")
            .setPositiveButton("Grant Permission") { _, _ ->
                cameraPermissionLauncher.launch(Manifest.permission.CAMERA)
            }
            .setNegativeButton("Cancel") { _, _ ->
                denyWebViewPermission()
            }
            .show()
    }
    
    private fun handleCameraPermissionResult(isGranted: Boolean) {
        if (isGranted) {
            grantWebViewPermission()
        } else {
            showPermissionDeniedDialog()
        }
    }
    
    private fun showPermissionDeniedDialog() {
        AlertDialog.Builder(this)
            .setTitle("Camera Access Required")
            .setMessage("Please grant camera access in Settings to use this feature")
            .setPositiveButton("Settings") { _, _ ->
                openAppSettings()
                denyWebViewPermission()
            }
            .setNegativeButton("Cancel") { _, _ ->
                denyWebViewPermission()
            }
            .show()
    }
    
    private fun openAppSettings() {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.fromParts("package", packageName, null)
        }
        startActivity(intent)
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
    
    override fun onResume() {
        super.onResume()
        webView.onResume()
    }
    
    override fun onPause() {
        super.onPause()
        webView.onPause()
    }
    
    override fun onDestroy() {
        super.onDestroy()
        webView.destroy()
    }
    
    private fun setupBackPressedCallback() {
        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                if (webView.canGoBack()) {
                    webView.goBack()
                } else {
                    finish()
                }
            }
        })
    }
}