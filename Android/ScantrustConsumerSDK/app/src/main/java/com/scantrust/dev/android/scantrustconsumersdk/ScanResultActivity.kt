package com.scantrust.dev.android.scantrustconsumersdk

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.activity.OnBackPressedCallback
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.google.android.material.snackbar.Snackbar
import com.scantrust.dev.android.scantrustconsumersdk.data.api.ScantrustApi
import com.scantrust.dev.android.scantrustconsumersdk.data.model.ScanResultResponse
import kotlinx.coroutines.launch
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.HttpException
import java.io.IOException

class ScanResultActivity : AppCompatActivity() {

    private lateinit var binding: ActivityScanResultBinding
    private lateinit var api: ScantrustApi

    companion object {
        private const val EXTRA_UID = "extra_uid"
        private const val EXTRA_API_KEY = "extra_api_key"
        private const val BASE_URL = "https://api.scantrust.com/"

        fun createIntent(context: Context, uid: String, apiKey: String): Intent {
            return Intent(context, ScanResultActivity::class.java).apply {
                putExtra(EXTRA_UID, uid)
                putExtra(EXTRA_API_KEY, apiKey)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        binding = ActivityScanResultBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupApi()
        setupBackButton()
        fetchScanResults()

        // Handle system back button
        val callback = object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                setResult(RESULT_OK)
                finish()
            }
        }
        onBackPressedDispatcher.addCallback(this, callback)
    }

    private fun setupApi() {
        val retrofit = Retrofit.Builder()
            .baseUrl(BASE_URL)
            .addConverterFactory(GsonConverterFactory.create())
            .build()

        api = retrofit.create(ScantrustApi::class.java)
    }

    private fun setupBackButton() {
        binding.backButton.setOnClickListener {
            // Set result and finish activity
            setResult(RESULT_OK)
            finish()
        }
    }

    private fun fetchScanResults() {
        val uid = intent.getStringExtra(EXTRA_UID)
        val apiKey = intent.getStringExtra(EXTRA_API_KEY)

        if (uid == null || apiKey == null) {
            showError("Invalid scan data")
            return
        }

        showLoading(true)

        lifecycleScope.launch {
            try {
                val response = api.getScanResults(uid, apiKey)
                updateUI(response)
            } catch (e: HttpException) {
                showError("Error: ${e.message}")
            } catch (e: IOException) {
                showError("Network error. Please check your connection.")
            } catch (e: Exception) {
                showError("Unexpected error: ${e.message}")
            } finally {
                showLoading(false)
            }
        }
    }

    private fun updateUI(response: ScanResultResponse) {
        with(binding) {
            appTextView.text = response.scan.app
            reasonTextView.text = response.scan.reason
            resultTextView.text = response.scan.result
            authFailureModeTextView.text = response.scan.auth_failure_mode
            countryTextView.text = response.scan.country
        }
    }

    private fun showLoading(show: Boolean) {
        binding.apply {
            progressIndicator.visibility = if (show) View.VISIBLE else View.GONE
            resultCardView.visibility = if (show) View.INVISIBLE else View.VISIBLE
        }
    }

    private fun showError(message: String) {
        Snackbar.make(binding.root, message, Snackbar.LENGTH_LONG).show()
    }
}