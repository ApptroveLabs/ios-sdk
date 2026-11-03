//
//  AppTroveBridge.swift
//  apptrove-ios-sdk
//
//  Objective-C bridge only. Swift SDK files are unchanged.
//  ObjC apps use the same class/method names as Swift docs via @objc(...) exports.
//
//  Import: @import apptrove_ios_sdk;
//

import Foundation

// MARK: - DeepLinkListener

@objc(DeepLinkListener)
public protocol ObjCDeepLinkListener: AnyObject {
    @objc func onDeepLinking(result: ObjCDeepLink)
}

private final class ObjCDeepLinkListenerAdapter: NSObject, DeepLinkListener {
    weak var delegate: ObjCDeepLinkListener?

    func onDeepLinking(result: DeepLink) {
        delegate?.onDeepLinking(result: ObjCDeepLink(deepLink: result))
    }
}

// MARK: - DeepLink

@objc(DeepLink)
public final class ObjCDeepLink: NSObject {
    private let deepLink: DeepLink

    init(deepLink: DeepLink) {
        self.deepLink = deepLink
    }

    @objc(initWithResult:)
    public init(result: String) {
        self.deepLink = DeepLink(result: result)
    }

    @objc public func getUrl() -> String { deepLink.getUrl() }
    @objc public func getMessage() -> String { deepLink.getMessage() }
    @objc public func getAd() -> String { deepLink.getAd() }
    @objc public func getAdId() -> String { deepLink.getAdId() }
    @objc public func getCamp() -> String { deepLink.getCamp() }
    @objc public func getCampId() -> String { deepLink.getCampId() }
    @objc public func getAdSet() -> String { deepLink.getAdSet() }
    @objc public func getAdSetId() -> String { deepLink.getAdSetId() }
    @objc public func getChannel() -> String { deepLink.getChannel() }
    @objc public func getP1() -> String { deepLink.getP1() }
    @objc public func getP2() -> String { deepLink.getP2() }
    @objc public func getP3() -> String { deepLink.getP3() }
    @objc public func getP4() -> String { deepLink.getP4() }
    @objc public func getP5() -> String { deepLink.getP5() }
    @objc public func getClickId() -> String { deepLink.getClickId() }
    @objc public func getDlv() -> String { deepLink.getDlv() }
    @objc public func getPid() -> String { deepLink.getPid() }
    @objc public func getSDKParams() -> String { deepLink.getSDKParams() }
    @objc(getSDKParamValueWithKey:)
    public func getSDKParamValue(key: String) -> String { deepLink.getSDKParamValue(key: key) }
    @objc(getQueryParamValueWithKey:)
    public func getQueryParamValue(key: String) -> String { deepLink.getQueryParamValue(key: key) }
    @objc public func getSDKParamsDictionary() -> NSDictionary? {
        deepLink.getSDKParamsDictionary() as NSDictionary?
    }
}

// MARK: - AppTroveSDKConfig

@objc(AppTroveSDKConfig)
public final class ObjCAppTroveSDKConfig: NSObject {
    @objc public let appToken: String
    @objc public let env: String

    private var secretId = ""
    private var secretKey = ""
    private var sdkType = "ios"
    private var sdkVersion = Constants.SDK_VERSION
    private var region: AppTroveSDKConfig.Region = .NONE
    fileprivate var deepLinkListener: ObjCDeepLinkListener?

    @objc public static let ENVIRONMENT_PRODUCTION = AppTroveSDKConfig.ENVIRONMENT_PRODUCTION
    @objc public static let ENV_DEVELOPMENT = AppTroveSDKConfig.ENV_DEVELOPMENT
    @objc public static let ENV_TESTING = AppTroveSDKConfig.ENV_TESTING

    @objc(initWithAppToken:env:)
    public init(appToken: String, env: String) {
        self.appToken = appToken
        self.env = env
    }

    @objc(setAppSecretWithSecretId:secretKey:)
    public func setAppSecret(secretId: String, secretKey: String) {
        self.secretId = secretId
        self.secretKey = secretKey
    }

    @objc(setDeeplinkListernerWithListener:)
    public func setDeeplinkListerner(listener: ObjCDeepLinkListener?) {
        deepLinkListener = listener
    }

