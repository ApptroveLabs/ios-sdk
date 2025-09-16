//
//  Constants.swift
//  trackier-ios-sdk
//
//  Created by Hemant Mann on 19/03/21.
//

import Foundation

class Constants {
    static let SDK_VERSION = "1.6.75"
    static let USER_AGENT = "com.trackier.sdk:ios-sdk:" + SDK_VERSION
    static let API_VERSION = "v1"
    static let BASE_URL = "events.trackier.io/" + API_VERSION
    static let BASE_URL_DL = "sdkr.apptracking.io/dl"
    static let INSTALL_URL = BASE_URL + "/install"
    static let EVENTS_URL = BASE_URL + "/event"
    static let SESSIONS_URL = BASE_URL + "/session"
    static let TOKEN_URL = BASE_URL + "/device-token"
    static let DEEPLINK_URL = BASE_URL_DL + "/resolver"
    static let BASE_URL_DYNAMIC_LINK = "sdkr.apptracking.io/api/v4/ug/dlg/"
    static let LOG_TAG = "com.trackier.sdk"
    static let SHARED_PREF_NAME = "com.trackier.sdk"
    static let SCHEME = "https://"
    
    static let SHARED_PREF_IS_INSTALL_TRACKED = "is_install_tracked"
    static let SHARED_PREF_INSTALL_ID = "install_id"
    static let SHARED_PREF_LAST_SESSION_TIME = "last_session_time"

    static let ENV_PRODUCTION = "production"
    static let ENV_DEVELOPMENT = "development"
    static let ENV_TESTING = "testing"

    static let DATE_TIME_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    static let UNKNOWN_EVENT = "unknown"
    static let SHARED_PREF_DEVICE_TOKEN = "deviceToken"
    
    static let SHARED_PREF_AD = "ad"
    static let SHARED_PREF_ADID = "adid"
    static let SHARED_PREF_ADSET = "adset"
    static let SHARED_PREF_ADSETID = "adsetid"
    static let SHARED_PREF_CAMPAIGN = "campaign"
    static let SHARED_PREF_CAMPAIGNID = "campaignid"
    static let SHARED_PREF_CHANNEL = "channel"
    static let SHARED_PREF_P1 = "p1"
    static let SHARED_PREF_P2 = "p2"
    static let SHARED_PREF_P3 = "p3"
    static let SHARED_PREF_P4 = "p4"
    static let SHARED_PREF_P5 = "p5"
    static let SHARED_PREF_CLICKID = "clickId"
    static let SHARED_PREF_DLV = "dlv"
    static let SHARED_PREF_PID = "pid"
    static let SHARED_PREF_ISRETARGETING = "isRetargeting"
}
