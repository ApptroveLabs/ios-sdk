import UIKit
import os
import trackier_ios_sdk

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, DeepLinkListener {
    
    var window: UIWindow?

    func onDeepLinking(result: DeepLink) -> Void {
        print("Deep link URL: \(result.getUrl())")
        
        print("Campaign: \(result.getCamp())")
        print("Campaign ID: \(result.getCampId())")
        print("Ad: \(result.getAd())")
        print("Ad ID: \(result.getAdId())")
        print("Channel: \(result.getChannel())")
        print("Click ID: \(result.getClickId())")
        
        let allParams: [String: String] = [
            "url": result.getUrl(),
            "message": result.getMessage(),
            "ad": result.getAd(),
            "adId": result.getAdId(),
            "camp": result.getCamp(),
            "campId": result.getCampId(),
            "adSet": result.getAdSet(),
            "adSetId": result.getAdSetId(),
            "channel": result.getChannel(),
            "p1": result.getP1(),
            "p2": result.getP2(),
            "p3": result.getP3(),
            "p4": result.getP4(),
            "p5": result.getP5(),
            "clickId": result.getClickId(),
            "dlv": result.getDlv(),
            "pid": result.getPid(),
            "sdkParams": result.getSDKParams()
        ]
        
        print("All parameters: \(allParams)")
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let config = TrackierSDKConfig(appToken: "b551b474-e91c-470e-900b-971e5b954169", env: TrackierSDKConfig.ENV_DEVELOPMENT)
        config.setDeeplinkListerner(listener: self)
        TrackierSDK.waitForATTUserAuthorization(timeoutInterval: 20)
        
        config.setDebugMode(true)
            .setSKANMinimumRevenueDelta(2.0)
            .setSKANMaximumUpdateFrequency(7200)
            .setSKANAutomaticSessionTracking(true)
            .setSKANRegisterForAttribution(true)

        TrackierSDK.registerSKAdNetwork()
        TrackierSDK.initialize(config: config)

        setupSKANDebugging()
        
        // Verify SKAN registration with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let (fine, coarse) = TrackierSDK.getCurrentSKANValues()
            print("Initial SKAN Values - Fine: \(fine ?? -1), Coarse: \(coarse ?? "none")")
        }

        return true
    }
    
    // MARK: - SKAN Debugging
    
    private func setupSKANDebugging() {
        #if DEBUG
        if isSimulator() {
            print("SKAN debugging skipped in simulator")
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.testSKANIntegration()
        }
        #endif
    }
    
    private func testSKANIntegration() {
        print("Starting SKAN integration tests")
        
        let testScenarios = [
            (revenue: 10.0, eventId: "o91gt1Q0PK"), // Login
            (revenue: 25.0, eventId: "99VEGvXjN7"), // Tutorial complete
            (revenue: 50.0, eventId: "Q4YsqBKnzZ")  // Purchase
        ]
        
        testScenarios.enumerated().forEach { (index, scenario) in
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 2) {
                print("Testing SKAN Conversion: \(scenario.eventId) - $\(scenario.revenue)")
                TrackierSDK.updateSKANConversion(
                    revenue: scenario.revenue,
                    eventId: scenario.eventId
                ) { success, error in
                    if success {
                        let (fine, coarse) = TrackierSDK.getCurrentSKANValues()
                        print("Updated SKAN Values - Fine: \(fine ?? -1), Coarse: \(coarse ?? "none")")
                    } else if let error = error {
                        print("SKAN Update Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        TrackierSDK.trackSession()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}
