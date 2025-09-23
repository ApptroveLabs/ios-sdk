//
//  DynamicLinksTests.swift
//  trackier-ios-sdk
//
//  Created by Satyam Jha on 05/08/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import XCTest
import trackier_ios_sdk

class DynamicLinksTests: XCTestCase {

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

    // MARK: - Dynamic Link Builder Tests
    
    func testDynamicLinkBuilder() {
        let dynamicLink = DynamicLink.Builder()
            .setTemplateId("template123")
            .setLink("https://example.com")
            .setDomainUriPrefix("https://example.page.link")
            .setDeepLinkValue("deeplink://example.com")
            .build()
        
        XCTAssertEqual(dynamicLink.templateId, "template123")
        XCTAssertEqual(dynamicLink.link, "https://example.com")
        XCTAssertEqual(dynamicLink.domainUriPrefix, "https://example.page.link")
        XCTAssertEqual(dynamicLink.deepLinkValue, "deeplink://example.com")
    }
    
    func testAndroidParameters() {
        let androidParams = AndroidParameters.Builder()
            .setRedirectLink("https://play.google.com/store/apps/details?id=com.example")
            .build()
        
        XCTAssertEqual(androidParams.redirectLink, "https://play.google.com/store/apps/details?id=com.example")
    }
    
    func testIosParameters() {
        let iosParams = IosParameters.Builder()
            .setRedirectLink("https://apps.apple.com/app/id123456789")
            .build()
        
        XCTAssertEqual(iosParams.redirectLink, "https://apps.apple.com/app/id123456789")
    }
    
    func testDesktopParameters() {
        let desktopParams = DesktopParameters.Builder()
            .setRedirectLink("https://example.com/desktop")
            .build()
        
        XCTAssertEqual(desktopParams.redirectLink, "https://example.com/desktop")
    }
    
    func testSocialMetaTagParameters() {
        let socialParams = SocialMetaTagParameters.Builder()
            .setTitle("Amazing App")
            .setDescription("The best app ever")
            .setImageLink("https://example.com/image.jpg")
            .build()
        
        XCTAssertEqual(socialParams.title, "Amazing App")
        XCTAssertEqual(socialParams.description, "The best app ever")
        XCTAssertEqual(socialParams.imageLink, "https://example.com/image.jpg")
    }
    
    func testDynamicLinkWithAllParameters() {
        let androidParams = AndroidParameters.Builder()
            .setRedirectLink("https://play.google.com/store/apps/details?id=com.example")
            .build()
        
        let iosParams = IosParameters.Builder()
            .setRedirectLink("https://apps.apple.com/app/id123456789")
            .build()
        
        let socialParams = SocialMetaTagParameters.Builder()
            .setTitle("Amazing App")
            .setDescription("The best app ever")
            .setImageLink("https://example.com/image.jpg")
            .build()
        
        let dynamicLink = DynamicLink.Builder()
            .setTemplateId("template123")
            .setLink("https://example.com")
            .setDomainUriPrefix("https://example.page.link")
            .setDeepLinkValue("deeplink://example.com")
            .setAndroidParameters(androidParams)
            .setIosParameters(iosParams)
            .setSocialMetaTagParameters(socialParams)
            .setSDKParameters(["param1": "value1", "param2": "value2"])
            .setAttributionParameters(
                channel: "facebook",
                campaign: "summer_sale",
                mediaSource: "social",
                p1: "custom1",
                p2: "custom2"
            )
            .build()
        
        XCTAssertEqual(dynamicLink.templateId, "template123")
        XCTAssertEqual(dynamicLink.link, "https://example.com")
        XCTAssertEqual(dynamicLink.domainUriPrefix, "https://example.page.link")
        XCTAssertEqual(dynamicLink.deepLinkValue, "deeplink://example.com")
        XCTAssertEqual(dynamicLink.channel, "facebook")
        XCTAssertEqual(dynamicLink.campaign, "summer_sale")
        XCTAssertEqual(dynamicLink.mediaSource, "social")
        XCTAssertEqual(dynamicLink.p1, "custom1")
        XCTAssertEqual(dynamicLink.p2, "custom2")
        XCTAssertEqual(dynamicLink.sdkParameters["param1"], "value1")
        XCTAssertEqual(dynamicLink.sdkParameters["param2"], "value2")
    }
    
