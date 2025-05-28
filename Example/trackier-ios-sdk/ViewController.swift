import UIKit
import trackier_ios_sdk
import os.log

class ViewController: UIViewController {
    
    // MARK: - Properties
    private enum LogLevel {
        case debug, info, warning, error
    }
    
    private static let logger = OSLog(
        subsystem: "com.trackier.ios-sdk",
        category: "SKANTesting"
    )
    
    // MARK: - Dynamic Link UI (Programmatic)
    private let dynamicLinkResultLabel: UILabel = {
        let label = UILabel()
        label.text = "Result will appear here"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dynamicLinkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Dynamic Link", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUserTracking()
        setupRevenueTrackingExamples()
        setupSKANTests()
        // Add dynamic link UI
        view.addSubview(dynamicLinkButton)
        view.addSubview(dynamicLinkResultLabel)
        NSLayoutConstraint.activate([
            dynamicLinkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dynamicLinkButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            dynamicLinkButton.heightAnchor.constraint(equalToConstant: 50),
            dynamicLinkButton.widthAnchor.constraint(equalToConstant: 220),
            dynamicLinkResultLabel.topAnchor.constraint(equalTo: dynamicLinkButton.bottomAnchor, constant: 24),
            dynamicLinkResultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            dynamicLinkResultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
        dynamicLinkButton.addTarget(self, action: #selector(didTapCreateDynamicLink), for: .touchUpInside)
    }
    
    // MARK: - User Tracking
    private func setupUserTracking() {
        // User identification
        TrackierSDK.setUserID(userId: "2998329")
        TrackierSDK.setUserEmail(userEmail: "abc@gmail.com")
        TrackierSDK.setUserName(userName: "abc")
        TrackierSDK.setUserPhone(userPhone: "xxxxxxxxxx")
        
        // Track login event
        trackLoginEvent()
    }
    
    private func trackLoginEvent() {
        let event = TrackierEvent(id: TrackierEvent.LOGIN)
        event.setDiscount(discount: 3.0)
        event.setCouponCode(couponCode: "test2")
        event.addEventValue(prop: "customValue1", val: "test1")
        event.addEventValue(prop: "customValue2", val: "XXXXX")
        
        TrackierSDK.trackEvent(event: event)
        TrackierSDK.updateSKANConversion(revenue: 445.3, eventId: "purchase")
    }
    
    // MARK: - Revenue Tracking Examples
    private func setupRevenueTrackingExamples() {
        // Example 1: Simple purchase
        let purchaseEvent = TrackierEvent(id: "sEMWSCTXeu")
        purchaseEvent.setRevenue(revenue: 9.99, currency: "USD")
        purchaseEvent.orderId = "ORD12345"
        TrackierSDK.trackEvent(event: purchaseEvent)
        
        // Example 2: Subscription
        trackSubscriptionEvent()
    }
    
    private func trackSubscriptionEvent() {
        let subscriptionEvent = TrackierEvent(id: TrackierEvent.PURCHASE)
        subscriptionEvent.setRevenue(revenue: 4.99, currency: "USD")
        subscriptionEvent.param1 = "monthly"
        subscriptionEvent.addEventValue(prop: "trial_period", val: "7 days")
        TrackierSDK.trackEvent(event: subscriptionEvent)
    }
    
    // MARK: - SKAN Testing
    private func setupSKANTests() {
        logMessage("Starting SKAN integration tests", level: .info)
        
        // Test sequence with delays to simulate real user flow
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.testInitialSKANUpdates()
        }
    }
    
    private func testInitialSKANUpdates() {
        logMessage("Testing initial SKAN updates", level: .debug)
        
        // First update - app launch/tutorial completion
        TrackierSDK.updateSKANConversion(revenue: 0, eventId: "first_open") { [weak self] _, _ in
            self?.logCurrentSKANValues()
            
            // Second update - after some engagement
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                TrackierSDK.updateSKANConversion(revenue: 25.0, eventId: "content_view") { [weak self] _, _ in
                    self?.logCurrentSKANValues()
                    self?.testPostbackSimulation()
                }
            }
        }
    }
    
    private func testPostbackSimulation() {
        if #available(iOS 16.1, *) {
            logMessage("Testing SKAN postback simulation", level: .debug)
            
            let testURL = URL(string: "https://apptrovesn.com/api/v2/skans/conversion_studios")!
            TrackierSDK.testSKANPostback(url: testURL) { [weak self] success, error in
                if success {
                    self?.logMessage("SKAN postback test succeeded", level: .info)
                } else if let error = error {
                    self?.logMessage("SKAN postback test failed: \(error.localizedDescription)", level: .error)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func logCurrentSKANValues() {
        let (fine, coarse) = TrackierSDK.getCurrentSKANValues()
        logMessage("Current SKAN Values - Fine: \(fine ?? 0), Coarse: \(coarse ?? "none")", level: .debug)
    }
    
    private func logMessage(_ message: String, level: LogLevel) {
        let osLogType: OSLogType
        switch level {
        case .debug: osLogType = .debug
        case .info: osLogType = .info
        case .warning: osLogType = .error
        case .error: osLogType = .fault
        }
        
        os_log("%{public}@", log: Self.logger, type: osLogType, message)
    }
    
    // MARK: - IBActions
    @IBAction func didCompletePurchase(_ sender: UIButton) {
        let purchaseAmount = 19.99
        logMessage("User completed purchase: $\(purchaseAmount)", level: .info)
        
        // Track both the event and update SKAN conversion
        let event = TrackierEvent(id: TrackierEvent.PURCHASE)
        event.setRevenue(revenue: purchaseAmount, currency: "USD")
        TrackierSDK.trackEvent(event: event)
        
        TrackierSDK.updateSKANConversion(
            revenue: purchaseAmount,
            eventId: "purchase"
        ) { [weak self] success, error in
            if success {
                self?.logMessage("Successfully updated SKAN conversion for purchase", level: .info)
            } else if let error = error {
                self?.logMessage("SKAN update failed: \(error.localizedDescription)", level: .error)
            }
        }
    }
    
    @available(iOS 16.1, *)
    @IBAction func didTapTestPostback(_ sender: UIButton) {
        testPostbackSimulation()
    }
    
    @objc private func didTapCreateDynamicLink() {
        dynamicLinkResultLabel.text = "Generating..."
        let dynamicLink = DynamicLink.Builder()
            .setTemplateId("PQBdiM")
            .setLink("https://trackier58.u9ilnk.me?dlv=product")
            .setDomainUriPrefix("trackier58.u9ilnk.me")
            .setDeepLinkValue("productios")
            .setAndroidParameters(
                AndroidParameters.Builder()
                    .setRedirectLink("https://play.google.com/store/apps/details?id=com.trackier.vistmarket")
                    .build()
            )
            .setSDKParameters(["param1": "value1", "param2": "value2"])
            .setAttributionParameters(
                channel: "my_channel",
                campaign: "my_campaign",
                mediaSource: "at_invite",
                p1: "param1_value",
                p2: "dfjsdfsdf",
                p3: "sdfsdfsdf"
            )
            .setIosParameters(
                IosParameters.Builder()
                    .setRedirectLink("https://apps.apple.com/us/app/naughts-n-crosses/id1560127886")
                    .build()
            )
            .setDesktopParameters(
                DesktopParameters.Builder()
                    .setRedirectLink("https://www.vistmarket.com")
                    .build()
            )
            .setSocialMetaTagParameters(
                SocialMetaTagParameters.Builder()
                    .setTitle("New Offer Buy 1 Get 2 Free")
                    .setDescription("New Deal is live now just Open Vist market and purchase any product and get 2 product free")
                    .setImageLink("https://storage.googleapis.com/static.trackier.io/images/test-data/downloaded_images/bluetooth_speaker.jpg")
                    .build()
            )
            .build()
        if #available(iOS 13.0, *) {
            TrackierSDK.createDynamicLink(dynamicLink: dynamicLink, onSuccess: { [weak self] link in
                DispatchQueue.main.async {
                    self?.dynamicLinkResultLabel.text = "Dynamic Link: \(link)"
                }
                print("Dynamic Link: \(link)")
            }, onFailure: { [weak self] error in
                DispatchQueue.main.async {
                    self?.dynamicLinkResultLabel.text = "Failed: \(error)"
                }
                print("Failed to create dynamic link: \(error)")
            })
        } else {
            dynamicLinkResultLabel.text = "iOS 13+ required"
        }
    }
}

// MARK: - Device Info Extension
extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
}
