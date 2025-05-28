//
//  ScanResultResponse.swift
//  ScantrustConsumerSDK
//
//  Created by AI Assistant on 2024-06-09.
//

import Foundation

struct ScanResultResponse: Codable {
    let code: CodeInfo
    let campaign: Campaign
    let scan: ScanInfo
}

struct CodeInfo: Codable {
    let product: Product
    let brand: Brand
    let qrcode: QRCode
    let scmData: [SCMData]
    let scanCount: Int

    enum CodingKeys: String, CodingKey {
        case product
        case brand
        case qrcode
        case scmData = "scm_data"
        case scanCount = "scan_count"
    }
}

struct Product: Codable {
    let id: Int
    let name: String
    let image: String?
    let description: String?
    let sku: String?
    let clientUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
        case description
        case sku
        case clientUrl = "client_url"
    }
}

struct Brand: Codable {
    let id: Int
    let name: String
    let description: String?
    let image: String?
}

struct QRCode: Codable {
    let message: String
    let creationDate: String
    let serialNumber: String?
    let isBlacklisted: Bool
    let activationStatus: String
    let blacklistReason: String?
    let isConsumed: Bool

    enum CodingKeys: String, CodingKey {
        case message
        case creationDate = "creation_date"
        case serialNumber = "serial_number"
        case isBlacklisted = "is_blacklisted"
        case activationStatus = "activation_status"
        case blacklistReason = "blacklist_reason"
        case isConsumed = "is_consumed"
    }
}

struct SCMData: Codable {
    let name: String
    let key: String
    let position: Int
    let type: String
    let value: String
}

struct Campaign: Codable {
    let products: [Product]
    let name: String
    let options: CampaignOptions
}

struct CampaignOptions: Codable {
    let isEnabled: Bool
    let serialNumberLookupEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case isEnabled = "is_enabled"
        case serialNumberLookupEnabled = "serial_number_lookup_enabled"
    }
}

struct ScanInfo: Codable {
    let app: String
    let reason: String
    let result: String
    let authFailureMode: String
    let country: String

    enum CodingKeys: String, CodingKey {
        case app
        case reason
        case result
        case authFailureMode = "auth_failure_mode"
        case country
    }
}