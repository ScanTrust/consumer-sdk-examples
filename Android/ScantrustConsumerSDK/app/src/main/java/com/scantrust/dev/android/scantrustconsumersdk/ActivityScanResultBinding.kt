package com.scantrust.dev.android.scantrustconsumersdk

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.TextView
import androidx.viewbinding.ViewBinding
import com.google.android.material.card.MaterialCardView
import com.google.android.material.progressindicator.CircularProgressIndicator

class ActivityScanResultBinding private constructor(
    private val rootView: View,
    val appTextView: TextView,
    val reasonTextView: TextView,
    val resultTextView: TextView,
    val authFailureModeTextView: TextView,
    val countryTextView: TextView,
    val progressIndicator: CircularProgressIndicator,
    val resultCardView: MaterialCardView,
    val backButton: Button
) : ViewBinding {

    override fun getRoot(): View = rootView

    companion object {
        fun inflate(layoutInflater: LayoutInflater): ActivityScanResultBinding {
            val root = layoutInflater.inflate(R.layout.activity_scan_result, null, false)
            return bind(root)
        }

        fun bind(rootView: View): ActivityScanResultBinding = ActivityScanResultBinding(
            rootView = rootView,
            appTextView = rootView.findViewById(R.id.appTextView),
            reasonTextView = rootView.findViewById(R.id.reasonTextView),
            resultTextView = rootView.findViewById(R.id.resultTextView),
            authFailureModeTextView = rootView.findViewById(R.id.authFailureModeTextView),
            countryTextView = rootView.findViewById(R.id.countryTextView),
            progressIndicator = rootView.findViewById(R.id.progressIndicator),
            resultCardView = rootView.findViewById(R.id.resultCardView),
            backButton = rootView.findViewById(R.id.backButton)
        )
    }
}