import XCTest
import trackier_ios_sdk

class CacheManagerTests: XCTestCase {

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

    // MARK: - SDK Configuration Tests
    
    func testSDKConfiguration() {
        let config = TrackierSDKConfig(appToken: "test-app-token", env: TrackierSDKConfig.ENV_DEVELOPMENT)
        
        // Test public methods
        config.setSDKType(sdkType: "test-sdk")
        config.setSDKVersion(sdkVersion: "1.0.0")
        config.setRegion(.IN)
        
        // Test public constants
        XCTAssertEqual(TrackierSDKConfig.ENV_DEVELOPMENT, "development")
        XCTAssertEqual(TrackierSDKConfig.ENVIRONMENT_PRODUCTION, "production")
        XCTAssertEqual(TrackierSDKConfig.ENV_TESTING, "testing")
    }
    
    // MARK: - Environment Tests
    
    func testEnvironmentConstants() {
        // Test environment constants
        XCTAssertEqual(TrackierSDKConfig.ENV_DEVELOPMENT, "development")
        XCTAssertEqual(TrackierSDKConfig.ENVIRONMENT_PRODUCTION, "production")
        XCTAssertEqual(TrackierSDKConfig.ENV_TESTING, "testing")
    }
    
    // MARK: - Region Tests
    
    func testRegionConstants() {
        // Test region constants
        XCTAssertEqual(TrackierSDKConfig.Region.IN, .IN)
        XCTAssertEqual(TrackierSDKConfig.Region.GLOBAL, .GLOBAL)
        XCTAssertEqual(TrackierSDKConfig.Region.NONE, .NONE)
    }
    
    // MARK: - SDK Type Tests
    
    func testSDKTypeManagement() {
        let config = TrackierSDKConfig(appToken: "test-token", env: TrackierSDKConfig.ENV_DEVELOPMENT)
        
        // Test SDK type setting
        config.setSDKType(sdkType: "ios-sdk")
        config.setSDKType(sdkType: "swift-sdk")
        config.setSDKType(sdkType: "test-sdk")
    }
    
    // MARK: - SDK Version Tests
    
    func testSDKVersionManagement() {
        let config = TrackierSDKConfig(appToken: "test-token", env: TrackierSDKConfig.ENV_DEVELOPMENT)
        
        // Test SDK version setting
        config.setSDKVersion(sdkVersion: "1.0.0")
        config.setSDKVersion(sdkVersion: "2.0.0")
        config.setSDKVersion(sdkVersion: "1.6.74")
    }
    
    // MARK: - Region Management Tests
    
    func testRegionManagement() {
        let config = TrackierSDKConfig(appToken: "test-token", env: TrackierSDKConfig.ENV_DEVELOPMENT)
        
        // Test region setting
        config.setRegion(.IN)
        config.setRegion(.GLOBAL)
        config.setRegion(.NONE)
    }
} 