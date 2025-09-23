//
//  CampaignTests.swift
//  trackier-ios-sdk
//
//  Created by Satyam Jha on 05/08/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import XCTest
import trackier_ios_sdk

class CampaignDataTests: XCTestCase {

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

    // MARK: - Campaign Data Retrieval Tests
    
    func testGetAd() {
        // Test getting ad data
        let ad = TrackierSDK.getAd()
        // Note: This might return nil if no campaign data is available
        // We just test that the method doesn't crash
        XCTAssertNoThrow(TrackierSDK.getAd())
    }
    
    func testGetAdID() {
        // Test getting ad ID
        let adId = TrackierSDK.getAdID()
        XCTAssertNoThrow(TrackierSDK.getAdID())
    }
    
    func testGetCampaign() {
        // Test getting campaign data
        let campaign = TrackierSDK.getCampaign()
        XCTAssertNoThrow(TrackierSDK.getCampaign())
    }
    
    func testGetCampaignID() {
        // Test getting campaign ID
        let campaignId = TrackierSDK.getCampaignID()
        XCTAssertNoThrow(TrackierSDK.getCampaignID())
    }
    
    func testGetAdSet() {
        // Test getting ad set data
        let adSet = TrackierSDK.getAdSet()
        XCTAssertNoThrow(TrackierSDK.getAdSet())
    }
    
    func testGetAdSetID() {
        // Test getting ad set ID
        let adSetId = TrackierSDK.getAdSetID()
        XCTAssertNoThrow(TrackierSDK.getAdSetID())
    }
    
    func testGetChannel() {
        // Test getting channel data
        let channel = TrackierSDK.getChannel()
        XCTAssertNoThrow(TrackierSDK.getChannel())
    }
    
    func testGetP1() {
        // Test getting P1 parameter
        let p1 = TrackierSDK.getP1()
        XCTAssertNoThrow(TrackierSDK.getP1())
    }
    
    func testGetP2() {
        // Test getting P2 parameter
        let p2 = TrackierSDK.getP2()
        XCTAssertNoThrow(TrackierSDK.getP2())
    }
    
    func testGetP3() {
        // Test getting P3 parameter
        let p3 = TrackierSDK.getP3()
        XCTAssertNoThrow(TrackierSDK.getP3())
    }
    
    func testGetP4() {
        // Test getting P4 parameter
        let p4 = TrackierSDK.getP4()
        XCTAssertNoThrow(TrackierSDK.getP4())
    }
    
    func testGetP5() {
        // Test getting P5 parameter
        let p5 = TrackierSDK.getP5()
        XCTAssertNoThrow(TrackierSDK.getP5())
    }
    
    func testGetClickId() {
        // Test getting click ID
        let clickId = TrackierSDK.getClickId()
        XCTAssertNoThrow(TrackierSDK.getClickId())
    }
    
    func testGetDlv() {
        // Test getting DLV parameter
        let dlv = TrackierSDK.getDlv()
        XCTAssertNoThrow(TrackierSDK.getDlv())
    }
    
    func testGetPid() {
        // Test getting PID parameter
        let pid = TrackierSDK.getPid()
        XCTAssertNoThrow(TrackierSDK.getPid())
    }
    
    func testGetIsRetargeting() {
        // Test getting retargeting flag
        let isRetargeting = TrackierSDK.getIsRetargeting()
        XCTAssertNoThrow(TrackierSDK.getIsRetargeting())
    }
    
    // MARK: - Campaign Data with Deep Link Tests
    
    func testCampaignDataAfterDeepLink() {
        // Test campaign data after parsing a deep link
        let testUrl = "https://example.com?utm_source=facebook&utm_campaign=summer_sale&utm_medium=cpc&ad_id=12345&campaign_id=67890&adset_id=11111&channel=social&p1=param1&p2=param2&p3=param3&p4=param4&p5=param5&click_id=click123&dlv=dlv456&pid=pid789&is_retargeting=true"
        
        // Parse deep link
        TrackierSDK.parseDeepLink(uri: testUrl)
        
        // Now test all campaign data methods
        XCTAssertNoThrow(TrackierSDK.getAd())
        XCTAssertNoThrow(TrackierSDK.getAdID())
        XCTAssertNoThrow(TrackierSDK.getCampaign())
        XCTAssertNoThrow(TrackierSDK.getCampaignID())
        XCTAssertNoThrow(TrackierSDK.getAdSet())
        XCTAssertNoThrow(TrackierSDK.getAdSetID())
        XCTAssertNoThrow(TrackierSDK.getChannel())
        XCTAssertNoThrow(TrackierSDK.getP1())
        XCTAssertNoThrow(TrackierSDK.getP2())
        XCTAssertNoThrow(TrackierSDK.getP3())
        XCTAssertNoThrow(TrackierSDK.getP4())
        XCTAssertNoThrow(TrackierSDK.getP5())
        XCTAssertNoThrow(TrackierSDK.getClickId())
        XCTAssertNoThrow(TrackierSDK.getDlv())
        XCTAssertNoThrow(TrackierSDK.getPid())
        XCTAssertNoThrow(TrackierSDK.getIsRetargeting())
    }
    
    // MARK: - Campaign Data Edge Cases
    
    func testCampaignDataWithEmptyDeepLink() {
        // Test campaign data with empty deep link
        TrackierSDK.parseDeepLink(uri: "")
        
        // All methods should still work without crashing
        XCTAssertNoThrow(TrackierSDK.getAd())
        XCTAssertNoThrow(TrackierSDK.getAdID())
        XCTAssertNoThrow(TrackierSDK.getCampaign())
        XCTAssertNoThrow(TrackierSDK.getCampaignID())
    }
    