    @objc(setSDKTypeWithSdkType:)
    public func setSDKType(sdkType: String) { self.sdkType = sdkType }

    @objc(setSDKVersionWithSdkVersion:)
    public func setSDKVersion(sdkVersion: String) { self.sdkVersion = sdkVersion }

    @objc public func setRegionIN() { region = .IN }
    @objc public func setRegionGlobal() { region = .GLOBAL }
    @objc public func setRegionNone() { region = .NONE }

    fileprivate func makeSwiftConfig(listenerAdapter: ObjCDeepLinkListenerAdapter) -> AppTroveSDKConfig {
        let config = AppTroveSDKConfig(appToken: appToken, env: env)
        if !secretId.isEmpty || !secretKey.isEmpty {
            config.setAppSecret(secretId: secretId, secretKey: secretKey)
        }
        config.setSDKType(sdkType: sdkType)
        config.setSDKVersion(sdkVersion: sdkVersion)
        config.setRegion(region)
        if let listener = deepLinkListener {
            listenerAdapter.delegate = listener
            config.setDeeplinkListerner(listener: listenerAdapter)
        }
        return config
    }
}

// MARK: - AppTroveEvent

@objc(AppTroveEvent)
public final class ObjCAppTroveEvent: NSObject {
    @objc public var orderId: String = ""
    @objc public var currency: String = ""
    @objc public var couponCode: String = ""
    @objc public var param1: String = ""
    @objc public var param2: String = ""
    @objc public var param3: String = ""
    @objc public var param4: String = ""
    @objc public var param5: String = ""
    @objc public var param6: String = ""
    @objc public var param7: String = ""
    @objc public var param8: String = ""
    @objc public var param9: String = ""
    @objc public var param10: String = ""
    @objc public var param11: String = ""
    @objc public var param12: String = ""
    @objc public var param13: String = ""
    @objc public var param14: String = ""
    @objc public var param15: String = ""
    @objc public var revenue: Double = 0
    @objc public var discount: Double = 0

    private let eventId: String
    private var customValues = [String: Any]()

    @objc(initWithId:)
    public init(id: String) {
        self.eventId = id
    }

    @objc(setRevenueWithRevenue:currency:)
    public func setRevenue(revenue: Double, currency: String) {
        self.revenue = revenue
        if currency.count == 3 { self.currency = currency }
    }

    @objc(setDiscountWithDiscount:)
    public func setDiscount(discount: Double) { self.discount = discount }

    @objc(setCouponCodeWithCouponCode:)
    public func setCouponCode(couponCode: String) { self.couponCode = couponCode }

    @objc(addEventValueWithProp:stringValue:)
    public func addEventValue(prop: String, stringValue: String) {
        customValues[prop] = stringValue
    }

    @objc(addEventValueWithProp:numberValue:)
    public func addEventValue(prop: String, numberValue: NSNumber) {
        customValues[prop] = numberValue
    }

    @objc(addEventValueWithProp:boolValue:)
    public func addEventValue(prop: String, boolValue: Bool) {
        customValues[prop] = boolValue
    }

    func makeSwiftEvent() -> AppTroveEvent {
        let event = AppTroveEvent(id: eventId)
        event.orderId = orderId
        event.currency = currency
        event.couponCode = couponCode
        event.param1 = param1
        event.param2 = param2
        event.param3 = param3
        event.param4 = param4
        event.param5 = param5
        event.param6 = param6
        event.param7 = param7
        event.param8 = param8
        event.param9 = param9
        event.param10 = param10
        event.param11 = param11
        event.param12 = param12
        event.param13 = param13
        event.param14 = param14
        event.param15 = param15
        event.revenue = revenue
        event.discount = discount
        for (key, value) in customValues {
            event.addEventValue(prop: key, val: value)
        }
        return event
    }

