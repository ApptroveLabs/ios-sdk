import XCTest
import trackier_ios_sdk

class APIManagerTests: XCTestCase {

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

    // MARK: - SDK State Management Tests
    
    func testSDKStateManagement() {
        // Test SDK state management
        TrackierSDK.setEnabled(value: false)
        XCTAssertFalse(TrackierSDK.isEnabled())
        
        TrackierSDK.setEnabled(value: true)
        XCTAssertTrue(TrackierSDK.isEnabled())
        
        TrackierSDK.setMinSessionDuration(val: 30)
    }
    
    // MARK: - Session Management Tests
    
    func testSessionManagement() {
        // Test session tracking
        XCTAssertNoThrow(TrackierSDK.trackSession())
        
        // Test session duration setting
        TrackierSDK.setMinSessionDuration(val: 30)
        TrackierSDK.setMinSessionDuration(val: 60)
        TrackierSDK.setMinSessionDuration(val: 120)
    }
    
    // MARK: - Device Management Tests
    
    func testDeviceManagement() {
        // Test device token setting
        TrackierSDK.setDeviceToken(deviceToken: "test-device-token-123")
        TrackierSDK.setDeviceToken(deviceToken: "another-device-token")
        
        // Test Apple Ads integration
        TrackierSDK.updateAppleAdsToken(token: "test-apple-ads-token")
        TrackierSDK.updatePostbackConversion(conversionValue: 1)
        TrackierSDK.updatePostbackConversion(conversionValue: 63)
    }
    
    // MARK: - User Management Tests
    
    func testUserManagement() {
        // Test user identification
        TrackierSDK.setUserID(userId: "user123")
        TrackierSDK.setUserEmail(userEmail: "user@example.com")
        TrackierSDK.setUserName(userName: "Test User")
        TrackierSDK.setUserPhone(userPhone: "+1234567890")
        
        // Test additional user details
        let additionalDetails: [String: Any] = ["age": 25, "location": "New York"]
        TrackierSDK.setUserAdditionalDetails(userAdditionalDetails: additionalDetails)
        
        // Test demographics
        TrackierSDK.setGender(gender: .MALE)
        TrackierSDK.setGender(gender: .FEMALE)
        TrackierSDK.setGender(gender: .OTHERS)
        TrackierSDK.setDOB(dob: "1990-01-01")
    }
    
    // MARK: - Event Tracking Tests
    
    func testEventTracking() {
        // Test basic event tracking
        let loginEvent = TrackierEvent(id: TrackierEvent.LOGIN)
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: loginEvent))
        
        let purchaseEvent = TrackierEvent(id: TrackierEvent.PURCHASE)
        purchaseEvent.setRevenue(revenue: 29.99, currency: "USD")
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: purchaseEvent))
        
        let customEvent = TrackierEvent(id: "custom_event_id")
        customEvent.addEventValue(prop: "test_prop", val: "test_value")
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: customEvent))
    }
    
    // MARK: - Deep Link Tests
    
    func testDeepLinkParsing() {
        // Test deep link parsing
        let testUrl = "https://example.com?utm_source=test&utm_campaign=campaign1"
        XCTAssertNoThrow(TrackierSDK.parseDeepLink(uri: testUrl))
        
        // Test with nil
        XCTAssertNoThrow(TrackierSDK.parseDeepLink(uri: nil))
        
        // Test with empty string
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
        // Test ATT framework integration
        XCTAssertNoThrow(TrackierSDK.waitForATTUserAuthorization(timeoutInterval: 5))
        XCTAssertNoThrow(TrackierSDK.waitForATTUserAuthorization(timeoutInterval: 30))
    }
} 
