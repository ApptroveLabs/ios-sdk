//
//  TrackierSDK.swift
//  trackier-ios-sdk
//
//  Created by Prakhar Srivastava on 18/03/21.
//

import Foundation
import os
import StoreKit

public class TrackierSDK {
    private var isInitialized = false
    private var instance = TrackierSDKInstance()
    
    static let shared = TrackierSDK()
    
    private init() {}
    
    public static func initialize(config: TrackierSDKConfig) {
            if (shared.isInitialized) {
                Logger.warning(message: "SDK Already initialized!")
                return
            }
            shared.isInitialized = true
            Logger.info(message: "Trackier SDK \(Constants.SDK_VERSION) initialized")
            shared.instance.initialize(config: config)
            
            let skanConfig = SKANManager.Configuration(
                minimumRevenueDelta: config.skanMinimumRevenueDelta,
                maximumUpdateFrequency: config.skanMaximumUpdateFrequency,
                automaticSessionTracking: config.skanAutomaticSessionTracking,
                debugMode: config.debugMode
            )
            SKANManager.shared.configure(config: skanConfig)
            if config.skanRegisterForAttribution {
                SKANManager.shared.registerForAttribution()
            }
        }
    
    public static func isEnabled() -> Bool {
        return shared.instance.isEnabled
    }
    
    public static func setEnabled(value : Bool) {
        shared.instance.isEnabled = value
    }
    
    public static func trackEvent(event: TrackierEvent) {
        if (!shared.isInitialized) {
            Logger.warning(message: "SDK Not Initialized")
            return
        }
        if (!isEnabled()) {
            Logger.warning(message: "SDK Disabled")
            return
        }
        shared.instance.trackEvent(event: event)
    }
    
