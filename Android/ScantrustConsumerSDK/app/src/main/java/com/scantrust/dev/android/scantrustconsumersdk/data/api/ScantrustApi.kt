package com.scantrust.dev.android.scantrustconsumersdk.data.api

import com.scantrust.dev.android.scantrustconsumersdk.data.model.ScanResultResponse
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.Path

interface ScantrustApi {
    @GET("api/v2/consumer/scan/{uid}/combined-info/")
    suspend fun getScanResults(
        @Path("uid") uid: String,
        @Header("X-ScanTrust-Consumer-Api-Key") apiKey: String
    ): ScanResultResponse
}