//
//  DeepLink.swift
//  trackier-ios-sdk
//
//  Created by Sanu Gupta on 17/02/23.
//

import Foundation

public class DeepLink {
    
    //private var dictionaryData: [String: Any]
    private var deeplinkData: [String: String]
    private var url : String
    private var sdkParamsFromResponse: [String: Any]?
    
    public init(result: String) {
        //self.dictionaryData = result
        url = result
        self.deeplinkData = DeepLink.getQueryParams(uri: result)
        self.sdkParamsFromResponse = nil
    }
    
    public init(result: String, sdkParamsFromResponse: [String: Any]?) {
           url = result
           self.deeplinkData = DeepLink.getQueryParams(uri: result)
           self.sdkParamsFromResponse = sdkParamsFromResponse
       }
    
//    public func getDictData(key: String) -> String {
//        let dictData = self.dictionaryData[key]
//        if dictData == nil {
//            return ""
//        }
//        return (dictData as? String)!
//    }
    
    public func getUrl() -> String {
        return url
    }
    
    public func getMessage() -> String {
        return getMapStringVal(data: deeplinkData, key: "message")
    }
    
    public func getAd() -> String {
        return getMapStringVal(data: deeplinkData, key: "ad")
    }
    
    public func getAdId() -> String {
        return getMapStringVal(data: deeplinkData, key: "adId")
    }
    
    public func getCamp() -> String {
        return getMapStringVal(data: deeplinkData, key: "camp")
    }
    
    public func getCampId() -> String {
        return getMapStringVal(data: deeplinkData, key: "campId")
    }
    
    public func getAdSet() -> String {
        return getMapStringVal(data: deeplinkData, key: "adSet")
    }
    
    public func getAdSetId() -> String {
        return getMapStringVal(data: deeplinkData, key: "adSetId")
    }
    
    public func getChannel() -> String {
        return getMapStringVal(data: deeplinkData, key: "channel")
    }
    
    public func getP1() -> String {
        return getMapStringVal(data: deeplinkData, key: "p1")
    }
    
    public func getP2() -> String {
        return getMapStringVal(data: deeplinkData, key: "p2")
    }
    
    public func getP3() -> String {
        return getMapStringVal(data: deeplinkData, key: "p3")
    }
    
    public func getP4() -> String {
        return getMapStringVal(data: deeplinkData, key: "p4")
    }
    
    public func getP5() -> String {
        return getMapStringVal(data: deeplinkData, key: "p5")
    }
    
    public func getClickId() -> String {
        return getMapStringVal(data: deeplinkData, key: "clickId")
    }
    
    public func getDlv() -> String {
        return getMapStringVal(data: deeplinkData, key: "dlv")
    }
    
    public func getPid() -> String {
        return getMapStringVal(data: deeplinkData, key: "pid")
    }
    
//    public func getSDKParams() -> String {
//        return getMapStringVal(data: deeplinkData, key: "sdkparams")
//    }
    
    // Updated method to get SDK parameters from both URL and response
      public func getSDKParams() -> String {
          // First try to get from URL parameters
          let urlParams = getMapStringVal(data: deeplinkData, key: "sdkparams")

          // If URL has SDK params, return them
          if !urlParams.isEmpty {
              return urlParams
          }

          // If no URL params, try to convert response params to string
          if let responseParams = sdkParamsFromResponse {
              return convertSDKParamsToString(responseParams)
          }

          return ""
      }

      // New method to get SDK parameters as dictionary (from response)
      public func getSDKParamsDictionary() -> [String: Any]? {
          return sdkParamsFromResponse
      }

      // New method to get specific SDK parameter value
      public func getSDKParamValue(key: String) -> String {
          // First check URL parameters
          let urlParams = getMapStringVal(data: deeplinkData, key: "sdkParams")
          if !urlParams.isEmpty {
              let params = parseSDKParamsString(urlParams)
              return params[key] ?? ""
          }

          // Then check response parameters
          if let responseParams = sdkParamsFromResponse {
              if let value = responseParams[key] {
                  return String(describing: value)
              }
          }

          return ""
      }

