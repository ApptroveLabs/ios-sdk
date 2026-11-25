//
//  AppTroveSkanCompute.swift
//  apptrove-ios-sdk
//
//  Handles SKAN compute API response and request body.
//  Apple is updated only when data.active is true.
//

import Foundation

struct SkanComputeData: Decodable {
    let active: Bool?
    let fineCv: Int?
    let coarseCv: String?
    let lock: Bool?

    enum CodingKeys: String, CodingKey {
        case active
        case fineCv = "fine_cv"
        case coarseCv = "coarse_cv"
        case lock
    }
}

struct SkanComputeResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: SkanComputeData?

    static func parse(from data: Data?) -> SkanComputeResponse? {
        guard let data = data, !data.isEmpty else { return nil }

        // Skip empty or plain text bodies
        if let text = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           text.isEmpty || text == "null" || text.lowercased() == "not found" {
            return nil
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            Logger.debug(message: "[SKAN] could not parse response")
            return nil
        }

        // Preferred format: { success, message, data: { active, fine_cv, coarse_cv, lock } }
        if let dataObj = json["data"] as? [String: Any] {
            return SkanComputeResponse(
                success: Self.boolValue(json["success"]),
                message: Self.stringValue(json["message"]),
                data: SkanComputeData(
                    active: Self.boolValue(dataObj["active"]),
                    fineCv: Self.intValue(dataObj["fine_cv"]),
                    coarseCv: Self.stringValue(dataObj["coarse_cv"]),
                    lock: Self.boolValue(dataObj["lock"])
                )
            )
        }

        // Temporary flat format while API is still updating
        if json["active"] != nil || json["fine_cv"] != nil {
            return SkanComputeResponse(
                success: Self.boolValue(json["success"]) ?? true,
                message: Self.stringValue(json["message"]),
                data: SkanComputeData(
                    active: Self.boolValue(json["active"]),
                    fineCv: Self.intValue(json["fine_cv"]),
                    coarseCv: Self.stringValue(json["coarse_cv"]),
                    lock: Self.boolValue(json["lock"])
                )
            )
        }

        // Error reply, e.g. {"success":false,"message":"cv mapping not found","data":null}
        if json["success"] != nil || json["message"] != nil {
            return SkanComputeResponse(
                success: Self.boolValue(json["success"]),
                message: Self.stringValue(json["message"]),
                data: nil
            )
        }

        return nil
    }

    var isSuccess: Bool {
        success == true
    }

    var shouldApplyToApple: Bool {
        isSuccess && data?.active == true
    }

    var validFineCv: Int? {
        guard let fineCv = data?.fineCv, (0...63).contains(fineCv) else { return nil }
        return fineCv
    }

    var mappedCoarseValue: AppTroveCoarseValue? {
        guard let raw = data?.coarseCv?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
              !raw.isEmpty else {
            return nil
        }
        switch raw {
        case "low": return .low
        case "medium", "med": return .medium
        case "high": return .high
        default:
            Logger.debug(message: "[SKAN] unknown coarse_cv \(raw)")
            return nil
        }
    }

    var lockWindow: Bool {
        data?.lock ?? false
    }

    // MARK: - Helpers

    private static func boolValue(_ any: Any?) -> Bool? {
        if any == nil || any is NSNull { return nil }
        if let b = any as? Bool { return b }
        if let n = any as? NSNumber { return n.boolValue }
        if let s = any as? String {
            switch s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            case "true", "1", "yes": return true
            case "false", "0", "no": return false
            default: return nil
            }
        }
        return nil
    }

    private static func intValue(_ any: Any?) -> Int? {
        if any == nil || any is NSNull { return nil }
        if let i = any as? Int { return i }
        if let n = any as? NSNumber { return n.intValue }
        if let d = any as? Double { return Int(d) }
        if let s = any as? String {
            let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
            if t.isEmpty { return nil }
            return Int(t)
        }
        return nil
    }

    private static func stringValue(_ any: Any?) -> String? {
        if any == nil || any is NSNull { return nil }
        if let s = any as? String {
            let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
            return t.isEmpty ? nil : t
        }
        if let n = any as? NSNumber { return n.stringValue }
        return nil
    }
}

enum SkanComputeRequestBuilder {

    static func makeBody(
        appKey: String,
        installId: String,
        installTs: String,
        idfa: String?,
        eventTs: String,
        eventId: String,
        revenue: Double?,
        currency: String?
    ) -> [String: Any]? {
        let installID = installId.lowercased()

        guard !appKey.isEmpty else {
            Logger.debug(message: "[SKAN] missing app_key")
            return nil
        }
        guard !installID.isEmpty else {
            Logger.debug(message: "[SKAN] missing install_id")
            return nil
        }
        guard !eventId.isEmpty else {
            Logger.debug(message: "[SKAN] missing e_id")
            return nil
        }
        guard !installTs.isEmpty else {
            Logger.debug(message: "[SKAN] missing install_ts")
            return nil
        }
        guard !eventTs.isEmpty else {
            Logger.debug(message: "[SKAN] missing event_ts")
            return nil
        }

        var idfaValue = idfa ?? ""
        // Zero IDFA is not useful, send empty
        if idfaValue == "00000000-0000-0000-0000-000000000000" {
            idfaValue = ""
        }

        return [
            "app_key": appKey,
            "install_id": installID,
            "install_ts": installTs,
            "idfa": idfaValue,
            "event_ts": eventTs,
            "e_id": eventId,
            "e_rev": revenue ?? 0,
            "e_curr": currency ?? ""
        ]
    }
}
