//
//  SKANError.swift
//  Pods
//
//  Created by Satyam Jha on 01/04/25.
//

// SKANError.swift
import Foundation

public enum SKANError: Error, LocalizedError, Equatable {
case configurationMissing
case noValuesSet
case updateTooFrequent
case unsupportediOSVersion
case invalidConfig(Error)
case invalidURL
case invalidResponse
case noData
case serverError(statusCode: Int)
case invalidLockWindowValue(String)
case postbackError(Error)
case invalidCoarseValue(String)

public var localizedDescription: String {
    switch self {
    case .configurationMissing: return "SKAN configuration not loaded"
    case .noValuesSet: return "No conversion values set"
    case .updateTooFrequent: return "SKAN update skipped - too frequent"
    case .unsupportediOSVersion: return "SKAN not supported on this iOS version"
    case .invalidConfig(let error): return "Invalid SKAN configuration: \\(error.localizedDescription)"
    case .invalidURL: return "Invalid URL"
    case .invalidResponse: return "Invalid response from server"
    case .noData: return "No data received from server"
    case .serverError(let statusCode): return "Server error with status code: \\(statusCode)"
    case .invalidLockWindowValue(let value): return "Invalid lock window value: '\\(value)'"
    case .postbackError(let error): return "Postback failed: \\(error.localizedDescription)"
    case .invalidCoarseValue(let value): return "Invalid coarse value: '\\(value)'"
    }
}

public var errorDescription: String? {
    return localizedDescription
}

public var recoverySuggestion: String? {
    switch self {
    case .configurationMissing:
        return "Fetch the SKAN configuration before calling this method."
    case .unsupportediOSVersion:
        return "Requires iOS 14.5 or later."
    case .serverError(let statusCode):
        return "Retry after checking server status. If persistent, contact support."
    case .invalidLockWindowValue:
        return "Lock window value must be 'true', 'false', 'high', 'medium', 'low', or a number."
    default:
        return nil
    }
}

public static func == (lhs: SKANError, rhs: SKANError) -> Bool {
    switch (lhs, rhs) {
    case (.configurationMissing, .configurationMissing),
         (.noValuesSet, .noValuesSet),
         (.updateTooFrequent, .updateTooFrequent),
         (.unsupportediOSVersion, .unsupportediOSVersion),
         (.invalidURL, .invalidURL),
         (.invalidResponse, .invalidResponse),
         (.noData, .noData):
        return true
    case (.serverError(let lhsCode), .serverError(let rhsCode)):
        return lhsCode == rhsCode
    case (.invalidConfig(let lhsError), .invalidConfig(let rhsError)):
        return lhsError.localizedDescription == rhsError.localizedDescription
    case (.invalidLockWindowValue(let lhsValue), .invalidLockWindowValue(let rhsValue)):
        return lhsValue == rhsValue
    default:
        return false
    }
}

}