    @objc public static let LEVEL_ACHIEVED = AppTroveEvent.LEVEL_ACHIEVED
    @objc public static let ADD_TO_CART = AppTroveEvent.ADD_TO_CART
    @objc public static let ADD_TO_WISHLIST = AppTroveEvent.ADD_TO_WISHLIST
    @objc public static let COMPLETE_REGISTRATION = AppTroveEvent.COMPLETE_REGISTRATION
    @objc public static let TUTORIAL_COMPLETION = AppTroveEvent.TUTORIAL_COMPLETION
    @objc public static let PURCHASE = AppTroveEvent.PURCHASE
    @objc public static let SUBSCRIBE = AppTroveEvent.SUBSCRIBE
    @objc public static let START_TRIAL = AppTroveEvent.START_TRIAL
    @objc public static let ACHIEVEMENT_UNLOCKED = AppTroveEvent.ACHIEVEMENT_UNLOCKED
    @objc public static let CONTENT_VIEW = AppTroveEvent.CONTENT_VIEW
    @objc public static let TRAVEL_BOOKING = AppTroveEvent.TRAVEL_BOOKING
    @objc public static let SHARE = AppTroveEvent.SHARE
    @objc public static let INVITE = AppTroveEvent.INVITE
    @objc public static let LOGIN = AppTroveEvent.LOGIN
    @objc public static let UPDATE = AppTroveEvent.UPDATE
}

// MARK: - DynamicLink

@objc(DynamicLink)
public final class ObjCDynamicLink: NSObject {
    @objc public var templateId: String = ""
    @objc public var link: String = ""
    @objc public var domainUriPrefix: String = ""
    @objc public var deepLinkValue: String = ""
    @objc public var channel: String = ""
    @objc public var campaign: String = ""
    @objc public var mediaSource: String = ""
    @objc public var p1: String = ""
    @objc public var p2: String = ""
    @objc public var p3: String = ""
    @objc public var p4: String = ""
    @objc public var p5: String = ""
    @objc public var iosRedirectLink: String = ""
    @objc public var androidRedirectLink: String = ""
    @objc public var desktopRedirectLink: String = ""
    @objc public var socialTitle: String = ""
    @objc public var socialDescription: String = ""
    @objc public var socialImageLink: String = ""

    private var sdkParameters = [String: String]()

    @objc public override init() { super.init() }

    @objc(setSDKParameterWithKey:value:)
    public func setSDKParameter(key: String, value: String) {
        sdkParameters[key] = value
    }

    @objc(setSDKParametersWithParameters:)
    public func setSDKParameters(_ parameters: NSDictionary) {
        var mapped = [String: String]()
        for (key, value) in parameters {
            if let key = key as? String {
                mapped[key] = String(describing: value)
            }
        }
        sdkParameters = mapped
    }

    fileprivate func makeSwiftDynamicLink() -> DynamicLink {
        let dynamicLink = DynamicLink()
        dynamicLink.templateId = templateId
        dynamicLink.link = link
        dynamicLink.domainUriPrefix = domainUriPrefix
        dynamicLink.deepLinkValue = deepLinkValue
        dynamicLink.channel = channel
        dynamicLink.campaign = campaign
        dynamicLink.mediaSource = mediaSource
        dynamicLink.p1 = p1
        dynamicLink.p2 = p2
        dynamicLink.p3 = p3
        dynamicLink.p4 = p4
        dynamicLink.p5 = p5
        dynamicLink.sdkParameters = sdkParameters
        if !iosRedirectLink.isEmpty {
            dynamicLink.iosParameters = IosParameters(redirectLink: iosRedirectLink)
        }
        if !androidRedirectLink.isEmpty {
            dynamicLink.androidParameters = AndroidParameters(redirectLink: androidRedirectLink)
        }
        if !desktopRedirectLink.isEmpty {
            dynamicLink.desktopParameters = DesktopParameters(redirectLink: desktopRedirectLink)
        }
        if !socialTitle.isEmpty || !socialDescription.isEmpty || !socialImageLink.isEmpty {
            dynamicLink.socialMetaTagParameters = SocialMetaTagParameters(
                title: socialTitle,
                description: socialDescription,
                imageLink: socialImageLink
            )
        }
        return dynamicLink
    }
}

// MARK: - Enums

@objc(AppTroveCoarseValue)
public enum ObjCAppTroveCoarseValue: Int {
    case low = 0
    case medium = 1
    case high = 2
}

@objc(AppTroveSDKGender)
public enum ObjCAppTroveSDKGender: Int {
    case MALE = 0
    case FEMALE = 1
    case OTHERS = 2
}

// MARK: - AppTroveSDK

