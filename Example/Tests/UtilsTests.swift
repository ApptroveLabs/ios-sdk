import XCTest
import trackier_ios_sdk

class UtilsTests: XCTestCase {

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

    // MARK: - User Management Tests
    
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
    
    // MARK: - Event Tracking Tests
    
    func testEventTracking() {
        // Test various event types
        let loginEvent = TrackierEvent(id: TrackierEvent.LOGIN)
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: loginEvent))
        
        let purchaseEvent = TrackierEvent(id: TrackierEvent.PURCHASE)
        purchaseEvent.setRevenue(revenue: 29.99, currency: "USD")
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: purchaseEvent))
        
        let customEvent = TrackierEvent(id: "custom_event_id")
        customEvent.addEventValue(prop: "test_prop", val: "test_value")
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: customEvent))
    }
    
    // MARK: - SDK State Tests
    
    func testSDKState() {
        // Test SDK state management
        XCTAssertTrue(TrackierSDK.isEnabled())
        
        TrackierSDK.setEnabled(value: false)
        XCTAssertFalse(TrackierSDK.isEnabled())
        
        TrackierSDK.setEnabled(value: true)
        XCTAssertTrue(TrackierSDK.isEnabled())
    }
    
    // MARK: - Session Management Tests
    
    func testSessionManagement() {
        // Test session tracking
        XCTAssertNoThrow(TrackierSDK.trackSession())
        
        // Test session duration
        TrackierSDK.setMinSessionDuration(val: 30)
        TrackierSDK.setMinSessionDuration(val: 60)
    }
    
    // MARK: - Device Management Tests
    
    func testDeviceManagement() {
        // Test device token
        TrackierSDK.setDeviceToken(deviceToken: "test-device-token")
        
        // Test Apple Ads
        TrackierSDK.updateAppleAdsToken(token: "test-apple-ads-token")
        TrackierSDK.updatePostbackConversion(conversionValue: 1)
    }
    
    // MARK: - Deep Link Tests
    
    func testDeepLinkParsing() {
        // Test deep link parsing
        let testUrl = "https://example.com?utm_source=test&utm_campaign=campaign1"
        XCTAssertNoThrow(TrackierSDK.parseDeepLink(uri: testUrl))
        
        XCTAssertNoThrow(TrackierSDK.parseDeepLink(uri: nil))
        XCTAssertNoThrow(TrackierSDK.parseDeepLink(uri: ""))
    }
    
    // MARK: - Organic Tracking Tests
    
    func testOrganicTracking() {
        // Test organic tracking
        TrackierSDK.trackAsOrganic(organic: true)
        TrackierSDK.trackAsOrganic(organic: false)
    }
    
    // MARK: - ATT Framework Tests
    
    func testATTFramework() {
        // Test ATT framework
        XCTAssertNoThrow(TrackierSDK.waitForATTUserAuthorization(timeoutInterval: 5))
    }
} 