//
//  DeviceInfo.swift
//  trackier-ios-sdk
//
//  Created by Prakhar Srivastava on 19/03/21.
//  Modified by Hemant Mann
//

import Foundation
import AppTrackingTransparency
import AdSupport
import UIKit

private let CTL_KERN: Int32 = 1
private let KERN_BOOTTIME: Int32 = 21

class DeviceInfo {
    
    let buildInfo = Bundle.main.infoDictionary
    var name = UIDevice.current.name
    var systemVersion = UIDevice.current.systemVersion
    var model = UIDevice.current.model
    var batteryLevel = UIDevice.current.batteryLevel
    var isBatteryMonitoringEnabled = UIDevice.current.isBatteryMonitoringEnabled
    var idfv = UIDevice.current.identifierForVendor?.uuidString
    var sdkVersion = Constants.SDK_VERSION
    
    public func getDeviceInfo() -> Dictionary<String, Any> {
        var dict = Dictionary<String, Any>()
        #if os(iOS)
        dict["osName"] = "iOS"
        #elseif os(watchOS)
        dict["osName"] = "watchOS"
        #elseif os(tvOS)
        dict["osName"] = "tvOS"
        #endif
        
        dict["name"] = name
        dict["buildName"] = buildInfo?["BuildMachineOSBuild"]
        dict["osVersion"] = systemVersion
        dict["manufacturer"] = "Apple"
        dict["hardwareName"] = name
        dict["model"] = model
        dict["apiLevel"] = buildInfo?["DTPlatformBuild"]
        dict["brand"] = model
        dict["packageName"] = buildInfo?["CFBundleIdentifier"]
        dict["appVersion"] = buildInfo?["CFBundleShortVersionString"]
        dict["appNumericVersion"] = buildInfo?["CFBundleNumericVersion"]
        dict["sdkVersion"] = sdkVersion
        dict["language"] = Locale.current.languageCode
        dict["country"] = NSLocale.current.regionCode
        dict["timezone"] = TimeZone.current.identifier
        dict["screenSize"] = getScreenSize()
        dict["screenDensity"] = getScreenDensity()
        dict["screenFormat"] = name
        // TODO: screenSize,screenDensity?
        dict["batteryLevel"] = batteryLevel
        dict["ibme"] = isBatteryMonitoringEnabled
        dict["idfv"] = idfv
        dict["idfa"] = getIDFA()
        dict["appInstallTime"] = getAppInstallTime()
        dict["appUpdateTime"] = getAppUpdateTime()
        dict["bootTime"] = getBootTime()
        if (Locale.current.languageCode != nil) {
             dict["locale"] = Locale.current.languageCode!
        }       
        #if targetEnvironment(simulator)
        dict["isEmulator"] = true
        #else
        dict["isEmulator"] = false
        #endif
        return dict
    }
    
    private func getScreenSize() -> String {
        let screenSize: CGRect = UIScreen.main.bounds
        return  "\(screenSize)"
    }
    
    private func getScreenDensity() -> String {
        let screenDensity: CGFloat = UIScreen.main.scale
        return  "\(screenDensity)"
    }
    
    private func getIDFA() -> String? {
        if #available(iOS 14, *) {
            if ATTrackingManager.trackingAuthorizationStatus != ATTrackingManager.AuthorizationStatus.authorized  {
                return nil
            }
        } else {
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled == false {
                return nil
            }
        }
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    private func getAppInstallTime() -> String? {
        // The bundle creation date is the closest equivalent
        // This represents when the app bundle was first created (usually during installation)
        let bundlePath = Bundle.main.bundlePath
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: bundlePath)
            if let creationDate = attributes[.creationDate] as? Date {
                return Utils.formatTime(date: creationDate)
            }
        } catch {
            // Handle error silently
        }
        return nil
    }
    
    private func getAppUpdateTime() -> String? {
        // For iOS, we can't get the actual App Store update time
        // The bundle modification date is the closest equivalent
        // This represents when the app bundle was last modified (usually during installation/update)
        let bundlePath = Bundle.main.bundlePath
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: bundlePath)
            if let modificationDate = attributes[.modificationDate] as? Date {
                return Utils.formatTime(date: modificationDate)
            }
        } catch {
            // Handle error silently
        }
        return nil
    }
    
    private func getBootTime() -> String? {
        // Get system boot time using sysctl
        var boottime = timeval()
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        var size = MemoryLayout<timeval>.stride
        
        let result = sysctl(&mib, u_int(mib.count), &boottime, &size, nil, 0)
        if result == 0 && size == MemoryLayout<timeval>.stride {
            // Convert to Date and format consistently with SDK standards
            let bootTime = Date(timeIntervalSince1970: TimeInterval(boottime.tv_sec) + TimeInterval(boottime.tv_usec) / 1_000_000.0)
            return Utils.formatTime(date: bootTime)
        }
        return nil
    }
}
