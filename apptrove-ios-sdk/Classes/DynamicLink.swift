//
//  DynamicLink.swift
//  
//
//  Created by Sanu Gupta on 29/05/25.
//

public class AndroidParameters {
    public let redirectLink: String
    public init(redirectLink: String) {
        self.redirectLink = redirectLink
    }
    public class Builder {
        public init() {}
        private var redirectLink: String = ""
        public func setRedirectLink(_ link: String) -> Builder {
            self.redirectLink = link
            return self
        }
        public func build() -> AndroidParameters {
            return AndroidParameters(redirectLink: redirectLink)
        }
    }
}

public class IosParameters {
    public let redirectLink: String
    public init(redirectLink: String) {
        self.redirectLink = redirectLink
    }
    public class Builder {
        public init() {}
        private var redirectLink: String = ""
        public func setRedirectLink(_ link: String) -> Builder {
            self.redirectLink = link
            return self
        }
        public func build() -> IosParameters {
            return IosParameters(redirectLink: redirectLink)
        }
    }
}

public class DesktopParameters {
    public let redirectLink: String
    public init(redirectLink: String) {
        self.redirectLink = redirectLink
    }
    public class Builder {
        public init() {}
        private var redirectLink: String = ""
        public func setRedirectLink(_ link: String) -> Builder {
            self.redirectLink = link
            return self
        }
        public func build() -> DesktopParameters {
            return DesktopParameters(redirectLink: redirectLink)
        }
    }
}

public class SocialMetaTagParameters {
    public let title: String
    public let description: String
    public let imageLink: String
    public init(title: String, description: String, imageLink: String) {
        self.title = title
        self.description = description
        self.imageLink = imageLink
    }
    public class Builder {
        public init() {}
        private var title: String = ""
        private var description: String = ""
        private var imageLink: String = ""
        public func setTitle(_ title: String) -> Builder {
            self.title = title
            return self
        }
        public func setDescription(_ description: String) -> Builder {
            self.description = description
            return self
        }
        public func setImageLink(_ imageLink: String) -> Builder {
            self.imageLink = imageLink
            return self
        }
        public func build() -> SocialMetaTagParameters {
            return SocialMetaTagParameters(title: title, description: description, imageLink: imageLink)
        }
    }
}

// MARK: - Redirection & SocialMedia

public struct Redirection: Codable {
    public let android: String?
    public let ios: String?
    public let desktop: String?
    public func toDictionary() -> [String: String] {
        return [
            "android": android ?? "",
            "ios": ios ?? "",
            "desktop": desktop ?? ""
        ]
    }
}

public struct SocialMedia: Codable {
    public let title: String?
    public let description: String?
    public let image: String?
    public func toDictionary() -> [String: String] {
        return [
            "title": title ?? "",
            "description": description ?? "",
            "image": image ?? ""
        ]
    }
}

// MARK: - DynamicLinkConfig

public struct DynamicLinkConfig: Codable {
    public let installId: String
    public let appKey: String
    public let templateId: String
    public let link: String
    public let brandDomain: String?
    public let deepLinkValue: String?
    public let sdkParameter: [String: String]?
    public let redirection: Redirection?
    public let attrParameter: [String: String]?
    public let socialMedia: SocialMedia?
    
    public func toDictionary() -> [String: Any] {
        return [
            "install_id": installId,
            "app_key": appKey,
            "template_id": templateId,
            "link": link,
            "brand_domain": brandDomain ?? "",
            "deep_link_value": deepLinkValue ?? "",
            "sdk_parameter": sdkParameter ?? [:],
            "redirection": redirection?.toDictionary() ?? [:],
            "attr_parameter": attrParameter ?? [:],
            "social_media": socialMedia?.toDictionary() ?? [:]
        ]
    }
}
//
//// MARK: - DynamicLinkResponse
//
//public struct DynamicLinkResponse: Codable {
//    public let success: Bool
//    public let message: String?
//    public let error: ErrorResponse?
//    public let data: LinkData?
//}
//
//public struct ErrorResponse: Codable {
//    public let statusCode: Int
//    public let errorCode: String
//    public let codeMsg: String
//    public let message: String
//}
//
//public struct LinkData: Codable {
//    public let link: String
//}

