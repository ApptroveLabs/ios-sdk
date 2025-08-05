import XCTest
import trackier_ios_sdk

class Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Initialize SDK for testing
        let config = TrackierSDKConfig(appToken: "test-token", env: TrackierSDKConfig.ENV_DEVELOPMENT)
        TrackierSDK.initialize(config: config)
    }

    override func tearDown() {
        super.tearDown()
        // Clean up after each test
    }

    // MARK: - Basic Integration Test
    
    func testBasicSDKIntegration() {
        // Test basic SDK functionality using only public APIs
        XCTAssertTrue(TrackierSDK.isEnabled())
        
        // Test basic event tracking
        let event = TrackierEvent(id: TrackierEvent.LOGIN)
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
    }
    
    // MARK: - Public API Tests
    
    func testSDKConfiguration() {
        let config = TrackierSDKConfig(appToken: "test-app-token", env: TrackierSDKConfig.ENV_DEVELOPMENT)
        
        // Test public methods
        config.setSDKType(sdkType: "test-sdk")
        config.setSDKVersion(sdkVersion: "1.0.0")
        config.setRegion(.IN)
        
        // Test public constants
        XCTAssertEqual(TrackierSDKConfig.ENV_DEVELOPMENT, "development")
        XCTAssertEqual(TrackierSDKConfig.ENV_TESTING, "testing")
        XCTAssertEqual(TrackierSDKConfig.ENVIRONMENT_PRODUCTION, "production")
    }
    
    func testEventCreation() {
        // Test public event creation
        let event = TrackierEvent(id: TrackierEvent.PURCHASE)
        
        // Test public properties
        event.orderId = "order123"
        event.currency = "USD"
        event.param1 = "test_param"
        
        // Test public methods
        event.setRevenue(revenue: 99.99, currency: "USD")
        event.setDiscount(discount: 10.0)
        event.setCouponCode(couponCode: "SAVE10")
        event.addEventValue(prop: "custom_key", val: "custom_value")
        
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
    }
    
    func testBuiltInEvents() {
        // Test all built-in events are accessible
        let events = [
            TrackierEvent.LEVEL_ACHIEVED,
            TrackierEvent.ADD_TO_CART,
            TrackierEvent.ADD_TO_WISHLIST,
            TrackierEvent.COMPLETE_REGISTRATION,
            TrackierEvent.TUTORIAL_COMPLETION,
            TrackierEvent.PURCHASE,
            TrackierEvent.SUBSCRIBE,
            TrackierEvent.START_TRIAL,
            TrackierEvent.ACHIEVEMENT_UNLOCKED,
            TrackierEvent.CONTENT_VIEW,
            TrackierEvent.TRAVEL_BOOKING,
            TrackierEvent.SHARE,
            TrackierEvent.INVITE,
            TrackierEvent.LOGIN,
            TrackierEvent.UPDATE
        ]
        
        for eventId in events {
            let event = TrackierEvent(id: eventId)
            XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
        }
    }
    
    func testSDKStateManagement() {
        // Test SDK state management
        TrackierSDK.setEnabled(value: false)
        XCTAssertFalse(TrackierSDK.isEnabled())
        
        TrackierSDK.setEnabled(value: true)
        XCTAssertTrue(TrackierSDK.isEnabled())
        
        TrackierSDK.setMinSessionDuration(val: 30)
    }
    
    func testUserManagement() {
        // Test user management functions
        TrackierSDK.setUserID(userId: "test_user_123")
        TrackierSDK.setUserEmail(userEmail: "test@example.com")
        TrackierSDK.setUserName(userName: "Test User")
        TrackierSDK.setUserPhone(userPhone: "+1234567890")
        
        let additionalDetails: [String: Any] = ["age": 25, "location": "New York"]
        TrackierSDK.setUserAdditionalDetails(userAdditionalDetails: additionalDetails)
        
        TrackierSDK.setGender(gender: .MALE)
        TrackierSDK.setDOB(dob: "1990-01-01")
    }
    
    func testDeviceToken() {
        // Test device token management
        TrackierSDK.setDeviceToken(deviceToken: "test_device_token_123")
    }
    
    func testAppleAdsToken() {
        // Test Apple Ads token
        TrackierSDK.updateAppleAdsToken(token: "test_apple_ads_token")
    }
    
    func testDeepLinkParsing() {
        // Test deep link parsing
        let testUrl = "https://example.com?utm_source=test&utm_campaign=campaign1"
        XCTAssertNoThrow(TrackierSDK.parseDeepLink(uri: testUrl))
        
        // Test with nil
        XCTAssertNoThrow(TrackierSDK.parseDeepLink(uri: nil))
    }
    
    func testSessionTracking() {
        // Test session tracking
        XCTAssertNoThrow(TrackierSDK.trackSession())
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
            for i in 0..<10 {
                let event = TrackierEvent(id: "perf_event_\(i)")
                TrackierSDK.trackEvent(event: event)
            }
        }
    }
} 