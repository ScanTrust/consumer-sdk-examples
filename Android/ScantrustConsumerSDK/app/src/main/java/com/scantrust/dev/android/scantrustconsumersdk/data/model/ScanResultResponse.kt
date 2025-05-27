package com.scantrust.dev.android.scantrustconsumersdk.data.model

data class ScanResultResponse(
    val code: CodeInfo,
    val campaign: CampaignInfo,
    val scan: ScanInfo
)

data class CodeInfo(
    val product: ProductInfo,
    val brand: BrandInfo,
    val qrcode: QRCodeInfo,
    val scm_data: List<SCMData>,
    val scan_count: Int
)

data class ProductInfo(
    val id: Int,
    val name: String,
    val image: String,
    val description: String,
    val sku: String,
    val client_url: String
)

data class BrandInfo(
    val id: Int,
    val name: String,
    val description: String,
    val image: String
)

data class QRCodeInfo(
    val message: String,
    val creation_date: String,
    val serial_number: String,
    val is_blacklisted: Boolean,
    val activation_status: String,
    val blacklist_reason: String,
    val is_consumed: Boolean
)

data class SCMData(
    val name: String,
    val key: String,
    val position: Int,
    val type: String,
    val value: String
)

data class CampaignInfo(
    val products: List<ProductInfo>,
    val name: String,
    val options: CampaignOptions
)

data class CampaignOptions(
    val is_enabled: Boolean,
    val serial_number_lookup_enabled: Boolean,
    val complaints: ComplaintsConfig,
    val wechat: WeChatConfig,
    val mark_consumed: Boolean,
    val ga_key: String,
    val stc_config: Map<String, Any>
)

data class ComplaintsConfig(
    val is_enabled: Boolean,
    val to_email: String
)

data class WeChatConfig(
    val is_enabled: Boolean,
    val channel_redirect: ChannelRedirect
)

data class ChannelRedirect(
    val is_enabled: Boolean,
    val landing_page: String,
    val channel_id: String
)

data class ScanInfo(
    val app: String,
    val reason: String,
    val result: String,
    val auth_failure_mode: String,
    val country: String
)