// MARK: - DynamicLink (Builder)

public class DynamicLink {
    public var templateId: String = ""
    public var link: String = ""
    public var domainUriPrefix: String = ""
    public var deepLinkValue: String = ""
    public var androidParameters: AndroidParameters? = nil
    public var iosParameters: IosParameters? = nil
    public var desktopParameters: DesktopParameters? = nil
    public var sdkParameters: [String: String] = [:]
    public var socialMetaTagParameters: SocialMetaTagParameters? = nil
    public var channel: String = ""
    public var campaign: String = ""
    public var mediaSource: String = ""
    public var p1: String = ""
    public var p2: String = ""
    public var p3: String = ""
    public var p4: String = ""
    public var p5: String = ""
    
    public class Builder {
        public init() {}
        private var dynamicLink = DynamicLink()
        public func setTemplateId(_ templateId: String) -> Builder {
            dynamicLink.templateId = templateId
            return self
        }
        public func setLink(_ link: String) -> Builder {
            dynamicLink.link = link
            return self
        }
        public func setDomainUriPrefix(_ prefix: String) -> Builder {
            dynamicLink.domainUriPrefix = prefix
            return self
        }
        public func setDeepLinkValue(_ value: String) -> Builder {
            dynamicLink.deepLinkValue = value
            return self
        }
        public func setAndroidParameters(_ params: AndroidParameters) -> Builder {
            dynamicLink.androidParameters = params
            return self
        }
        public func setIosParameters(_ params: IosParameters) -> Builder {
            dynamicLink.iosParameters = params
            return self
        }
        public func setDesktopParameters(_ params: DesktopParameters) -> Builder {
            dynamicLink.desktopParameters = params
            return self
        }
        public func setSDKParameters(_ params: [String: String]) -> Builder {
            dynamicLink.sdkParameters = params
            return self
        }
        public func setSocialMetaTagParameters(_ params: SocialMetaTagParameters) -> Builder {
            dynamicLink.socialMetaTagParameters = params
            return self
        }
        public func setAttributionParameters(channel: String = "", campaign: String = "", mediaSource: String = "", p1: String = "", p2: String = "", p3: String = "", p4: String = "", p5: String = "") -> Builder {
            dynamicLink.channel = channel
            dynamicLink.campaign = campaign
            dynamicLink.mediaSource = mediaSource
            dynamicLink.p1 = p1
            dynamicLink.p2 = p2
            dynamicLink.p3 = p3
            dynamicLink.p4 = p4
            dynamicLink.p5 = p5
            return self
        }
        public func build() -> DynamicLink {
            return dynamicLink
        }
    }
    
    public func toDynamicLinkConfig(installId: String, appKey: String) -> DynamicLinkConfig {
        return DynamicLinkConfig(
            installId: installId,
            appKey: appKey,
            templateId: templateId,
            link: link,
            brandDomain: domainUriPrefix,
            deepLinkValue: deepLinkValue,
            sdkParameter: sdkParameters,
            redirection: Redirection(
                android: androidParameters?.redirectLink,
                ios: iosParameters?.redirectLink,
                desktop: desktopParameters?.redirectLink
            ),
            attrParameter: [
                "channel": channel,
                "campaign": campaign,
                "media_source": mediaSource,
                "p1": p1,
                "p2": p2,
                "p3": p3,
                "p4": p4,
                "p5": p5
            ].filter { !$0.value.isEmpty },
            socialMedia: socialMetaTagParameters.map {
                SocialMedia(title: $0.title, description: $0.description, image: $0.imageLink)
            }
        )
    }
}
