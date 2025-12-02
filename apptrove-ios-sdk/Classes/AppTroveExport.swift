//
//  AppTroveExport.swift
//  AppTroveSDK
//
//  Created by Sanu Gupta on 20/10/22.
//

import Foundation

@_cdecl("AppTroveSDK_initialize")
public func initialize(initParam: UnsafePointer<CChar>?)  {
    let initParam = String(cString: initParam!)
    let initData = try! JSONDecoder().decode(InitData.self, from: initParam.data(using: .utf8)!)
    let sdkConfigs = AppTroveSDKConfig.init(appToken: initData.appKey, env: initData.env)
    sdkConfigs.sdkt = initData.setSDKType
    sdkConfigs.sdkVersion = initData.setSDKVersion
    sdkConfigs.setSDKVersion(sdkVersion: "1.6.59")
    AppTroveSDK.initialize(config: sdkConfigs)
}

@_cdecl("AppTroveSDK_setUserID")
public func setUserID(userID: UnsafePointer<CChar>?)  {
    let userId = String(cString: userID!)
    AppTroveSDK.setUserID(userId: userId)
}

@_cdecl("AppTroveSDK_setUserEmail")
public func setUserEmail(userEmail: UnsafePointer<CChar>?) {
    let userEmail = String(cString: userEmail!)
    AppTroveSDK.setUserEmail(userEmail: userEmail)
}

@_cdecl("AppTroveSDK_setUserPhone")
public func setUserPhone(userPhone: UnsafePointer<CChar>?) {
    let userPhone = String(cString: userPhone!)
    AppTroveSDK.setUserPhone(userPhone: userPhone)
}

@_cdecl("AppTroveSDK_setUserName")
public func setUserName(userName: UnsafePointer<CChar>?) {
    let userName = String(cString: userName!)
    AppTroveSDK.setUserName(userName: userName)
}

@_cdecl("AppTroveSDK_TrackEvent")
public func TrackEvent(eventId: UnsafePointer<CChar>?, eventParam: UnsafePointer<CChar>?) {
    let trackEvent = String(cString: eventId!)
    let event = AppTroveEvent(id: trackEvent)
    let eventParamJson = String(cString: eventParam!)
    let eventsData = try! JSONDecoder().decode(EventsExtraParam.self, from: eventParamJson.data(using: .utf8)!)
    event.couponCode = eventsData.couponCode
    event.orderId = eventsData.orderId
    event.discount = Float64(eventsData.discount)
    event.currency = eventsData.currency
    event.revenue = Float64(eventsData.revenue)
    event.param1 = eventsData.param1
    event.param2 = eventsData.param2
    event.param3 = eventsData.param3
    event.param4 = eventsData.param4
    event.param5 = eventsData.param5
    event.param6 = eventsData.param6
    event.param7 = eventsData.param7
    event.param8 = eventsData.param8
    event.param9 = eventsData.param9
    event.param10 = eventsData.param10
    AppTroveSDK.trackEvent(event: event)
}

struct EventsExtraParam: Decodable {
    let orderId: String
    let discount: String
    let revenue: String
    let couponCode: String
    let currency: String
    var param1: String
    var param2: String
    let param3: String
    let param4: String
    let param5: String
    let param6: String
    let param7: String
    let param8: String
    let param9: String
    let param10: String
}

struct InitData: Decodable {
    let appKey: String
    let env: String
    let setSDKVersion: String
    let setSDKType: String
    
}
