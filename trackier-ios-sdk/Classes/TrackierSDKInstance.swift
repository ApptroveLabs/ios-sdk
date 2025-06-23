//
//  TrackierSDKInstance.swift
//  trackier-ios-sdk
//
//  Created by Trackier on 18/03/21.
//

import Foundation
import os
import Alamofire

class TrackierSDKInstance {
    
    var config = TrackierSDKConfig(appToken: "", env: "")
    var appToken: String = ""
    
    init() {}

    var isEnabled = true
    var isInitialized = false
    var minSessionDuration: Int64 = 10 // in seconds
    var idfa: String? = ""
    var installId = ""
    var installTime = ""
    let deviceInfo = DeviceInfo()
    
    var customerId = ""
    var customerEmail = ""
    var customerOptionals: Dictionary<String, Any>? = nil
    var organic = false
    var customerPhone = ""
    var customerName = ""
    var deviceToken = ""
    var timeoutInterval = 0
    var appleAdsToken = ""
    var gender = ""
    var dob = ""
    
    /**
     * Initialize method should be called to initialize the sdk
     */
    public func initialize(config: TrackierSDKConfig) {
        if self.isInitialized {
            return
        }
        self.config = config
        self.isInitialized = true
        self.appToken = config.appToken
        self.installId = getInstallID()
        self.installTime = getInstallTime()
        if (timeoutInterval > 0) {
            DispatchQueue.main.async(execute: {
                Timer.scheduledTimer(withTimeInterval: TimeInterval(self.timeoutInterval), repeats: false)
                { timer in
                    self._sendInstall()
                }
            })
        } else {
            _sendInstall()
        }
    }
    
    private func setInstallID(installID: String) {
        CacheManager.setString(key: Constants.SHARED_PREF_INSTALL_ID, value: installID)
    }
    
    private func getInstallTime() -> String {
        var installTime = CacheManager.getString(key: "install_time")
        if installTime == "" {
            installTime = Utils.getCurrentTime()
            CacheManager.setString(key: "install_time", value: installTime)
        }
        return installTime
    }
    
    private func getInstallID() -> String {
        var itd = CacheManager.getString(key: Constants.SHARED_PREF_INSTALL_ID)
        if itd == "" {
            itd = UUID().uuidString
            setInstallID(installID: itd)
        }
        return itd
    }
    
