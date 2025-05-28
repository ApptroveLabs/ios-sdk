//
//  TrackierSDKConfig.swift
//  trackier-ios-sdk
//
//  Created by Prakhar Srivastava on 18/03/21.
//

import Foundation

public class TrackierSDKConfig {
    public static let ENVIRONMENT_PRODUCTION = Constants.ENV_PRODUCTION
    public static let ENV_DEVELOPMENT = Constants.ENV_DEVELOPMENT
    public static let ENV_TESTING = Constants.ENV_TESTING

    
    // SKAN Properties
    public private(set) var skanMinimumRevenueDelta: Double = 1.0
        public private(set) var skanMaximumUpdateFrequency: TimeInterval = 3600
        public private(set) var skanAutomaticSessionTracking: Bool = true
        public private(set) var skanRegisterForAttribution: Bool = true
        public private(set) var debugMode: Bool = false
    
    var appToken: String
    var env: String
    var secretId: String = ""
    var secretKey: String = ""
    var sdkt: String = "ios"
    var sdkVersion: String = Constants.SDK_VERSION

    private var deeplinkListener: DeepLinkListener? = nil

    public init(appToken: String, env: String) {
        self.appToken = appToken
        self.env = env
        if env == TrackierSDKConfig.ENVIRONMENT_PRODUCTION {
            Logger.setLogLevel(level: Logger.LEVEL_ERROR)
        } else {
            Logger.setLogLevel(level: Logger.LEVEL_DEBUG)
        }
    }
    
    public func setAppSecret(secretId: String, secretKey: String) {
        self.secretId = secretId
        self.secretKey = secretKey
    }
    
    func getAppSecretId() -> String {
        return self.secretId
    }
    
    func getAppSecretKey() -> String {
        return self.secretKey
    }

    func setLogLevel(level: UInt) {
        Logger.setLogLevel(level: level)
    }
    
    func getSDKType() -> String {
        return self.sdkt
    }
    
    public func setSDKType(sdkType: String) {
        self.sdkt = sdkType
    }
    
    func getSDKVersion() -> String {
       return self.sdkVersion
    }
    
    public func setSDKVersion(sdkVersion: String) {
        self.sdkVersion = sdkVersion
    }

    public func setDeeplinkListerner(listener: DeepLinkListener) {
        self.deeplinkListener = listener
    }

    public func getDeeplinkListerner() -> DeepLinkListener? {
        return self.deeplinkListener;
    }
    
    // MARK: - SKAN Configuration Methods
    
    public func setSKANMinimumRevenueDelta(_ delta: Double) -> Self { self.skanMinimumRevenueDelta = delta; return self }
        public func setSKANMaximumUpdateFrequency(_ frequency: TimeInterval) -> Self { self.skanMaximumUpdateFrequency = frequency; return self }
        public func setSKANAutomaticSessionTracking(_ enabled: Bool) -> Self { self.skanAutomaticSessionTracking = enabled; return self }
        public func setSKANRegisterForAttribution(_ register: Bool) -> Self { self.skanRegisterForAttribution = register; return self }
        public func setDebugMode(_ enabled: Bool) -> Self { self.debugMode = enabled; return self }
}
