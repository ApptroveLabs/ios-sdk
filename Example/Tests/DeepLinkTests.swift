import XCTest
import trackier_ios_sdk

class DeepLinkTests: XCTestCase {

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

    // MARK: - Deep Link Parsing Tests
    
    func testDeepLinkParsing() {
        // Test deep link parsing
        let testUrl = "https://example.com?utm_source=test&utm_campaign=campaign1"
        XCTAssertNoThrow(TrackierSDK.parseDeepLink(uri: testUrl))
        
        // Test with nil
        XCTAssertNoThrow(TrackierSDK.parseDeepLink(uri: nil))
        
        // Test with empty string
        XCTAssertNoThrow(TrackierSDK.parseDeepLink(uri: ""))
    }
    
    // MARK: - Campaign URL Tests
    
    func testCampaignURLs() {
        // Test various campaign URL formats
        let urls = [
            "https://example.com?utm_source=facebook&utm_campaign=summer_sale",
            "https://example.com?utm_source=google&utm_campaign=winter_promo",
            "https://example.com?utm_source=twitter&utm_campaign=holiday_special",
            "https://example.com?utm_source=instagram&utm_campaign=spring_clearance"
        ]
        
        for url in urls {
            XCTAssertNoThrow(TrackierSDK.parseDeepLink(uri: url))
        }
    }
    
    // MARK: - Custom Parameter Tests
    
    func testCustomParameters() {
        // Test URLs with custom parameters
        let customUrls = [
            "https://example.com?p1=value1&p2=value2&p3=value3",
            "https://example.com?click_id=abc123&dlv=xyz789",
            "https://example.com?ad_id=ad123&campaign_id=camp456&channel=social"
        ]
        
        for url in customUrls {
            XCTAssertNoThrow(TrackierSDK.parseDeepLink(uri: url))
        }
    }
    
    // MARK: - Edge Case Tests
    
    func testEdgeCases() {
        // Test edge cases
        XCTAssertNoThrow(TrackierSDK.parseDeepLink(uri: "https://example.com"))
        XCTAssertNoThrow(TrackierSDK.parseDeepLink(uri: "https://example.com?"))
        XCTAssertNoThrow(TrackierSDK.parseDeepLink(uri: "https://example.com?&"))
        XCTAssertNoThrow(TrackierSDK.parseDeepLink(uri: "https://example.com?param="))
    }
} 