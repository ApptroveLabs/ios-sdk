//
//  APIService.swift
//  trackier-ios-sdk
//
//  Created by Hemant Mann on 19/03/21.
//

import Foundation
import Alamofire


    struct DataResponse: Codable {
        let success: Bool
    }

    public struct InstallResponse: Codable {
        public let success: Bool?
        public let message: String?
        public let ad: String?
        public let adId: String?
        public let camp: String?
        public let campId: String?
        public let adSet: String?
        public let adSetId: String?
        public let channel: String?
        public let p1: String?
        public let p2: String?
        public let p3: String?
        public let p4: String?
        public let p5: String?
        public let clickId: String?
        public let dlv: String?
        public let pid: String?
        public let sdkParams: Dictionary<String,String>?
        public let isRetargeting: Bool?
        public let data: DlData?
    }

    public struct DlData: Codable {
        public let url: String?
        public let dlv: String?
        public let sdkParams: [String: Any]?

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            url = try container.decodeIfPresent(String.self, forKey: .url)
            dlv = try container.decodeIfPresent(String.self, forKey: .dlv)
            let params = try container.decodeIfPresent([String: JSONValue].self, forKey: .sdkParams)
            sdkParams = params?.mapValues { $0.value }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(url, forKey: .url)
            try container.encodeIfPresent(dlv, forKey: .dlv)
            let params = sdkParams?.mapValues { JSONValue($0) }
            try container.encodeIfPresent(params, forKey: .sdkParams)
        }

        enum CodingKeys: String, CodingKey {
            case url
            case dlv
            case sdkParams = "sdkparams"
        }
    }
    // Helper enum to handle heterogeneous types in the dictionary
    public enum JSONValue: Codable {
        case string(String)
        case number(Double)
        case bool(Bool)
        case object([String: JSONValue])
        case array([JSONValue])
        case null

        public var value: Any {
            switch self {
            case .string(let value): return value
            case .number(let value): return value
            case .bool(let value): return value
            case .object(let value): return value
            case .array(let value): return value
            case .null: return NSNull()
            }
        }

    public init(_ value: Any) {
        if let value = value as? String {
            self = .string(value)
        } else if let value = value as? Double {
            self = .number(value)
        } else if let value = value as? Bool {
            self = .bool(value)
        } else if let value = value as? [String: Any] {
            self = .object(value.mapValues { JSONValue($0) })
        } else if let value = value as? [Any] {
            self = .array(value.map { JSONValue($0) })
        } else {
            self = .null
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode([String: JSONValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else if container.decodeNil() {
            self = .null
        } else {
            throw DecodingError.typeMismatch(JSONValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported JSON value"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .number(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .object(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        case .null: try container.encodeNil()
        }
    }
    }

    public struct DynamicLinkResponse: Codable {
        public let success: Bool
        public let message: String?
        public let error: ErrorResponse?
        public let data: LinkData?
    }

    public struct ErrorResponse: Codable {
        public let statusCode: Int
        public let errorCode: String
        public let codeMsg: String
        public let message: String
    }

    public struct LinkData: Codable {
        public let link: String
}


class APIService {
    var sessionManager = Session()          // Create a session manager 
    static var shared = APIService()

    private func request(uri : String, method: HTTPMethod, body : [String : Any], headers : HTTPHeaders?) {
        sessionManager.request(uri, method: method, parameters: body, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (responseObj) -> Void in
            Logger.debug(message: "Response is \(responseObj)")
        }
    }
    
    static func post(uri : String, body : [String : Any], headers : HTTPHeaders?){
        shared.request(uri: uri, method: HTTPMethod.post, body: body, headers: headers)
    }
    
    @available(iOS 13.0, *)
    private func requestAsync(uri: String, method: HTTPMethod, body: [String : Any], headers: HTTPHeaders?) async throws -> Data {
        try await withUnsafeThrowingContinuation { continuation in
            AF.request(uri, method: method, parameters: body, encoding: JSONEncoding.default, headers: headers).validate().responseData { response in
                if let data = response.value {
                    continuation.resume(returning: data)
                    return
                }
                if let err = response.error {
                    continuation.resume(throwing: err)
                    return
                }
                fatalError("unhandled request edge case")
            }
        }
    }
    
    @available(iOS 13.0, *)
        private func requestAsyncDynamicDeeplink(uri: String, method: HTTPMethod, body: [String : Any], headers: HTTPHeaders?) async throws -> Data {
            try await withUnsafeThrowingContinuation { continuation in
                AF.request(uri, method: method, parameters: body, encoding: JSONEncoding.default, headers: headers).validate().responseData { response in
                    switch response.result {
                    case .success(let data):
                        continuation.resume(returning: data)
                    case .failure(let error):
                        if let data = response.data, let statusCode = response.response?.statusCode {
                            continuation.resume(throwing: APIServiceError.httpError(data: data, statusCode: statusCode))
                        } else {
                            continuation.resume(throwing: error)
                        }
                    }
                }
            }
        }
    
    @available(iOS 13.0, *)
    private func requestAsyncDeeplink(uri: String, method: HTTPMethod, body: [String : Any], headers: HTTPHeaders?) async throws -> InstallResponse {
        try await withUnsafeThrowingContinuation { continuation in
            AF.request(uri, method: method, parameters: body, encoding: JSONEncoding.default, headers: headers).validate().responseData { response in
                if let data = response.value {
                    do {
                        let installResponse = try JSONDecoder().decode(InstallResponse.self, from: data)
                        continuation.resume(returning: installResponse)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                    return
                }
                if let err = response.error {
                    continuation.resume(throwing: err)
                    print("trackiersdk",err)
                    return
                }
                fatalError("unhandled request edge case")
            }
        }
    }
    
    @available(iOS 13.0, *)
    static func postAsync(uri: String, body: [String : Any], headers: HTTPHeaders?) async throws -> Data {
        return try await shared.requestAsync(uri: uri, method: HTTPMethod.post, body: body, headers: headers)
    }
    
    @available(iOS 13.0, *)
    static func postAsyncDeeplink(uri: String, body: [String : Any], headers: HTTPHeaders?) async throws -> InstallResponse {
        return try await shared.requestAsyncDeeplink(uri: uri, method: HTTPMethod.post, body: body, headers: headers)
    }
    
    @available(iOS 13.0, *)
    static func publicPostAsyncDeeplink(uri: String, body: [String : Any], headers: HTTPHeaders?) async throws -> InstallResponse {
        return try await shared.requestAsyncDeeplink(uri: uri, method: HTTPMethod.post, body: body, headers: headers)
    }
    
    @available(iOS 13.0, *)
       static func postAsyncDynamicLink(uri: String, body: [String : Any], headers: HTTPHeaders?) async throws -> DynamicLinkResponse {
           do {
               let data = try await shared.requestAsyncDynamicDeeplink(uri: uri, method: HTTPMethod.post, body: body, headers: headers)
               let decoder = JSONDecoder()
               return try decoder.decode(DynamicLinkResponse.self, from: data)
           } catch APIServiceError.httpError(let data, _) {
               let decoder = JSONDecoder()
               if let backendError = try? decoder.decode(DynamicLinkResponse.self, from: data) {
                   return backendError
               }
               return DynamicLinkResponse(success: false, message: "Unknown backend error", error: nil, data: nil)
           } catch {
               return DynamicLinkResponse(success: false, message: error.localizedDescription, error: nil, data: nil)
           }
       }
    
    enum APIServiceError: Error {
        case httpError(data: Data, statusCode: Int)
        case other(Error)
    }
}
