//
//  APIManager.swift
//  apptrove-ios-sdk
//
//  Created by Prakhar Srivastava on 19/03/21.
//

import Foundation
import Alamofire

class APIManager: NSObject {
    
    static let sharedInstance = APIManager()
    static let headers: HTTPHeaders  = ["User-Agent": Constants.USER_AGENT, "X-Client-SDK": Constants.SDK_VERSION]
    
    override init() {
    }
    
    static func doWork(workRequest: AppTroveWorkRequest) {
        let baseUrl: String
        switch workRequest.kind {
        case AppTroveWorkRequest.KIND_INSTALL:
            let body = workRequest.getData()
            let jsonData = Utils.convertDictToJSON(data: body)
            Logger.debug(message: "Sending install request. Body is: \(jsonData)")
            baseUrl = getBaseUrl(for: Constants.INSTALL_URL)
            APIService.post(uri: baseUrl, body: body, headers: headers)
            break;
        case AppTroveWorkRequest.KIND_EVENT:
            let body = workRequest.getEventData()
            let jsonData = Utils.convertDictToJSON(data: body)
            Logger.debug(message: "Sending event request. Body is: \(jsonData)")
            baseUrl = getBaseUrl(for: Constants.EVENTS_URL)
            APIService.post(uri: baseUrl, body: body, headers: headers)
            break;
        case AppTroveWorkRequest.KIND_SESSION:
            let body = workRequest.getSessionData()
            let jsonData = Utils.convertDictToJSON(data: body)
            Logger.debug(message: "Sending session request. Body is: \(jsonData)")
            baseUrl = getBaseUrl(for: Constants.SESSIONS_URL)
            APIService.post(uri: baseUrl, body: body, headers: headers)
            break;
        case AppTroveWorkRequest.KIND_Token:
            let body = workRequest.getDeviceToken()
            let jsonData = Utils.convertDictToJSON(data: body)
            Logger.debug(message: "Sending token request. Body is: \(jsonData)")
            baseUrl = getBaseUrl(for: Constants.TOKEN_URL)
            APIService.post(uri: baseUrl, body: body, headers: headers)
            break;
        case AppTroveWorkRequest.KIND_UNKNOWN:
            fallthrough
        default:
            break;
        }
    }
    
    @available(iOS 13.0, *)
    static func doWorkSession(workRequest: AppTroveWorkRequest) async throws -> Data {
        let body = workRequest.getSessionData()
        let jsonData = Utils.convertDictToJSON(data: body)
        Logger.debug(message: "Sending session request. Body is: \(jsonData)")
        let baseUrl = getBaseUrl(for: Constants.SESSIONS_URL)
        return try await APIService.postAsync(uri: baseUrl, body:body, headers: headers)
    }
    
    @available(iOS 13.0, *)
    static func doWorkInstall(workRequest: AppTroveWorkRequest) async throws -> Data {
        let body = workRequest.getData()
        let jsonData = Utils.convertDictToJSON(data: body)
        Logger.debug(message: "Sending install request. Body is: \(jsonData)")
        let baseUrl = getBaseUrl(for: Constants.INSTALL_URL)
        return try await APIService.postAsync(uri: baseUrl, body: body, headers: headers)
    }
    
    @available(iOS 13.0, *)
    static func doWorkDeeplinkresolver(workRequest: AppTroveWorkRequest) async throws -> InstallResponse {
        let body = workRequest.getDeeplinksData()
        let jsonData = Utils.convertDictToJSON(data: body)
        Logger.debug(message: "Sending deeplink request. Body is: \(jsonData)")
        let baseUrl = getBaseUrl(for: Constants.DEEPLINK_URL)
        return try await APIService.postAsyncDeeplink(uri: baseUrl, body: body, headers: headers)
    }
    
    static func getBaseUrl(for path: String) -> String {
        let region = AppTroveSDK.config.getRegion()
        return region.isEmpty ? "\(Constants.SCHEME)\(path)" : "\(Constants.SCHEME)\(region)-\(path)"
    }
    
    @available(iOS 13.0, *)
        static func doWorkSubscribeDeeplinkresolver(workRequest: AppTroveWorkRequest) async throws -> InstallResponse {
            let body = workRequest.getDeeplinksSubscribeData()
            let jsonData = Utils.convertDictToJSON(data: body)
            Logger.debug(message: "Sending subscribe deeplink request. Body is: \(jsonData)")
            let baseUrl = getBaseUrl(for: Constants.DEEPLINK_URL)
            return try await APIService.postAsyncDeeplink(uri: baseUrl, body: body, headers: headers)
        }
    
}