    func testCampaignDataWithNilDeepLink() {
        // Test campaign data with nil deep link
        TrackierSDK.parseDeepLink(uri: nil)
        
        // All methods should still work without crashing
        XCTAssertNoThrow(TrackierSDK.getAd())
        XCTAssertNoThrow(TrackierSDK.getAdID())
        XCTAssertNoThrow(TrackierSDK.getCampaign())
        XCTAssertNoThrow(TrackierSDK.getCampaignID())
    }
    
    func testCampaignDataWithInvalidDeepLink() {
        // Test campaign data with invalid deep link
        let invalidUrl = "not-a-valid-url"
        TrackierSDK.parseDeepLink(uri: invalidUrl)
        
        // All methods should still work without crashing
        XCTAssertNoThrow(TrackierSDK.getAd())
        XCTAssertNoThrow(TrackierSDK.getAdID())
        XCTAssertNoThrow(TrackierSDK.getCampaign())
        XCTAssertNoThrow(TrackierSDK.getCampaignID())
    }
    
    // MARK: - Real-world Campaign Data Tests
    
    func testFacebookCampaignData() {
        let facebookUrl = "https://example.com?utm_source=facebook&utm_campaign=app_install&utm_medium=cpc&ad_id=fb_ad_123&campaign_id=fb_campaign_456&adset_id=fb_adset_789&channel=facebook&p1=ios&p2=us&p3=english&p4=18-25&p5=high_value&click_id=fb_click_123&dlv=fb_dlv_456&pid=fb_pid_789&is_retargeting=false"
        
        TrackierSDK.parseDeepLink(uri: facebookUrl)
        
        XCTAssertNoThrow(TrackierSDK.getAd())
        XCTAssertNoThrow(TrackierSDK.getAdID())
        XCTAssertNoThrow(TrackierSDK.getCampaign())
        XCTAssertNoThrow(TrackierSDK.getCampaignID())
        XCTAssertNoThrow(TrackierSDK.getChannel())
    }
    
    func testGoogleAdsCampaignData() {
        let googleUrl = "https://example.com?utm_source=google&utm_campaign=search_campaign&utm_medium=cpc&ad_id=google_ad_123&campaign_id=google_campaign_456&adset_id=google_adset_789&channel=google&p1=android&p2=global&p3=all_languages&p4=25-34&p5=mid_value&click_id=google_click_123&dlv=google_dlv_456&pid=google_pid_789&is_retargeting=true"
        
        TrackierSDK.parseDeepLink(uri: googleUrl)
        
        XCTAssertNoThrow(TrackierSDK.getAd())
        XCTAssertNoThrow(TrackierSDK.getAdID())
        XCTAssertNoThrow(TrackierSDK.getCampaign())
        XCTAssertNoThrow(TrackierSDK.getCampaignID())
        XCTAssertNoThrow(TrackierSDK.getChannel())
    }
    
    func testTikTokCampaignData() {
        let tiktokUrl = "https://example.com?utm_source=tiktok&utm_campaign=video_campaign&utm_medium=cpc&ad_id=tiktok_ad_123&campaign_id=tiktok_campaign_456&adset_id=tiktok_adset_789&channel=tiktok&p1=ios&p2=us&p3=english&p4=16-24&p5=low_value&click_id=tiktok_click_123&dlv=tiktok_dlv_456&pid=tiktok_pid_789&is_retargeting=false"
        
        TrackierSDK.parseDeepLink(uri: tiktokUrl)
        
        XCTAssertNoThrow(TrackierSDK.getAd())
        XCTAssertNoThrow(TrackierSDK.getAdID())
        XCTAssertNoThrow(TrackierSDK.getCampaign())
        XCTAssertNoThrow(TrackierSDK.getCampaignID())
        XCTAssertNoThrow(TrackierSDK.getChannel())
    }
    
    // MARK: - Campaign Data Performance Tests
    
    func testCampaignDataPerformance() {
        let testUrl = "https://example.com?utm_source=test&utm_campaign=performance_test&utm_medium=cpc&ad_id=perf_ad_123&campaign_id=perf_campaign_456&adset_id=perf_adset_789&channel=test&p1=param1&p2=param2&p3=param3&p4=param4&p5=param5&click_id=perf_click_123&dlv=perf_dlv_456&pid=perf_pid_789&is_retargeting=true"
        
        TrackierSDK.parseDeepLink(uri: testUrl)
        
        // Test performance of multiple campaign data calls
        self.measure {
            for _ in 0..<100 {
                _ = TrackierSDK.getAd()
                _ = TrackierSDK.getAdID()
                _ = TrackierSDK.getCampaign()
                _ = TrackierSDK.getCampaignID()
                _ = TrackierSDK.getAdSet()
                _ = TrackierSDK.getAdSetID()
                _ = TrackierSDK.getChannel()
                _ = TrackierSDK.getP1()
                _ = TrackierSDK.getP2()
                _ = TrackierSDK.getP3()
                _ = TrackierSDK.getP4()
                _ = TrackierSDK.getP5()
                _ = TrackierSDK.getClickId()
                _ = TrackierSDK.getDlv()
                _ = TrackierSDK.getPid()
                _ = TrackierSDK.getIsRetargeting()
            }
        }
    }
}
