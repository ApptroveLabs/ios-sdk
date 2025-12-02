//
//  Utils.swift
//  apptrove-ios-sdk
//
//  Created by Hemant Mann on 19/03/21.
//

import Foundation
import CryptoSwift

class Utils {
    
    static func getDateTimeFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return formatter
    }
    
    static func formatTime(date: Date) -> String {
        let formatter = getDateTimeFormatter()
        return formatter.string(from: date)
    }
    
    static func getCurrentTime() -> String {
        let date = Date()
        let formatter = getDateTimeFormatter()
        return formatter.string(from: date)
    }
    
    static func convertUnixTsToISO(ts: Int64) -> String {
        let lst = Date(timeIntervalSince1970: TimeInterval(ts))
        return formatTime(date: lst)
    }
    
    static func convertDictToJSON(data: Dictionary<String, Any>) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            let decoded = String(data: jsonData, encoding: .utf8)!
            return decoded
        } catch {
            return ""
        }
    }
    
    // Reference: https://stackoverflow.com/questions/34778950/how-to-compare-any-value-types
    static func isEqual<T: Equatable>(type: T.Type, a: Any, b: Any) -> Bool {
        guard let a = a as? T, let b = b as? T else { return false }

        return a == b
    }

    static func getUnixTime(time: String?) -> String {
        if (time != nil) {
            let dateFormatter = getDateTimeFormatter()
            let date = dateFormatter.date(from: time!)
            return String(date!.timeIntervalSince1970)
        } else {
            return ""
        }
    }
    
    static func createSignature(message: String, key: String) -> String {
        do {
            let bytes = try CryptoSwift.HMAC(key: key, variant: .sha2(.sha256)).authenticate(message.bytes)
            let data = Data(bytes)

            return data.hexEncodedString()
        } catch {
            return ""
        }
    }
    
    static func makeQueryString(_ queryItems: [URLQueryItem]) -> String? {
        let url = URL(string: "https://domain.com")
        var urlComponents = URLComponents(url: url!, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = queryItems
        
        if #available(iOS 16.0, *) {
            return urlComponents.url?.query(percentEncoded: false)
        }
        return urlComponents.url?.query
    }
    
    static func campaignData(res: InstallResponse) -> Void {
        CacheManager.setString(key: Constants.SHARED_PREF_AD, value: res.ad!)
        CacheManager.setString(key: Constants.SHARED_PREF_ADID, value: res.adId!)
        CacheManager.setString(key: Constants.SHARED_PREF_CAMPAIGN, value: res.camp!)
        CacheManager.setString(key: Constants.SHARED_PREF_CAMPAIGNID, value: res.campId!)
        CacheManager.setString(key: Constants.SHARED_PREF_ADSET, value: res.adSet!)
        CacheManager.setString(key: Constants.SHARED_PREF_ADSETID, value: res.adSetId!)
        CacheManager.setString(key: Constants.SHARED_PREF_CHANNEL, value: res.channel!)
        CacheManager.setString(key: Constants.SHARED_PREF_P1, value: res.p1!)
        CacheManager.setString(key: Constants.SHARED_PREF_P2, value: res.p2!)
        CacheManager.setString(key: Constants.SHARED_PREF_P3, value: res.p3!)
        CacheManager.setString(key: Constants.SHARED_PREF_P4, value: res.p4!)
        CacheManager.setString(key: Constants.SHARED_PREF_P5, value: res.p5!)
        CacheManager.setString(key: Constants.SHARED_PREF_CLICKID, value: res.clickId!)
        CacheManager.setString(key: Constants.SHARED_PREF_DLV, value: res.dlv!)
        CacheManager.setString(key: Constants.SHARED_PREF_PID, value: res.pid!)
        CacheManager.setBool(key: Constants.SHARED_PREF_ISRETARGETING, value: res.isRetargeting!)
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