    public static func trackSession() {
        if #available(iOS 13.0, *) {
            shared.instance.trackSession()
        }
    }
    
    public static func setMinSessionDuration(val: UInt64) {
        if val > 0 {
            shared.instance.minSessionDuration = Int64(val)
        }
    }
    
    public static func setUserID(userId: String) {
        shared.instance.customerId = userId
    }
    
    public static func setUserEmail(userEmail: String) {
        shared.instance.customerEmail = userEmail
    }
    
    public static func setUserAdditionalDetails(userAdditionalDetails: Dictionary<String, Any>) {
        shared.instance.customerOptionals = userAdditionalDetails
    }
    
    public static func trackAsOrganic(organic: Bool) {
        shared.instance.organic = organic
    }
    
    public static func setUserPhone(userPhone: String) {
        shared.instance.customerPhone = userPhone
    }
    
    public static func setUserName(userName: String) {
        shared.instance.customerName = userName
    }
    
    public static func getTrackierId() -> String {
        return CacheManager.getString(key: Constants.SHARED_PREF_INSTALL_ID)
    }
    
    public static func setDeviceToken(deviceToken: String) {
        let getCacheToken = CacheManager.getString(key: Constants.SHARED_PREF_DEVICE_TOKEN)
        if (!getCacheToken.elementsEqual(deviceToken)) {
            shared.instance.deviceToken = deviceToken
            shared.instance.deviceTokenApns()
            CacheManager.setString(key: Constants.SHARED_PREF_DEVICE_TOKEN, value: deviceToken)
        }
    }
    

    
    public static func waitForATTUserAuthorization(timeoutInterval: Int) {
        shared.instance.timeoutInterval = timeoutInterval
    }
    
    public static func getAd() -> String {
        return CacheManager.getString(key: Constants.SHARED_PREF_AD)
    }
    
    public static func getAdID() -> String {
        return CacheManager.getString(key: Constants.SHARED_PREF_ADID)
    }
    
    public static func getCampaign() -> String {
        return CacheManager.getString(key: Constants.SHARED_PREF_CAMPAIGN)
    }
    
    public static func getCampaignID() -> String {
        return CacheManager.getString(key: Constants.SHARED_PREF_CAMPAIGNID)
    }
    
    public static func getAdSet() -> String {
        return CacheManager.getString(key: Constants.SHARED_PREF_ADSET)
    }
    
    public static func getAdSetID() -> String {
        return CacheManager.getString(key: Constants.SHARED_PREF_ADSETID)
    }
    
    public static func getChannel() -> String {
        return CacheManager.getString(key: Constants.SHARED_PREF_CHANNEL)
    }
    
    public static func getP1() -> String {
        return CacheManager.getString(key: Constants.SHARED_PREF_P1)
    }
    
    public static func getP2() -> String {
        return CacheManager.getString(key: Constants.SHARED_PREF_P2)
    }
    
    public static func getP3() -> String {
        return CacheManager.getString(key: Constants.SHARED_PREF_P3)
    }
    
    public static func getP4() -> String {
        return CacheManager.getString(key: Constants.SHARED_PREF_P4)
    }
    
    public static func getP5() -> String {
        return CacheManager.getString(key: Constants.SHARED_PREF_P5)
    }
    
    public static func getClickId() -> String {
        return CacheManager.getString(key: Constants.SHARED_PREF_CLICKID)
    }
    
    public static func getDlv() -> String {
        return CacheManager.getString(key: Constants.SHARED_PREF_DLV)
    }
    
    public static func getPid() -> String {
        return CacheManager.getString(key: Constants.SHARED_PREF_PID)
    }
    
    public static func getIsRetargeting() -> String {
        return CacheManager.getString(key: Constants.SHARED_PREF_ISRETARGETING)
    }
    
    public static func updateAppleAdsToken(token: String) {
        shared.instance.appleAdsToken = token
    }
    
    public enum Gender {
        case MALE
        case FEMALE
        case OTHERS
    }
    
    public static func setGender(gender: Gender) {
        shared.instance.gender = String(describing: gender)
    }
    
    public static func setDOB(dob: String) {
        shared.instance.dob = dob
    }
    
    public static func parseDeepLink(uri: String?) {
        if #available(iOS 13.0, *) {
            shared.instance.parseDeepLink(uri: uri)
        } else {
            // Fallback on earlier versions
        }
    }
    
    // Updated SKAN Methods
    
    public static func configureSKAN(
        minimumRevenueDelta: Double = 1.0,
        maximumUpdateFrequency: TimeInterval = 3600,
        automaticSessionTracking: Bool = true,
        debugMode: Bool = false,
        registerForAttribution: Bool = true
    ) {
        let config = SKANManager.Configuration(
            minimumRevenueDelta: minimumRevenueDelta,
            maximumUpdateFrequency: maximumUpdateFrequency,
            automaticSessionTracking: automaticSessionTracking,
            debugMode: debugMode,
            registerForAttribution: registerForAttribution
        )
        SKANManager.shared.configure(config: config)
    }
    
    public static func registerSKAdNetwork() {
        SKANManager.shared.registerForAttribution()
    }

        public static func updateSKANConversion(revenue: Double, eventId: String? = nil, completion: ((Bool, Error?) -> Void)? = nil) {
            SKANManager.shared.updateConversionValue(revenue: revenue, eventId: eventId, completion: completion)
        }

    @available(iOS 16.1, *)
    public static func updatePostbackConversionValue(
        fineValue: Int,
        coarseValue: String,
        lockWindow: Bool,
        completion: ((Bool, Error?) -> Void)? = nil
    ) {
        guard let coarseType = SKANCoarseType(rawValue: coarseValue.lowercased()) else {
            completion?(false, SKANError.invalidCoarseValue(coarseValue))
            return
        }
        SKANManager.shared.updatePostbackConversionValue(
            fineValue: fineValue,
            coarseValue: coarseType,
            lockWindow: lockWindow,
            completion: completion
        )
    }

        public static func getCurrentSKANValues() -> (fine: Int?, coarse: String?) {
            SKANManager.shared.getCurrentValues()
        }

        @available(iOS 16.1, *)
        public static func testSKANPostback(url: URL, completion: @escaping (Bool, Error?) -> Void) {
            SKANManager.shared.testPostback(url: url, completion: completion)
        }

    public static func getAppToken() -> String? {
           return shared.instance.appToken
       }
    
    @available(iOS 13.0, *)
    public static func createDynamicLink(
        dynamicLink: DynamicLink,
        onSuccess: @escaping (String) -> Void,
        onFailure: @escaping (String) -> Void
    ) {
        Task {
            let response = await shared.instance.createDynamicLink(dynamicLink: dynamicLink)
            if response.success, let link = response.data?.link {
                onSuccess(link)
            } else {
                let errorMessage = response.error?.message ?? response.message ?? "Unknown error"
                onFailure(errorMessage)
            }
        }
    }
    
}
