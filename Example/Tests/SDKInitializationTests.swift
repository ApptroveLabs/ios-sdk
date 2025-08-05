import XCTest
import trackier_ios_sdk

class SDKInitializationTests: XCTestCase {

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

    // MARK: - Basic SDK Tests
    
    func testBasicSDKIntegration() {
        // Test basic SDK functionality using only public APIs
        XCTAssertTrue(TrackierSDK.isEnabled())
        
        // Test basic event tracking
        let event = TrackierEvent(id: TrackierEvent.LOGIN)
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
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
    
    // MARK: - Device Management Tests
    
    func testDeviceManagement() {
        // Test device token management
        TrackierSDK.setDeviceToken(deviceToken: "test_device_token_123")
        
        // Test Apple Ads integration
        TrackierSDK.updateAppleAdsToken(token: "test_apple_ads_token")
        TrackierSDK.updatePostbackConversion(conversionValue: 1)
    }
    
    // MARK: - Session Management Tests
    
    func testSessionManagement() {
        // Test session tracking
        XCTAssertNoThrow(TrackierSDK.trackSession())
        
        // Test organic tracking
        TrackierSDK.trackAsOrganic(organic: true)
        TrackierSDK.trackAsOrganic(organic: false)
    }
    
    // MARK: - ATT Framework Tests
    
    func testATTFramework() {
        // Test ATT framework integration
        XCTAssertNoThrow(TrackierSDK.waitForATTUserAuthorization(timeoutInterval: 5))
    }
    
    // MARK: - App Token Tests
    
    func testGetAppToken() {
        // Test getting app token
        let appToken = TrackierSDK.getAppToken()
        XCTAssertEqual(appToken, "xxxx-xx-xxx-xxx")
    }
    
    // MARK: - Configuration Tests
    
    func testSDKConfiguration() {
        let config = TrackierSDKConfig(appToken: "test-app-token", env: TrackierSDKConfig.ENV_DEVELOPMENT)
        
        // Test app secret setting
        config.setAppSecret(secretId: "test-secret-id", secretKey: "test-secret-key")
        
        // Test SDK type and version
        config.setSDKType(sdkType: "test-sdk")
        config.setSDKVersion(sdkVersion: "1.0.0")
        
        // Test region setting
        config.setRegion(.IN)
        
        // Test deeplink listener (mock implementation)
        let mockListener = MockDeepLinkListener()
        config.setDeeplinkListerner(listener: mockListener)
        
        // Verify listener was set
        let retrievedListener = config.getDeeplinkListerner()
        XCTAssertNotNil(retrievedListener)
    }
    
    // MARK: - App Secret Tests
    
    func testAppSecretConfiguration() {
        let config = TrackierSDKConfig(appToken: "test-token", env: TrackierSDKConfig.ENV_DEVELOPMENT)
        
        // Test setting app secrets
        config.setAppSecret(secretId: "secret123", secretKey: "key456")
        
        // Note: getAppSecretId and getAppSecretKey are internal, so we can't test them directly
        // But we can test that setting them doesn't crash
        XCTAssertNoThrow(config.setAppSecret(secretId: "new-secret", secretKey: "new-key"))
    }
    
    // MARK: - Deep Link Listener Tests
    
    func testDeepLinkListenerConfiguration() {
        let config = TrackierSDKConfig(appToken: "test-token", env: TrackierSDKConfig.ENV_DEVELOPMENT)
        
        // Test setting and getting deeplink listener
        let mockListener = MockDeepLinkListener()
        config.setDeeplinkListerner(listener: mockListener)
        
        let retrievedListener = config.getDeeplinkListerner()
        XCTAssertNotNil(retrievedListener)
    }
}

// MARK: - Mock Deep Link Listener

class MockDeepLinkListener: DeepLinkListener {
    func onDeepLinking(result: DeepLink) {
        // Mock implementation for testing
    }
} 