@objc(AppTroveSDK)
public final class ObjCAppTroveSDK: NSObject {

    private static var listenerAdapter = ObjCDeepLinkListenerAdapter()

    private override init() { super.init() }

    @objc(initializeWithConfig:)
    public static func initialize(config: ObjCAppTroveSDKConfig) {
        AppTroveSDK.initialize(config: config.makeSwiftConfig(listenerAdapter: listenerAdapter))
    }

    @objc public static func isEnabled() -> Bool { AppTroveSDK.isEnabled() }

    @objc(setEnabledWithValue:)
    public static func setEnabled(value: Bool) { AppTroveSDK.setEnabled(value: value) }

    @objc(trackEventWithEvent:)
    public static func trackEvent(event: ObjCAppTroveEvent) {
        AppTroveSDK.trackEvent(event: event.makeSwiftEvent())
    }

    @objc public static func trackSession() { AppTroveSDK.trackSession() }

    @objc(setMinSessionDurationWithVal:)
    public static func setMinSessionDuration(val: UInt64) {
        AppTroveSDK.setMinSessionDuration(val: val)
    }

    @objc(setUserIDWithUserId:)
    public static func setUserID(userId: String) { AppTroveSDK.setUserID(userId: userId) }

    @objc(setUserEmailWithUserEmail:)
    public static func setUserEmail(userEmail: String) { AppTroveSDK.setUserEmail(userEmail: userEmail) }

    @objc(setUserPhoneWithUserPhone:)
    public static func setUserPhone(userPhone: String) { AppTroveSDK.setUserPhone(userPhone: userPhone) }

    @objc(setUserNameWithUserName:)
    public static func setUserName(userName: String) { AppTroveSDK.setUserName(userName: userName) }

    @objc(setUserAdditionalDetailsWithUserAdditionalDetails:)
    public static func setUserAdditionalDetails(userAdditionalDetails: NSDictionary) {
        var mapped = [String: Any]()
        for (key, value) in userAdditionalDetails {
            if let key = key as? String { mapped[key] = value }
        }
        AppTroveSDK.setUserAdditionalDetails(userAdditionalDetails: mapped)
    }

    @objc(setGenderWithGender:)
    public static func setGender(gender: ObjCAppTroveSDKGender) {
        switch gender {
        case .MALE: AppTroveSDK.setGender(gender: .MALE)
        case .FEMALE: AppTroveSDK.setGender(gender: .FEMALE)
        case .OTHERS: AppTroveSDK.setGender(gender: .OTHERS)
        }
    }

    @objc(setDOBWithDob:)
    public static func setDOB(dob: String) { AppTroveSDK.setDOB(dob: dob) }

    @objc(trackAsOrganicWithOrganic:)
    public static func trackAsOrganic(organic: Bool) { AppTroveSDK.trackAsOrganic(organic: organic) }

    @objc public static func getAppTroveId() -> String { AppTroveSDK.getAppTroveId() }
    @objc public static func getAppToken() -> String { AppTroveSDK.getAppToken() }
    @objc public static func getAd() -> String { AppTroveSDK.getAd() }
    @objc public static func getAdID() -> String { AppTroveSDK.getAdID() }
    @objc public static func getCampaign() -> String { AppTroveSDK.getCampaign() }
    @objc public static func getCampaignID() -> String { AppTroveSDK.getCampaignID() }
    @objc public static func getAdSet() -> String { AppTroveSDK.getAdSet() }
    @objc public static func getAdSetID() -> String { AppTroveSDK.getAdSetID() }
    @objc public static func getChannel() -> String { AppTroveSDK.getChannel() }
    @objc public static func getP1() -> String { AppTroveSDK.getP1() }
    @objc public static func getP2() -> String { AppTroveSDK.getP2() }
    @objc public static func getP3() -> String { AppTroveSDK.getP3() }
    @objc public static func getP4() -> String { AppTroveSDK.getP4() }
    @objc public static func getP5() -> String { AppTroveSDK.getP5() }
    @objc public static func getClickId() -> String { AppTroveSDK.getClickId() }
    @objc public static func getDlv() -> String { AppTroveSDK.getDlv() }
    @objc public static func getPid() -> String { AppTroveSDK.getPid() }
    @objc public static func getIsRetargeting() -> String { AppTroveSDK.getIsRetargeting() }