    private func _sendInstall() {
        DispatchQueue.global().async {
            self.trackInstall()
            if #available(iOS 13.0, *) {
                self.trackSession()
            }
        }
    }
    
    private func isInstallTracked() -> Bool {
        return CacheManager.getBool(key: Constants.SHARED_PREF_IS_INSTALL_TRACKED)
    }
    
    private func setInstallTracked() {
        CacheManager.setBool(key: Constants.SHARED_PREF_IS_INSTALL_TRACKED, value: true)
    }
    
    private func getLastSessionTime() -> Int64 {
        return CacheManager.getInt(key: Constants.SHARED_PREF_LAST_SESSION_TIME)
    }
    
    private func setLastSessionTime(val: Int64) {
        CacheManager.setInt(key: Constants.SHARED_PREF_LAST_SESSION_TIME, value: val)
    }
    
    private func makeWorkRequest(kind: String) -> TrackierWorkRequest {
        let wrk = TrackierWorkRequest(kind: kind, appToken: self.appToken, mode: self.config.env)
        if (self.config.getSDKType() != "ios") {
            deviceInfo.sdkVersion = self.config.getSDKVersion()
        }
        wrk.installId = installId
        wrk.installTime = installTime
        wrk.deviceInfo = deviceInfo
        wrk.secretId = self.config.getAppSecretId()
        wrk.secretKey = self.config.getAppSecretKey()
        wrk.sdkt = self.config.getSDKType()
        return wrk
    }
    
    //    private func trackInstall() {
    //        if (isInstallTracked()) {
    //            return
    //        }
    //        let wrk = makeWorkRequest(kind: TrackierWorkRequest.KIND_INSTALL)
    //        wrk.customerId = customerId
    //        wrk.customerEmail = customerEmail
    //        wrk.customerOptionals = customerOptionals
    //        wrk.organic = organic
    //        wrk.customerName = customerName
    //        wrk.customerPhone = customerPhone
    //        APIManager.doWork(workRequest: wrk)
    //        setInstallTracked()
    //    }
    
    private func trackInstall() {
        if (isInstallTracked()) {
            return
        }
        let wrk = makeWorkRequest(kind: TrackierWorkRequest.KIND_INSTALL)
        wrk.customerId = customerId
        wrk.customerEmail = customerEmail
        wrk.customerOptionals = customerOptionals
        wrk.organic = organic
        wrk.customerName = customerName
        wrk.customerPhone = customerPhone
        wrk.appleAdsToken = appleAdsToken
        wrk.dob = dob
        wrk.gender = gender
        DispatchQueue.global().async {
            if #available(iOS 13.0, *) {
                Task {
                    let resData = try await APIManager.doWorkInstall(workRequest: wrk)
                    let strResData = String(decoding: resData, as: UTF8.self)
                    let res = try! JSONDecoder().decode(InstallResponse.self, from: strResData.data(using: .utf8)!)
                    Utils.campaignData(res: res)
                }
            } else {
                APIManager.doWork(workRequest: wrk)
            }
        }
        setInstallTracked()
    }
    
    func trackEvent(event: TrackierEvent) {
        if (!isEnabled) {
            Logger.warning(message: "SDK Not Enabled")
            return
        }
        if (!isInitialized) {
            Logger.warning(message: "SDK Not Initialized")
        }
        if (!isInstallTracked()) {
            Logger.warning(message: "Event sent before Install was tracked")
            return
        }
        let wrk = makeWorkRequest(kind: TrackierWorkRequest.KIND_EVENT)
        wrk.customerId = customerId
        wrk.customerEmail = customerEmail
        wrk.customerOptionals = customerOptionals
        wrk.organic = organic
        wrk.customerName = customerName
        wrk.customerPhone = customerPhone
        wrk.eventObj = event
        wrk.dob = dob
        wrk.gender = gender
        DispatchQueue.global().async {
            APIManager.doWork(workRequest: wrk)
        }
    }
    
    @available(iOS 13.0, *)
    func trackSession() {
        if (!isEnabled) {
            Logger.warning(message: "SDK Not Enabled")
            return
        }
        if (!isInitialized) {
            Logger.warning(message: "SDK Not Initialized")
        }
        if (!isInstallTracked()) {
            return
        }
        let wrk = makeWorkRequest(kind: TrackierWorkRequest.KIND_SESSION)
        wrk.customerId = customerId
        wrk.customerEmail = customerEmail
        wrk.customerOptionals = customerOptionals
        wrk.organic = organic
        wrk.customerName = customerName
        wrk.customerPhone = customerPhone
        wrk.dob = dob
        wrk.gender = gender
        let lastSessionTime = getLastSessionTime()
        wrk.lastSessionTime = Utils.convertUnixTsToISO(ts: lastSessionTime)
        let currentSessionTime = Int64(Date().timeIntervalSince1970)
        if (currentSessionTime - lastSessionTime) < self.minSessionDuration {
            // Session duration is too low
            return
        }
        DispatchQueue.global().async {
            Task {
                let resData = try await APIManager.doWorkSession(workRequest: wrk)
                let strResData = String(decoding: resData, as: UTF8.self)
                let res = try! JSONDecoder().decode(DataResponse.self, from: strResData.data(using: .utf8)!)
                if (res.success == true) {
                    self.setLastSessionTime(val: currentSessionTime)
                }
            }
        }
    }
    
    @available(iOS 13.0, *)
    func deeplinkData(url: String) async throws -> InstallResponse? {
        var deeplinRes: InstallResponse? = nil
        let wrkRequest = makeWorkRequest(kind: TrackierWorkRequest.KIND_Resolver)
        wrkRequest.deeplinkUrl = url
                do {
                    deeplinRes = try await APIManager.doWorkDeeplinkresolver(workRequest: wrkRequest)
                } catch {
                    //try await APIManager.doWorkDeeplinkresolver(workRequest: wrkRequest)
                }
        return deeplinRes
    }
    
    func callDeepLinkListenerDynamic(dlObj: InstallResponse) {
        guard let dlt = config.getDeeplinkListerner() else { return }
        if let url = dlObj.data?.url{
            let resultDict: String = url 
            let dlResult = DeepLink(result: resultDict)
            dlt.onDeepLinking(result: dlResult)
        }
    }
    
    func deviceTokenApns() {
        let wrk = makeWorkRequest(kind: TrackierWorkRequest.KIND_Token)
        wrk.deviceToken = deviceToken
        DispatchQueue.global().async {
            APIManager.doWork(workRequest: wrk)
        }
    }
    
    @available(iOS 13.0, *)
    func parseDeepLink(uri: String?) {
        guard let uri = uri else { return }
        var resData: InstallResponse?
        DispatchQueue.global().async {
            Task {
                resData = try await self.deeplinkData(url: uri)
                if self.isInitialized {
                    do {
                        if let resData = resData {
                            self.callDeepLinkListenerDynamic(dlObj: resData)
                        }
                    }
                }
            }
        }
    }
    
    @available(iOS 13.0, *)
    public func createDynamicLink(dynamicLink: DynamicLink) async -> DynamicLinkResponse {
        let region = TrackierSDK.config.getRegion()
        let baseUrl: String
        let installid = getInstallID().lowercased()
        let config = dynamicLink.toDynamicLinkConfig(installId: installid, appKey: appToken)
        print("Dynamic Deeeplink body" , config.toDictionary())
        if !region.isEmpty {
                baseUrl = "\(Constants.SCHEME)\(region)-\(Constants.BASE_URL_DYNAMIC_LINK)"
            } else {
                baseUrl = "\(Constants.SCHEME)\(Constants.BASE_URL_DYNAMIC_LINK)"
           }
        do {
            print("Dynamic Deeeplink body baseurl" , baseUrl)
            let response = try await APIService.postAsyncDynamicLink(
                uri: baseUrl + "generation",
                body: config.toDictionary(),
                headers: [
                    "X-Client-SDK": Constants.SDK_VERSION,
                    "User-Agent": Constants.USER_AGENT
                ]
               
            )
            return response
        } catch {
            return DynamicLinkResponse(success: false, message: error.localizedDescription, error: nil, data: nil)
        }
    }
}
