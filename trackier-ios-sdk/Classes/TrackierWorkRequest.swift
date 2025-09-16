//
//  TrackierWorkRequest.swift
//  trackier-ios-sdk
//
//  Created by Hemant Mann on 19/03/21.
//

import Foundation

class TrackierWorkRequest {
    static let KIND_INSTALL = "install"
    static let KIND_EVENT = "event"
    static let KIND_SESSION = "session"
    static let KIND_UNKNOWN = "unknown"
    static let KIND_Token = "deviceToken"
    static let KIND_Resolver = "deeplinkURL"
    
    var kind: String
    var installId: String = ""
    var installTime: String = ""
    var eventObj = TrackierEvent(id: "")
    var deviceInfo: DeviceInfo? = nil
    var lastSessionTime: String
    private var appToken: String
    private var mode: String
    var customerId = ""
    var customerEmail = ""
    var customerOptionals: Dictionary<String, Any>? = nil
    var organic = false
    var secretId: String = ""
    var secretKey: String = ""
    var sdkt = ""
    var customerPhone = ""
    var customerName = ""
    var deviceToken = ""
    var appleAdsToken = ""
    var gender = ""
    var dob = ""
    var deeplinkUrl = ""
    
    init(kind: String, appToken: String, mode: String) {
        self.kind = kind
        self.appToken = appToken
        self.mode = mode
        self.lastSessionTime = ""
    }
    
    func getData() -> Dictionary<String, Any> {
        var dict = Dictionary<String, Any>()
        let installID = self.installId.lowercased()
        let createdAt = Utils.getCurrentTime()
        dict["appKey"] = self.appToken
        dict["device"] = deviceInfo?.getDeviceInfo()
        dict["createdAt"] = createdAt
        dict["mode"] = self.mode
        dict["installId"] = installID
        dict["installTime"] = self.installTime
        dict["cuid"] = customerId
        dict["cmail"] = customerEmail
        dict["installTimeMicro"] = Utils.getUnixTime(time: self.installTime)
        dict["gender"] = gender
        dict["dob"] = dob
        if (customerOptionals != nil) {
            dict["opts"] = customerOptionals
        }
        if (self.secretKey.count > 10) {
            dict["secretId"] = self.secretId
            dict["sigv"] = "v1.0.0"
            dict["signature"] = Utils.createSignature(message: installID+":"+createdAt+":"+self.secretId+":", key: self.secretKey)
        }
        dict["organic"] = organic
        dict["sdkt"] = sdkt
        dict["cphone"] = customerPhone
        dict["cname"] = customerName
        dict["iOSAttributionToken"] = appleAdsToken
        return dict
    }
    
    func getEventData() -> Dictionary<String, Any> {
        var dict = getData()
        dict["event"] = self.eventObj.getHashMap()
        return dict
    }
    
    func getSessionData() -> Dictionary<String, Any> {
        var dict = getData()
        dict["lastSessionTime"] = lastSessionTime
        return dict
    }
    
    func getDeviceToken() -> Dictionary<String, Any> {
        var dict = Dictionary<String, Any>()
        let installID = self.installId.lowercased()
        dict["deviceToken"] = self.deviceToken
        dict["appKey"] = self.appToken
        dict["installId"] = installID
        return dict
    }
    
    func getDeeplinksData() -> Dictionary<String, Any> {
        var dict = Dictionary<String, Any>()
        dict["url"] = self.deeplinkUrl
        dict["os"] = "ios"
        dict["osv"] = UIDevice.current.systemVersion
        dict["sdkv"] = Constants.SDK_VERSION
        dict["apv"] = DeviceInfo().buildInfo?["CFBundleShortVersionString"]
        dict["insId"] = TrackierSDK.getTrackierId().lowercased()
        dict["appKey"] = appToken
        return dict
    }
    
    func getDeeplinksSubscribeData() -> Dictionary<String, Any> {
            var dict = Dictionary<String, Any>()
            dict["os"] = "ios"
            dict["osv"] = UIDevice.current.systemVersion
            dict["sdkv"] = Constants.SDK_VERSION
            dict["apv"] = DeviceInfo().buildInfo?["CFBundleShortVersionString"]
            dict["insId"] = TrackierSDK.getTrackierId().lowercased()
            dict["appKey"] = appToken
            return dict
        }
}
