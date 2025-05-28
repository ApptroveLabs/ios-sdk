import Foundation
import StoreKit

struct SKANResponse: Codable {
    let success: Bool
    let data: SKANConfig?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case data
        case message
    }
}

struct SKANConfig: Codable {
    let id: String
    let aid: String
    let window1: SKANWindow
    let window2: SKANWindow
    let window3: SKANWindow
    let status: String
    let currency: String?
    let createdAt: Date
    let updatedAt: Date
    let skanVer: String?
    let oid: String?
    let createdBy: String?
    let updatedBy: String?

    enum CodingKeys: String, CodingKey {
        case id, aid, status, currency, window1, window2, window3
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case skanVer = "skan_ver"
        case oid, createdBy = "created_by", updatedBy = "updated_by"
    }

    enum ValidationError: Error {
        case invalidRevenueRanges
        case missingWindow1Values
        case overlappingRevenueRanges
        case invalidLockWindowValue
    }

    func validate() throws {
        if window1.fineValues?.isEmpty ?? true && window1.coarseValues?.isEmpty ?? true {
            throw ValidationError.missingWindow1Values
        }
        try validateWindow(window: window1)
        try validateWindow(window: window2)
        try validateWindow(window: window3)
    }

    private func validateWindow(window: SKANWindow) throws {
        if let fineValues = window.fineValues {
            try validateRanges(values: fineValues.map { ($0.revenueStart, $0.revenueEnd) })
        }
        if let coarseValues = window.coarseValues {
            try validateRanges(values: coarseValues.map { ($0.revenueStart, $0.revenueEnd) })
        }
    }

    private func validateRanges(values: [(start: Double, end: Double)]) throws {
        let sorted = values.sorted { $0.start < $1.start }
        for i in 0..<sorted.count-1 {
            if sorted[i].end > sorted[i+1].start {
                throw ValidationError.overlappingRevenueRanges
            }
        }
    }
}

struct SKANWindow: Codable {
    let fineValues: [SKANFineValue]?
    let coarseValues: [SKANCoarseValue]?
    let lockWindowValue: String?

    enum CodingKeys: String, CodingKey {
        case fineValues = "conv_fine"
        case coarseValues = "conv_coarse"
        case lockWindowValue = "lw_value"
    }

    var shouldLock: Bool {
        guard let value = lockWindowValue?.lowercased() else { return false }
        return value == "true" || value == "high" || value == "medium" || (Double(value) != nil && Double(value)! > 0)
    }

    var isValidLockWindow: Bool {
        guard let value = lockWindowValue?.lowercased() else { return true }
        return ["true", "false", "high", "low", "medium"].contains(value) || Double(value) != nil
    }
}

struct SKANFineValue: Codable {
    let eventId: String?
    let eventName: String?
    let value: Int
    let revenueStart: Double
    let revenueEnd: Double

    enum CodingKeys: String, CodingKey {
        case eventId = "eid"
        case eventName = "ename"
        case value = "conv_val"
        case revenueStart = "rev_start"
        case revenueEnd = "rev_end"
    }

    func matches(eventId: String?, revenue: Double) -> Bool {
        let eventMatches = self.eventId == eventId || eventId == nil || self.eventId?.isEmpty == true
        let revenueMatches = revenue >= revenueStart && revenue <= revenueEnd
        return eventMatches && revenueMatches
    }
}

struct SKANCoarseValue: Codable {
    let eventId: String?
    let eventName: String?
    let type: SKANCoarseType
    let revenueStart: Double
    let revenueEnd: Double

    enum CodingKeys: String, CodingKey {
        case eventId = "eid"
        case eventName = "ename"
        case type
        case revenueStart = "rev_start"
        case revenueEnd = "rev_end"
    }

    func matches(eventId: String?, revenue: Double) -> Bool {
        let eventMatches = self.eventId == eventId || eventId == nil || self.eventId?.isEmpty == true
        let revenueMatches = revenue >= revenueStart && revenue <= revenueEnd
        return eventMatches && revenueMatches
    }
}

enum SKANCoarseType: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"

    @available(iOS 16.1, *)
    var skAdNetworkValue: SKAdNetwork.CoarseConversionValue {
        switch self {
        case .medium: return .medium
        case .high: return .high
        default: return .low
        }
    }
}

struct SKANCurrentValues {
    var fine: Int?
    var coarse: SKANCoarseType?
    var lock: Bool
    var lastUpdated: Date?

    init(fine: Int? = nil, coarse: SKANCoarseType? = nil, lock: Bool = false) {
        self.fine = fine
        self.coarse = coarse
        self.lock = lock
    }
}

// Updated extension for flexible date decoding
extension JSONDecoder {
    static var skanDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let formatters = [
                DateFormatter().apply { $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" },
                DateFormatter().apply { $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSZZ" },
                DateFormatter().apply { $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZZ" },
                DateFormatter().apply { $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" }
            ]
            
            for formatter in formatters {
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string: \(dateString)")
        }
        return decoder
    }
}

// Helper extension for DateFormatter configuration
extension DateFormatter {
    func apply(_ configuration: (DateFormatter) -> Void) -> DateFormatter {
        configuration(self)
        return self
    }
}
