import XCTest
import trackier_ios_sdk

class EventTests: XCTestCase {

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

    // MARK: - Event Creation Tests
    
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
        event.setCouponCode(couponCode: "SUMMER20")
        event.addEventValue(prop: "product_id", val: "XYZ")
        
        // Test that the event can be tracked
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
    }
    
    // MARK: - Built-in Event Tests
    
    func testBuiltInEvents() {
        // Test all built-in event types
        let events = [
            TrackierEvent(id: TrackierEvent.LOGIN),
            TrackierEvent(id: TrackierEvent.PURCHASE),
            TrackierEvent(id: TrackierEvent.ADD_TO_CART),
            TrackierEvent(id: TrackierEvent.CONTENT_VIEW),
            TrackierEvent(id: TrackierEvent.SHARE),
            TrackierEvent(id: TrackierEvent.INVITE),
            TrackierEvent(id: TrackierEvent.ACHIEVEMENT_UNLOCKED),
            TrackierEvent(id: TrackierEvent.TUTORIAL_COMPLETION),
            TrackierEvent(id: TrackierEvent.SUBSCRIBE),
            TrackierEvent(id: TrackierEvent.START_TRIAL),
            TrackierEvent(id: TrackierEvent.COMPLETE_REGISTRATION),
            TrackierEvent(id: TrackierEvent.ADD_TO_WISHLIST),
            TrackierEvent(id: TrackierEvent.TRAVEL_BOOKING),
            TrackierEvent(id: TrackierEvent.UPDATE),
            TrackierEvent(id: TrackierEvent.LEVEL_ACHIEVED)
        ]
        
        // Test that all events can be tracked
        for event in events {
            XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
        }
    }
    
    // MARK: - Individual Event Type Tests
    
    func testLevelAchievedEvent() {
        let event = TrackierEvent(id: TrackierEvent.LEVEL_ACHIEVED)
        event.addEventValue(prop: "level", val: 5)
        event.addEventValue(prop: "difficulty", val: "hard")
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
    }
    
    func testAddToCartEvent() {
        let event = TrackierEvent(id: TrackierEvent.ADD_TO_CART)
        event.addEventValue(prop: "product_id", val: "PROD123")
        event.addEventValue(prop: "quantity", val: 2)
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
    }
    
    func testAddToWishlistEvent() {
        let event = TrackierEvent(id: TrackierEvent.ADD_TO_WISHLIST)
        event.addEventValue(prop: "product_id", val: "PROD456")
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
    }
    
    func testCompleteRegistrationEvent() {
        let event = TrackierEvent(id: TrackierEvent.COMPLETE_REGISTRATION)
        event.addEventValue(prop: "registration_method", val: "email")
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
    }
    
    func testTutorialCompletionEvent() {
        let event = TrackierEvent(id: TrackierEvent.TUTORIAL_COMPLETION)
        event.addEventValue(prop: "tutorial_name", val: "onboarding")
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
    }
    
    func testSubscribeEvent() {
        let event = TrackierEvent(id: TrackierEvent.SUBSCRIBE)
        event.setRevenue(revenue: 9.99, currency: "USD")
        event.addEventValue(prop: "subscription_type", val: "premium")
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
    }
    
    func testStartTrialEvent() {
        let event = TrackierEvent(id: TrackierEvent.START_TRIAL)
        event.addEventValue(prop: "trial_duration", val: "7_days")
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
    }
    
    func testAchievementUnlockedEvent() {
        let event = TrackierEvent(id: TrackierEvent.ACHIEVEMENT_UNLOCKED)
        event.addEventValue(prop: "achievement_id", val: "ACH001")
        event.addEventValue(prop: "achievement_name", val: "First Purchase")
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
    }
    
    func testContentViewEvent() {
        let event = TrackierEvent(id: TrackierEvent.CONTENT_VIEW)
        event.addEventValue(prop: "content_type", val: "article")
        event.addEventValue(prop: "content_id", val: "ART123")
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
    }
    
    func testTravelBookingEvent() {
        let event = TrackierEvent(id: TrackierEvent.TRAVEL_BOOKING)
        event.setRevenue(revenue: 299.99, currency: "USD")
        event.addEventValue(prop: "destination", val: "Paris")
        event.addEventValue(prop: "travel_class", val: "economy")
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
    }
    
    func testShareEvent() {
        let event = TrackierEvent(id: TrackierEvent.SHARE)
        event.addEventValue(prop: "share_method", val: "facebook")
        event.addEventValue(prop: "content_id", val: "CONT123")
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
    }
    
    func testInviteEvent() {
        let event = TrackierEvent(id: TrackierEvent.INVITE)
        event.addEventValue(prop: "invite_method", val: "email")
        event.addEventValue(prop: "invite_count", val: 5)
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
    }
    
    func testUpdateEvent() {
        let event = TrackierEvent(id: TrackierEvent.UPDATE)
        event.addEventValue(prop: "update_type", val: "profile")
        event.addEventValue(prop: "field_updated", val: "email")
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
    }
    
    // MARK: - Revenue Event Tests
    
    func testRevenueEvents() {
        let event = TrackierEvent(id: TrackierEvent.PURCHASE)
        
        // Test revenue setting
        event.setRevenue(revenue: 29.99, currency: "USD")
        event.setRevenue(revenue: 49.99, currency: "EUR")
        event.setRevenue(revenue: 99.99, currency: "GBP")
        
        // Test discount setting
        event.setDiscount(discount: 5.0)
        event.setDiscount(discount: 10.0)
        event.setDiscount(discount: 15.0)
        
        // Test coupon code setting
        event.setCouponCode(couponCode: "SAVE10")
        event.setCouponCode(couponCode: "SUMMER20")
        event.setCouponCode(couponCode: "WELCOME50")
        
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
    }
    
    // MARK: - Custom Event Tests
    
    func testCustomEvents() {
        let event = TrackierEvent(id: "custom_event_id")
        
        // Test custom event values
        event.addEventValue(prop: "product_id", val: "PROD123")
        event.addEventValue(prop: "category", val: "electronics")
        event.addEventValue(prop: "price", val: 299.99)
        event.addEventValue(prop: "quantity", val: 2)
        event.addEventValue(prop: "user_type", val: "premium")
        
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
    }
    
    // MARK: - Event Parameters Tests
    
    func testEventParameters() {
        let event = TrackierEvent(id: TrackierEvent.CONTENT_VIEW)
        
        // Test all parameter fields
        event.param1 = "param1_value"
        event.param2 = "param2_value"
        event.param3 = "param3_value"
        event.param4 = "param4_value"
        event.param5 = "param5_value"
        event.param6 = "param6_value"
        event.param7 = "param7_value"
        event.param8 = "param8_value"
        event.param9 = "param9_value"
        event.param10 = "param10_value"
        
        XCTAssertNoThrow(TrackierSDK.trackEvent(event: event))
    }
} 