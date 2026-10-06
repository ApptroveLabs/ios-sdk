//
//  AppTroveSDKInstance.swift
//  apptrove-ios-sdk
//
//  Created by AppTrove on 18/03/21.
//

import Foundation
import os
import Alamofire
import StoreKit
import AppTrackingTransparency

class AppTroveSDKInstance {
    
    var config = AppTroveSDKConfig(appToken: "", env: "")
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

    // Prevents overlapping session / skan compute calls on cold start.
    private var isSessionInFlight = false
    private let sessionLock = NSLock()
    private var lastSkanComputeAt: [String: TimeInterval] = [:]
    private let skanDedupeLock = NSLock()
    private let skanDedupeWindowSeconds: TimeInterval = 5

    // Deferred deeplink resolver needs the install on the backend first,
    // so subscribe requests are held until the install request has finished.
    private var isInstallRequestDone = false
    private var isDeferredDeeplinkPending = false
    private let deferredDeeplinkLock = NSLock()

    // Events tracked after initialize() but before the install is sent
    // (e.g. while waiting for ATT) are queued and sent once the install request is done.
    private var pendingEvents: [AppTroveEvent] = []
    private let pendingEventsLock = NSLock()

    /**
     * Initialize method should be called to initialize the sdk
     */
    public func initialize(config: AppTroveSDKConfig) {
        if self.isInitialized {
            return
        }
        self.config = config
        self.isInitialized = true
        self.appToken = config.appToken
        self.installId = getInstallID()
        self.installTime = getInstallTime()

        // Register with SKAdNetwork once. Later CV comes from skan compute API.
        if !CacheManager.getBool(key: Constants.SHARED_PREF_IS_SKAN_INITIALIZED) {
            if #available(iOS 15.4, *) {
                SKAdNetwork.updatePostbackConversionValue(0, completionHandler: { error in
                    if let error = error {
                        Logger.error(message: "SKAdNetwork initial registration failed: \(error.localizedDescription)")
                    } else {
                        Logger.info(message: "SKAdNetwork initial registration succeeded with value 0")
                        CacheManager.setBool(key: Constants.SHARED_PREF_IS_SKAN_INITIALIZED, value: true)
                    }
                })
            } else if #available(iOS 14.0, *) {
                SKAdNetwork.registerAppForAdNetworkAttribution()
                CacheManager.setBool(key: Constants.SHARED_PREF_IS_SKAN_INITIALIZED, value: true)
            }
        } else {
            Logger.info(message: "SKAdNetwork registration SKIPPED (Already registered)")
        }
        
        // Install already tracked on a previous launch, resolver can find it
        if isInstallTracked() {
            markInstallRequestDone()
        }

        if (timeoutInterval > 0) {
            let deadline = Date().addingTimeInterval(TimeInterval(timeoutInterval))
            DispatchQueue.main.async {
                self.sendInstallAfterATT(deadline: deadline)
            }
        } else {
            _sendInstall()
        }
    }

    // Sends the install as soon as the user answers the ATT prompt,
    // or when the timeout passed to waitForATTUserAuthorization expires.
    private func sendInstallAfterATT(deadline: Date) {
        if #available(iOS 14, *),
           ATTrackingManager.trackingAuthorizationStatus == .notDetermined,
           Date() < deadline {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.sendInstallAfterATT(deadline: deadline)
            }
            return
        }
        _sendInstall()
    }

    private func markInstallRequestDone() {
        deferredDeeplinkLock.lock()
        isInstallRequestDone = true
        let shouldResolve = isDeferredDeeplinkPending
        isDeferredDeeplinkPending = false
        deferredDeeplinkLock.unlock()

        // Events queued before the install go out once the install request is done
        flushPendingEvents()

        if shouldResolve, #available(iOS 13.0, *) {
            Logger.debug(message: "Install request finished, resolving pending deferred deeplink")
            resolveDeferredDeepLink()
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
            itd = UUID().uuidString.lowercased()
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

    // Calendar day in local timezone
    private func currentSessionDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func getLastSessionDate() -> String {
        return CacheManager.getString(key: Constants.SHARED_PREF_LAST_SESSION_DATE)
    }

    private func setLastSessionDate(_ date: String) {
        CacheManager.setString(key: Constants.SHARED_PREF_LAST_SESSION_DATE, value: date)
    }
    
    private func makeWorkRequest(kind: String) -> AppTroveWorkRequest {
        let wrk = AppTroveWorkRequest(kind: kind, appToken: self.appToken, mode: self.config.env)
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
    //        let wrk = makeWorkRequest(kind: AppTroveWorkRequest.KIND_INSTALL)
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
        let wrk = makeWorkRequest(kind: AppTroveWorkRequest.KIND_INSTALL)
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
                    defer { self.markInstallRequestDone() }
                    do {
                        let resData = try await APIManager.doWorkInstall(workRequest: wrk)
                        if let res = try? JSONDecoder().decode(InstallResponse.self, from: resData) {
                            Utils.campaignData(res: res)
                        } else {
                            Logger.debug(message: "Install response could not be decoded")
                        }
                    } catch {
                        Logger.error(message: "Install request failed: \(error.localizedDescription)")
                    }
                }
            } else {
                APIManager.doWork(workRequest: wrk)
                self.markInstallRequestDone()
            }
        }
        setInstallTracked()
    }

    private func flushPendingEvents() {
        pendingEventsLock.lock()
        let events = pendingEvents
        pendingEvents.removeAll()
        pendingEventsLock.unlock()

        if !events.isEmpty {
            Logger.debug(message: "Sending \(events.count) event(s) queued before install")
        }
        for event in events {
            trackEvent(event: event)
        }
    }
    
    func trackEvent(event: AppTroveEvent) {
        if (!isEnabled) {
            Logger.warning(message: "SDK Not Enabled")
            return
        }
        if (!isInitialized) {
            Logger.warning(message: "SDK Not Initialized")
        }
        if (!isInstallTracked()) {
            if isInitialized {
                pendingEventsLock.lock()
                pendingEvents.append(event)
                pendingEventsLock.unlock()
                // Install request may have finished while queueing; flush so nothing is stranded
                deferredDeeplinkLock.lock()
                let installDone = isInstallRequestDone
                deferredDeeplinkLock.unlock()
                if installDone {
                    flushPendingEvents()
                }
                Logger.debug(message: "Event queued until Install is tracked")
            } else {
                Logger.warning(message: "Event sent before Install was tracked")
            }
            return
        }
        let wrk = makeWorkRequest(kind: AppTroveWorkRequest.KIND_EVENT)
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
            // Call skan compute after event is sent
            self.requestSkanCompute(
                eventId: event.id,
                revenue: event.revenue,
                currency: event.currency
            )
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

        sessionLock.lock()
        if isSessionInFlight {
            sessionLock.unlock()
            Logger.debug(message: "Session already in flight, skip duplicate")
            return
        }

        // send session API at most once per local calendar day.
        let currentDate = currentSessionDateString()
        let lastSessionDate = getLastSessionDate()
        if lastSessionDate == currentDate {
            sessionLock.unlock()
            Logger.debug(message: "Session already called for today")
            return
        }

        let lastSessionTime = getLastSessionTime()
        let currentSessionTime = Int64(Date().timeIntervalSince1970)
        // Keep minSessionDuration as an extra safety throttle (default 10s).
        if (currentSessionTime - lastSessionTime) < self.minSessionDuration {
            // Session duration is too low
            sessionLock.unlock()
            return
        }
        isSessionInFlight = true
        sessionLock.unlock()

        let wrk = makeWorkRequest(kind: AppTroveWorkRequest.KIND_SESSION)
        wrk.customerId = customerId
        wrk.customerEmail = customerEmail
        wrk.customerOptionals = customerOptionals
        wrk.organic = organic
        wrk.customerName = customerName
        wrk.customerPhone = customerPhone
        wrk.dob = dob
        wrk.gender = gender
        wrk.lastSessionTime = Utils.convertUnixTsToISO(ts: lastSessionTime)

        DispatchQueue.global().async {
            Task {
                defer {
                    self.sessionLock.lock()
                    self.isSessionInFlight = false
                    self.sessionLock.unlock()
                }
                do {
                    let resData = try await APIManager.doWorkSession(workRequest: wrk)
                    let strResData = String(decoding: resData, as: UTF8.self)
                    if let data = strResData.data(using: .utf8),
                       let res = try? JSONDecoder().decode(DataResponse.self, from: data),
                       res.success == true {
                        self.setLastSessionTime(val: currentSessionTime)
                        self.setLastSessionDate(currentDate)
                        // Skan compute only after a successful session
                        self.requestSkanCompute(
                            eventId: "session",
                            revenue: 0,
                            currency: ""
                        )
                    } else {
                        Logger.debug(message: "Session request returned success=false, skip skan compute")
                    }
                } catch {
                    Logger.debug(message: "Session request failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @available(iOS 13.0, *)
    func deeplinkData(url: String) async throws -> InstallResponse? {
        var deeplinRes: InstallResponse? = nil
        let wrkRequest = makeWorkRequest(kind: AppTroveWorkRequest.KIND_Resolver)
//        wrkRequest.deeplinkUrl = url
//                do {
//                    deeplinRes = try await APIManager.doWorkDeeplinkresolver(workRequest: wrkRequest)
//                } catch {
//                    //try await APIManager.doWorkDeeplinkresolver(workRequest: wrkRequest)
//                }
        wrkRequest.deeplinkUrl = url ?? ""  // Handle nil URL
               do {
                   deeplinRes = try await APIManager.doWorkDeeplinkresolver(workRequest: wrkRequest)
               } catch {
                   Logger.error(message: "Failed to resolve deep link: \(error.localizedDescription)")
               }
        return deeplinRes
    }
    
    func callDeepLinkListenerDynamic(dlObj: InstallResponse) {
        guard let dlt = config.getDeeplinkListerner() else { return }
        if let url = dlObj.data?.url{
            let resultDict: String = url 
           // let dlResult = DeepLink(result: resultDict)
            // Pass SDK parameters from API response to DeepLink
            let sdkParamsFromResponse = dlObj.data?.sdkParams
            let dlResult = DeepLink(result: resultDict, sdkParamsFromResponse: sdkParamsFromResponse)
            dlt.onDeepLinking(result: dlResult)
        }
    }
    
    func deviceTokenApns() {
        let wrk = makeWorkRequest(kind: AppTroveWorkRequest.KIND_Token)
        wrk.deviceToken = deviceToken
        DispatchQueue.global().async {
            APIManager.doWork(workRequest: wrk)
        }
    }
    
    @available(iOS 13.0, *)
    func parseDeepLink(uri: String?) {
        guard let uri = uri else { return }
        // Full link resolver check 
        let urlParams = DeepLink.getQueryParams(uri: uri)
        if uri.contains("?") && !urlParams.isEmpty {
            DispatchQueue.global().async {
                if self.isInitialized, let dlt = self.config.getDeeplinkListerner() {
                    let dl = DeepLink(result: uri)
                    dlt.onDeepLinking(result: dl)
                }
            }
            return
        }
        DispatchQueue.global().async {
            Task {
                do {
                    if let resData = try await self.deeplinkData(url: uri) {
                        if self.isInitialized {
                            self.callDeepLinkListenerDynamic(dlObj: resData)
                        }
                    }
                } catch {
                    Logger.error(message: "Failed to parse deep link: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @available(iOS 13.0, *)
    public func createDynamicLink(dynamicLink: DynamicLink) async -> DynamicLinkResponse {
        let region = AppTroveSDK.config.getRegion()
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
    
    @available(iOS 13.0, *)
    func subscribeDeepLinkData() {
        deferredDeeplinkLock.lock()
        if !isInstallRequestDone {
            // Resolved from markInstallRequestDone() once the install is sent
            isDeferredDeeplinkPending = true
            deferredDeeplinkLock.unlock()
            Logger.debug(message: "Install not sent yet, deferred deeplink will resolve after install")
            return
        }
        deferredDeeplinkLock.unlock()
        resolveDeferredDeepLink()
    }

    @available(iOS 13.0, *)
    private func resolveDeferredDeepLink() {
        var deeplinRes: InstallResponse? = nil
        let wrkRequest = makeWorkRequest(kind: AppTroveWorkRequest.KIND_Resolver)
        DispatchQueue.global().async {
            Task {
                wrkRequest.deeplinkUrl = ""
                do {
                    deeplinRes = try await APIManager.doWorkSubscribeDeeplinkresolver(workRequest: wrkRequest)
                    if self.isInitialized {
                        self.callDeepLinkListenerDynamic(dlObj: deeplinRes!)
                    }
                } catch {
                    //try await APIManager.doWorkDeeplinkresolver(workRequest: wrkRequest)
                }
                
            }
        }
    }
    
    func sendAPNToken(token: String) {
        if token.isEmpty {
            Logger.warning(message: "APN token is empty")
            return
        }
        
        Logger.info(message: "Sending APN token: \(token)")
        
        // Get app version
        let appVersion = deviceInfo.buildInfo?["CFBundleShortVersionString"] as? String ?? ""
        let installID = getInstallID().lowercased()
        
        // Create request body
        let body: [String: Any] = [
            "app_key": appToken,
            "apv": appVersion,
            "insid": installID,
            "token": token
        ]
        
        // Send token with delay to ensure install data is processed first
        DispatchQueue.global().async {
            APIManager.doWorkTokenIngest(body: body)
        }
    }
    
    func updatePostbackConversion(
        _ conversionValue: Int,
        coarseValue: AppTroveCoarseValue?,
        lockWindow: Bool?,
        completion: ((Error?) -> Void)?
    ) {
        guard (0...63).contains(conversionValue) else {
            let err = NSError(domain: "AppTrove", code: -1, userInfo: [NSLocalizedDescriptionKey: "SKAdNetwork conversion value must be between 0 and 63."])
            completion?(err)
            return
        }
        
        let isLocked = lockWindow ?? false
        
        if #available(iOS 16.1, *) {
            if let cv = coarseValue {
                let skanCoarseValue: SKAdNetwork.CoarseConversionValue
                switch cv {
                case .high: skanCoarseValue = .high
                case .medium: skanCoarseValue = .medium
                case .low: skanCoarseValue = .low
                }
                
                SKAdNetwork.updatePostbackConversionValue(conversionValue, coarseValue: skanCoarseValue, lockWindow: isLocked) { error in
                    completion?(error)
                }
            } else {
                SKAdNetwork.updatePostbackConversionValue(conversionValue) { error in
                    completion?(error)
                }
            }
        } else if #available(iOS 15.4, *) {
            SKAdNetwork.updatePostbackConversionValue(conversionValue) { error in
                completion?(error)
            }
        } else if #available(iOS 14.5, *) {
            SKAdNetwork.updateConversionValue(conversionValue)
            completion?(nil)
        } else {
            let err = NSError(domain: "AppTrove", code: -1, userInfo: [NSLocalizedDescriptionKey: "SKAdNetwork update not supported on this iOS version."])
            completion?(err)
        }
    }

    // MARK: - SKAN compute

    // Calls skan compute API. Safe if API is down or body is bad.
    private func requestSkanCompute(eventId: String, revenue: Double?, currency: String?) {
        // Skip duplicate compute for same e_id within a short window (cold-start races).
        skanDedupeLock.lock()
        let now = Date().timeIntervalSince1970
        if let last = lastSkanComputeAt[eventId], (now - last) < skanDedupeWindowSeconds {
            skanDedupeLock.unlock()
            Logger.debug(message: "[SKAN] skip duplicate compute for e_id=\(eventId)")
            return
        }
        lastSkanComputeAt[eventId] = now
        skanDedupeLock.unlock()

        guard let body = SkanComputeRequestBuilder.makeBody(
            appKey: appToken,
            installId: installId,
            installTs: installTime,
            idfa: deviceInfo.getIDFA(),
            eventTs: Utils.getCurrentTime(),
            eventId: eventId,
            revenue: revenue,
            currency: currency
        ) else {
            return
        }

        APIManager.computeSkan(body: body) { [weak self] response in
            self?.applySkanComputeResponse(response)
        }
    }

    // Update Apple only when success and active are both true.
    private func applySkanComputeResponse(_ response: SkanComputeResponse?) {
        guard let response = response else { return }

        let msg = response.message ?? ""

        guard response.isSuccess else {
            Logger.warning(message: "[SKAN] failed: \(msg)")
            return
        }

        guard response.shouldApplyToApple else {
            Logger.debug(message: "[SKAN] active is false, skip Apple update. \(msg)")
            return
        }

        guard let fineCv = response.validFineCv else {
            Logger.warning(message: "[SKAN] fine_cv is invalid: \(String(describing: response.data?.fineCv))")
            return
        }

        let coarse = response.mappedCoarseValue
        let lock = response.lockWindow

        Logger.info(message: "[SKAN] update Apple CV fine=\(fineCv) coarse=\(String(describing: coarse?.rawValue)) lock=\(lock). \(msg)")

        updatePostbackConversion(fineCv, coarseValue: coarse, lockWindow: lock) { error in
            if let error = error {
                Logger.error(message: "[SKAN] Apple update failed: \(error.localizedDescription)")
            } else {
                Logger.info(message: "[SKAN] Apple update done")
            }
        }
    }
}
