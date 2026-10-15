//
//  Utils.swift
//  apptrove-ios-sdk
//
//  Created by Hemant Mann on 19/03/21.
//

import Foundation
import WebKit
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
    
    // System UA as URLSession sends it, e.g. "MyApp/42 CFNetwork/1494.0.7 Darwin/23.4.0".
    static let deviceUserAgent: String = {
        let info = Bundle.main.infoDictionary
        let appName = (info?["CFBundleName"] as? String) ?? (info?["CFBundleExecutable"] as? String) ?? "App"
        let appBuild = (info?["CFBundleVersion"] as? String) ?? "1"
        let cfNetwork = (Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary?["CFBundleVersion"] as? String) ?? ""
        var sysInfo = utsname()
        uname(&sysInfo)
        let darwin = withUnsafeBytes(of: &sysInfo.release) { bytes in
            String(decoding: bytes.prefix { $0 != 0 }, as: UTF8.self)
        }
        var ua = "\(appName.replacingOccurrences(of: " ", with: ""))/\(appBuild)"
        if !cfNetwork.isEmpty { ua += " CFNetwork/\(cfNetwork)" }
        if !darwin.isEmpty { ua += " Darwin/\(darwin)" }
        return toHeaderSafe(ua)
    }()

    // WKWebView UA, e.g. "Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148".
    // Read from a real WKWebView, not built by hand: from iOS 26 WebKit reports a frozen
    // OS version (18_x) rather than the real one. Cached per OS version, so the WebView
    // is only loaded on first launch and after an OS update.
    private static let webViewUALock = NSLock()
    private static let webViewUAGroup = DispatchGroup()
    private static var webViewUAValue: String? = nil
    private static var isWebViewUALoading = false
    private static var webViewUATimedOut = false
    private static var webViewUAView: WKWebView? = nil // main thread only, kept alive until JS returns

    // Called from initialize so the UA is usually ready before the first request.
    static func loadWebViewUserAgent() {
        webViewUALock.lock()
        if webViewUAValue != nil || isWebViewUALoading {
            webViewUALock.unlock()
            return
        }
        let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        let cached = CacheManager.getString(key: Constants.SHARED_PREF_WEBVIEW_UA)
        if !cached.isEmpty && CacheManager.getString(key: Constants.SHARED_PREF_WEBVIEW_UA_OS) == osVersion {
            webViewUAValue = cached
            webViewUALock.unlock()
            return
        }
        isWebViewUALoading = true
        webViewUAGroup.enter()
        webViewUALock.unlock()

        DispatchQueue.main.async {
            let webView = WKWebView(frame: .zero)
            webViewUAView = webView
            webView.evaluateJavaScript("navigator.userAgent") { result, error in
                let ua = toHeaderSafe((result as? String) ?? "")
                if ua.isEmpty {
                    Logger.debug(message: "WebView user agent unavailable: \(String(describing: error))")
                } else {
                    CacheManager.setString(key: Constants.SHARED_PREF_WEBVIEW_UA, value: ua)
                    CacheManager.setString(key: Constants.SHARED_PREF_WEBVIEW_UA_OS, value: osVersion)
                }
                webViewUALock.lock()
                webViewUAValue = ua
                isWebViewUALoading = false
                webViewUALock.unlock()
                webViewUAView = nil
                webViewUAGroup.leave()
            }
        }
    }

    // Empty if WKWebView fails, or if still loading when read on the main thread.
    static var webViewUserAgent: String {
        loadWebViewUserAgent()
        webViewUALock.lock()
        let shouldWait = webViewUAValue == nil && !webViewUATimedOut && !Thread.isMainThread
        webViewUALock.unlock()
        // Requests run off the main thread, so they can wait for the main-thread WebView load.
        if shouldWait && webViewUAGroup.wait(timeout: .now() + 3) == .timedOut {
            webViewUALock.lock()
            webViewUATimedOut = true
            webViewUALock.unlock()
        }
        webViewUALock.lock()
        defer { webViewUALock.unlock() }
        return webViewUAValue ?? ""
    }

    // Single User-Agent header: system UA followed by the WebView UA.
    static var userAgent: String {
        return [deviceUserAgent, webViewUserAgent].filter { !$0.isEmpty }.joined(separator: " ")
    }

    // Header values must be printable ASCII.
    private static func toHeaderSafe(_ value: String) -> String {
        return String(value.unicodeScalars.map { (32...126).contains($0.value) ? Character($0) : "?" })
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