    @objc(setDeviceTokenWithDeviceToken:)
    public static func setDeviceToken(deviceToken: String) {
        AppTroveSDK.setDeviceToken(deviceToken: deviceToken)
    }

    @objc(sendAPNTokenWithToken:)
    public static func sendAPNToken(token: String) { AppTroveSDK.sendAPNToken(token: token) }

    @objc(waitForATTUserAuthorizationWithTimeoutInterval:)
    public static func waitForATTUserAuthorization(timeoutInterval: Int) {
        AppTroveSDK.waitForATTUserAuthorization(timeoutInterval: timeoutInterval)
    }

    @objc(updateAppleAdsTokenWithToken:)
    public static func updateAppleAdsToken(token: String) {
        AppTroveSDK.updateAppleAdsToken(token: token)
    }

    @objc(updatePostbackConversion:coarseValue:completion:)
    public static func updatePostbackConversion(
        _ conversionValue: Int,
        coarseValue: ObjCAppTroveCoarseValue,
        completion: ((NSError?) -> Void)?
    ) {
        AppTroveSDK.updatePostbackConversion(
            conversionValue,
            coarseValue: mapCoarseValue(coarseValue),
            lockWindow: nil,
            completion: { completion?($0 as NSError?) }
        )
    }

    @objc(updatePostbackConversion:coarseValue:lockWindow:completion:)
    public static func updatePostbackConversion(
        _ conversionValue: Int,
        coarseValue: ObjCAppTroveCoarseValue,
        lockWindow: Bool,
        completion: ((NSError?) -> Void)?
    ) {
        AppTroveSDK.updatePostbackConversion(
            conversionValue,
            coarseValue: mapCoarseValue(coarseValue),
            lockWindow: lockWindow,
            completion: { completion?($0 as NSError?) }
        )
    }

    @objc(updatePostbackConversion:completion:)
    public static func updatePostbackConversion(
        _ conversionValue: Int,
        completion: ((NSError?) -> Void)?
    ) {
        AppTroveSDK.updatePostbackConversion(
            conversionValue,
            coarseValue: nil,
            lockWindow: nil,
            completion: { completion?($0 as NSError?) }
        )
    }

    @objc(parseDeepLinkWithUri:)
    public static func parseDeepLink(uri: String?) { AppTroveSDK.parseDeepLink(uri: uri) }

    @objc public static func subscribeAttributionlink() {
        if #available(iOS 13.0, *) { AppTroveSDK.subscribeAttributionlink() }
    }

    @objc(resolveDeeplinkUrlWithInputUrl:completion:)
    public static func resolveDeeplinkUrl(
        inputUrl: String,
        completion: @escaping (NSString?, NSString?, NSDictionary?, NSError?) -> Void
    ) {
        if #available(iOS 13.0, *) {
            AppTroveSDK.resolveDeeplinkUrl(inputUrl: inputUrl) { result in
                switch result {
                case .success(let data):
                    completion(
                        data.url as NSString?,
                        data.dlv as NSString?,
                        data.sdkParams as NSDictionary?,
                        nil
                    )
                case .failure(let error):
                    completion(nil, nil, nil, error as NSError)
                }
            }
        } else {
            completion(nil, nil, nil, NSError(
                domain: "AppTroveSDK",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "resolveDeeplinkUrl requires iOS 13+"]
            ))
        }
    }

    @objc(createDynamicLinkWithDynamicLink:onSuccess:onFailure:)
    public static func createDynamicLink(
        dynamicLink: ObjCDynamicLink,
        onSuccess: @escaping (String) -> Void,
        onFailure: @escaping (String) -> Void
    ) {
        if #available(iOS 13.0, *) {
            AppTroveSDK.createDynamicLink(
                dynamicLink: dynamicLink.makeSwiftDynamicLink(),
                onSuccess: onSuccess,
                onFailure: onFailure
            )
        } else {
            onFailure("createDynamicLink requires iOS 13+")
        }
    }

    private static func mapCoarseValue(_ value: ObjCAppTroveCoarseValue) -> AppTroveCoarseValue {
        switch value {
        case .low: return .low
        case .medium: return .medium
        case .high: return .high
        }
    }
}