    func testToDynamicLinkConfig() {
        let androidParams = AndroidParameters.Builder()
            .setRedirectLink("https://play.google.com/store/apps/details?id=com.example")
            .build()
        
        let socialParams = SocialMetaTagParameters.Builder()
            .setTitle("Amazing App")
            .setDescription("The best app ever")
            .setImageLink("https://example.com/image.jpg")
            .build()
        
        let dynamicLink = DynamicLink.Builder()
            .setTemplateId("template123")
            .setLink("https://example.com")
            .setDomainUriPrefix("https://example.page.link")
            .setDeepLinkValue("deeplink://example.com")
            .setAndroidParameters(androidParams)
            .setSocialMetaTagParameters(socialParams)
            .setSDKParameters(["param1": "value1"])
            .setAttributionParameters(
                channel: "facebook",
                campaign: "summer_sale"
            )
            .build()
        
        let config = dynamicLink.toDynamicLinkConfig(installId: "install123", appKey: "app_key_123")
        
        XCTAssertEqual(config.installId, "install123")
        XCTAssertEqual(config.appKey, "app_key_123")
        XCTAssertEqual(config.templateId, "template123")
        XCTAssertEqual(config.link, "https://example.com")
        XCTAssertEqual(config.brandDomain, "https://example.page.link")
        XCTAssertEqual(config.deepLinkValue, "deeplink://example.com")
        XCTAssertEqual(config.sdkParameter?["param1"], "value1")
        XCTAssertEqual(config.redirection?.android, "https://play.google.com/store/apps/details?id=com.example")
        XCTAssertEqual(config.socialMedia?.title, "Amazing App")
        XCTAssertEqual(config.socialMedia?.description, "The best app ever")
        XCTAssertEqual(config.socialMedia?.image, "https://example.com/image.jpg")
    }
    
    func testRedirectionToDictionary() {
        // Create Redirection using JSON decoding since it's Codable
        let redirectionJSON = """
        {
            "android": "https://play.google.com/store/apps/details?id=com.example",
            "ios": "https://apps.apple.com/app/id123456789",
            "desktop": "https://example.com/desktop"
        }
        """.data(using: .utf8)!
        
        let redirection = try! JSONDecoder().decode(Redirection.self, from: redirectionJSON)
        let dictionary = redirection.toDictionary()
        
        XCTAssertEqual(dictionary["android"], "https://play.google.com/store/apps/details?id=com.example")
        XCTAssertEqual(dictionary["ios"], "https://apps.apple.com/app/id123456789")
        XCTAssertEqual(dictionary["desktop"], "https://example.com/desktop")
    }
    
    func testSocialMediaToDictionary() {
        // Create SocialMedia using JSON decoding since it's Codable
        let socialMediaJSON = """
        {
            "title": "Amazing App",
            "description": "The best app ever",
            "image": "https://example.com/image.jpg"
        }
        """.data(using: .utf8)!
        
        let socialMedia = try! JSONDecoder().decode(SocialMedia.self, from: socialMediaJSON)
        let dictionary = socialMedia.toDictionary()
        
        XCTAssertEqual(dictionary["title"], "Amazing App")
        XCTAssertEqual(dictionary["description"], "The best app ever")
        XCTAssertEqual(dictionary["image"], "https://example.com/image.jpg")
    }
    
    func testDynamicLinkConfigToDictionary() {
        // Create DynamicLinkConfig using JSON decoding since it's Codable
        let configJSON = """
        {
            "installId": "install123",
            "appKey": "app_key_123",
            "templateId": "template123",
            "link": "https://example.com",
            "brandDomain": "https://example.page.link",
            "deepLinkValue": "deeplink://example.com",
            "sdkParameter": {"param1": "value1"},
            "redirection": {
                "android": "https://play.google.com/store/apps/details?id=com.example",
                "ios": "https://apps.apple.com/app/id123456789"
            },
            "attrParameter": {"channel": "facebook"},
            "socialMedia": {
                "title": "Amazing App",
                "description": "The best app ever",
                "image": "https://example.com/image.jpg"
            }
        }
        """.data(using: .utf8)!
        
        let config = try! JSONDecoder().decode(DynamicLinkConfig.self, from: configJSON)
        let dictionary = config.toDictionary()
        
        XCTAssertEqual(dictionary["install_id"] as? String, "install123")
        XCTAssertEqual(dictionary["app_key"] as? String, "app_key_123")
        XCTAssertEqual(dictionary["template_id"] as? String, "template123")
        XCTAssertEqual(dictionary["link"] as? String, "https://example.com")
        XCTAssertEqual(dictionary["brand_domain"] as? String, "https://example.page.link")
        XCTAssertEqual(dictionary["deep_link_value"] as? String, "deeplink://example.com")
    }
    
    // MARK: - SDK Integration Tests
    
    @available(iOS 13.0, *)
    func testResolveDeeplinkUrl() {
        // Test the SDK's resolveDeeplinkUrl method
        let url = "https://example.page.link/test?param1=value1&param2=value2"
        
        // This method should not crash and should handle the URL properly
        XCTAssertNoThrow(TrackierSDK.resolveDeeplinkUrl(inputUrl: url) { result in
            // Completion handler for testing
        })
    }
    
    @available(iOS 13.0, *)
    func testCreateDynamicLink() {
        // Test the SDK's createDynamicLink method
        let dynamicLink = DynamicLink.Builder()
            .setTemplateId("template123")
            .setLink("https://example.com")
            .build()
        
        // This method should not crash and should handle the dynamic link properly
        XCTAssertNoThrow(TrackierSDK.createDynamicLink(dynamicLink: dynamicLink, onSuccess: { result in
            // Success handler for testing
        }, onFailure: { error in
            // Failure handler for testing
        }))
    }
}