      // Helper method to convert SDK params dictionary to string
      private func convertSDKParamsToString(_ params: [String: Any]) -> String {
          var paramStrings: [String] = []

          for (key, value) in params {
              let stringValue = String(describing: value)
              if let encodedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                   paramStrings.append("\(key)=\(encodedValue)")
              }
          }

          return paramStrings.joined(separator: "&")
      }

      // Helper method to parse SDK params string
      private func parseSDKParamsString(_ sdkParams: String) -> [String: String] {
          var params: [String: String] = [:]
          let pairs = sdkParams.components(separatedBy: "&")

          for pair in pairs {
              let keyValue = pair.components(separatedBy: "=")
              if keyValue.count == 2 {
                  params[keyValue[0]] = keyValue[1]
              }
          }

          return params
      }
    
//    static func parseDeeplinkData(res: InstallResponse) -> DeepLink {
//        var dict = Dictionary<String, Any>()
//        dict["ad"] = res.ad
//        dict["adId"] = res.adId
//        dict["adSetId"] = res.adSetId
//        dict["camp"] = res.camp
//        dict["campId"] = res.campId
//        dict["adSet"] = res.adSet
//        dict["adSetId"] = res.adSetId
//        dict["channel"] = res.channel
//        dict["message"] = res.message
//        dict["p1"] = res.p1
//        dict["p2"] = res.p2
//        dict["p3"] = res.p3
//        dict["p4"] = res.p4
//        dict["p5"] = res.p5
//        dict["clickId"] = res.clickId
//        dict["dlv"] = res.dlv
//        dict["pid"] = res.pid
//        dict["sdkParams"] = res.sdkParams
//        dict["isRetargeting"] = res.isRetargeting
//        return DeepLink(result: dict)
//    }
//
//   public func getUrlParams() -> String {
//        let queryItems = [URLQueryItem(name: "dlv", value: getDlv()), URLQueryItem(name: "pid", value: getPid()), URLQueryItem(name: "message", value: getMessage()), URLQueryItem(name: "adId", value: getAdId()), URLQueryItem(name: "adSetId", value: getAdSet()), URLQueryItem(name: "campaign", value: getCamp()), URLQueryItem(name: "campaignId", value: getCampId()), URLQueryItem(name: "channel", value: getChannel()), URLQueryItem(name: "p1", value: getP1()), URLQueryItem(name: "p2", value: getP2()), URLQueryItem(name: "p3", value: getP3()), URLQueryItem(name: "p4", value: getP4()), URLQueryItem(name: "p5", value: getP5())]
//            
//        let queryStr = Utils.makeQueryString(queryItems)
//        if (queryStr != nil) {
//            return queryStr!
//        }
//        return ""
//    }
//    
    func getMapStringVal(data: [String: String], key: String) -> String {
        if data.keys.contains(key) {
            return data[key] ?? ""
        } else {
            return ""
        }
    }
    
    static func getQueryParams(uri: String) -> [String: String] {
            var map = [String: String]()
            let decodedUrl = uri // Optionally decode the URL string if needed

            do {
                let urlParts = decodedUrl.components(separatedBy: "?")
                var query = decodedUrl
                if urlParts.count == 1 {
                    query = urlParts[0]
                } else if urlParts.count >= 2 {
                    query = urlParts[1]
                }

                let params = query.components(separatedBy: "&")
                for param in params {
                    let modifiedParam = param.components(separatedBy: "#")
                    let parts = modifiedParam[0].components(separatedBy: "=")
                    if parts.count == 2 {
                        let name = parts[0]
                        if let value = parts[1].removingPercentEncoding {
                            map[name] = value
                        }
                    }
                }
            } catch {
                print("Error parsing query params: \(error)")
            }
            return map
        }
    
    
}
