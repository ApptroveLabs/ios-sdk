# trackier-ios-sdk

[![Version](https://img.shields.io/cocoapods/v/trackier-ios-sdk.svg?style=flat)](https://cocoapods.org/pods/trackier-ios-sdk)
[![License](https://img.shields.io/cocoapods/l/trackier-ios-sdk.svg?style=flat)](https://cocoapods.org/pods/trackier-ios-sdk)
[![Platform](https://img.shields.io/cocoapods/p/trackier-ios-sdk.svg?style=flat)](https://cocoapods.org/pods/trackier-ios-sdk)

## Table of Content

### Requirements

* [Installation Guide](#qs-installation)
* [Integrate and Initialize the Trackier SDK](#qs-implement-sdk)
* [Retrieve your SDK key](#qs-retrieve-dev-key)
    * [Initialize the SDK](#qs-initialize-sdk)
    * [Associate User Info during initialization of SDK](#qs-add-user-info)
* [Events Tracking](#qs-trackier-event)
    * [Retrieve Event Id from dashboard](#qs-retrieve-event-id)
    * [Built-in Events](#qs-built-in)
    * [Customs Events](#qs-customs-events)
    * [Revenue Event Tracking](#qs-track-event-with-currencey)
    * [Pass the custom params in events](#qs-add-custome-param-event)
* [SDK Signing](#qs-sdk-signing)
* [Deep Link Setup](#qs-deeplink)
* [Getting Campaign Data](#qs-campaign-data)
* [Apple Search Ads](#qs-aaattribution)

## <a id="qs-add-trackier-sdk"></a>Quick start guide

We have created a example app for the Ios sdk integration. 

Please check the [Example](https://github.com/trackier/ios-sdk/tree/master/Example) directory for know to how the `Trackier IOS SDK` can be integrated.

To run the example project, clone the repo, and run pod install from the Example directory first. If you're new to CocoaPods, see their [official documentation](https://guides.cocoapods.org/using/using-cocoapods) for info on how to create and use Pod Files.

## <a id="qs-installation"></a>Installation

trackier-ios-sdk is available through [CocoaPods](https://cocoapods.org/). To install it, simply add the following line to your Podfile:

```ruby
    pod 'trackier-ios-sdk'
```

## <a id="qs-implement-sdk"></a>Integrate and Initialize the Trackier SDK

### <a id="qs-retrieve-dev-key"></a>Retrieve your SDK key

For initialising the Trackier SDk. First, We need to generate the SDK key from the Trackier MMP panel.

Following below are the steps to retrieve the development key:-

- Login your Trackier Panel
- Select your application and click on Action button and login as
- In the Dashboard, Click on the` SDK Integration` option on the left side of panel. 
- under on the SDK Integration, You will be get the SDK Key.

After follow all steps, Your SDK key look like the below screenshot

Screenshot[1]

<img width="1000" alt="Screenshot 2022-06-10 at 3 46 48 PM" src="https://user-images.githubusercontent.com/16884982/173044860-a540706c-ad10-4174-aaf0-7cf9290fc949.png">


## <a id="qs-initialize-sdk"></a>Initialize the SDK

<p>We recommend initializing the SDK inside the AppDelegate.swift. This allows the SDK to
initialize in all scenarios, including deep linking.
The steps listed below take place inside the AppDelegate.swift .
</p>

#### AppDelegate.swift

**Note** - It is crucial to use the correct dev key when initializing the SDK. Using the wrong dev key or an incorrect dev key impacts all traffic sent from the SDK and causes attribution and reporting issues.

```swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
       /* While Initializing the SDK, You need to pass the two arguments in the TrackierSDKConfig.
        * In First argument, you need to pass the Trackier SDK api key
        * In second argument, you need to pass the environment which can be either "development", "production" or "testing". */
        
        let config = TrackierSDKConfig(appToken: "xxxx-xx-xxx-xxx", env: TrackierSDKConfig.ENV_DEVELOPMENT) //Pass your Trackier sdk api key
        TrackierSDK.initialize(config: config)
        return true
    }   
}

```

Below are the screenshot of the code:-

Screenshot[2]

<img width="1000" alt="Screenshot 2022-07-04 at 12 20 38 AM" src="https://user-images.githubusercontent.com/16884982/177053392-62aae4d6-2e7f-4eaf-a530-29d538a3cefc.png">


## <a id="qs-trackier-event"></a>Events Tracking 

<a id="qs-retrieve-event-id"></a>Trackier events trackings enable to provides the insights into how to user interacts with your app. 
Trackier SDK easily get that insights data from the app. Just follow with the simple events integration process

Trackier provides the `Built-in events` and `Customs events` on the Trackier panel.

#### <a id="qs-built-in"></a> **Built-in Events** - 

Predefined events are the list of constants events which already been created on the dashboard. 

You can use directly to track those events. Just need to implements events in the app projects.

Screenshot[3]

<img width="1000" alt="Screenshot 2022-06-10 at 1 23 01 PM" src="https://user-images.githubusercontent.com/16884982/173018185-3356c117-8b9f-46d1-bfd5-c41653f9ac9e.png">

#### Example code for calling Built-in events


```swift

/*
 * Event Tracking
  <------------->
 * The below code is the example to pass a event to the Trackier SDK.
 * This event requires only 1 Parameter which is the Event ID.
 * Below are the example of built-in events function calling
 * The arguments - "TrackierEvent.LOGIN" passed in the Trackier event class is Events id
 *
 */


func eventsTracking(){

    let event = TrackierEvent(id: TrackierEvent.LOGIN)
 
   /* Below are the function for the adding the extra data,
      You can add the extra data like login details of user or anything you need.
      We have 10 params to add data, Below 5 are mentioned */

    event.param1 = "this is a param1 value"
    event.param2 = "this is a param2 value"
    event.param3 = "this is a param3 value"
    event.param4 = "this is a param4 value"
    event.param5 = "this is a param5 value"
    DispatchQueue.global().async {
        sleep(1)
        TrackierSDK.trackEvent(event: event)
}
    
}

```

Note:- Argument in Trackier event class is event Id.

You can integrate inbuilt params with the event. In-built param list are mentioned below:-

orderId, revenue, currency, param1, param2, param3 ,param4, param5, param6, param7, param8, param9, param10, param11, param12, param13, param14, param15.

Below are the screenshot of following example:-

Screenshot[4]

<img width="1000" alt="Screenshot 2022-07-04 at 2 30 49 PM" src="https://user-images.githubusercontent.com/16884982/177121084-a9056773-f102-433e-b181-f2c67bcc3473.png">


#### <a id="qs-customs-events"></a> **Customs Events** - 

Customs events are created by user as per their required business logic. 

You can create the events in the Trackier dashboard and integrate those events in the app project.

Screenshot[5]

<img width="1000" alt="Screenshot 2022-06-29 at 4 09 37 PM" src="https://user-images.githubusercontent.com/16884982/176417552-a8c80137-aa1d-480a-81a3-ea1e03172868.png">


#### Example code for calling Customs Events.

```swift

  /*
 * Event Tracking
  <------------->
 * The below code is the example to pass a event to the Trackier SDK.
 * This event requires only 1 Parameter which is the Event ID.
 * Below are the example of customs events function calling for `AppOpen` event name.
 * The arguments - "sEMWSCTXeu" passed in the Trackier event class is Events id 
 *
 */

  func eventsTracking(){
    let event = TrackierEvent(id: "sEMWSCTXeu")
    
   /* Below are the function for the adding the extra data,
      You can add the extra data like login details of user or anything you need.
      We have 10 params to add data, Below 5 are mentioned */
    
    event.param1 = "this is a param1 value"
    event.param2 = "this is a param2 value"
    event.param3 = "this is a param3 value"
    event.param4 = "this is a param4 value"
    event.param5 = "this is a param5 value"
    DispatchQueue.global().async {
        sleep(1)
        TrackierSDK.trackEvent(event: event)
   }
    
}

```

Also check the screenshots of the above code.

Screenshot[6]

<img width="1000" alt="Screenshot 2022-07-04 at 3 29 36 PM" src="https://user-images.githubusercontent.com/16884982/177131719-4b02d09e-efce-49db-9464-f8346aa24408.png">


### <a id="qs-track-event-with-currencey"></a>Revenue Event Tracking

Trackier allow user to pass the revenue data which is generated from the app through Revenue events. It is mainly used to keeping record of generating revenue from the app and also you can pass currency as well.

```swift
    
  func eventsRevenueTracking(){
    
    let event = TrackierEvent(id: TrackierEvent.LOGIN)
    
    //Passing the revenue events be like below example
    event.revenue = 10.0; //Pass your generated revenue here.
    event.currency = "INR";  //Pass your currency here.
    event.orderId = "orderID";
    event.param1 = "param1";
    event.param2 = "param2";
    event.setEventValue("ev1", "eventValue1");
    event.setEventValue("ev2", 1);
    DispatchQueue.global().async {
        sleep(1)
        TrackierSDK.trackEvent(event: event)
}
    
}

```
Below are the screenshot of the above code 

Screenshot[7]

<img width="1000" alt="Screenshot 2022-07-04 at 4 00 22 PM" src="https://user-images.githubusercontent.com/16884982/177137505-b141a9e3-aabe-4439-aaf7-c9fe596b2610.png">



### <a id="qs-add-custome-param-event"></a>Pass the custom params in events

```swift
   func userDetails(){
    
    let event = TrackierEvent(id: TrackierEvent.LOGIN)
    
    /*Passing the UserId and User EmailId Data */
     TrackierSDK.setUserId(XXXXXXXX) // Pass user Id here
     TrackierSDK.setUserEmail("abc@gmail.com") // Pass email Id
     TrackierSDK.setUserName(userName: "abc") // Pass User Name
     TrackierSDK.setUserPhone(userPhone: "8138933891") // Pass User Phone Number
    
    /*Passing the custom value in the events */
     event.addEventValue("customeValue1","XXXXX");
     event.addEventValue("customeValue2","XXXXX");
    
    
    DispatchQueue.global().async {
        sleep(1)
        TrackierSDK.trackEvent(event: event)
}
  }
```

### Passing User Data to SDK

Trackier allows to pass additional data like Userid, Email to SDK so that same can be correlated to the Trackier Data and logs.

Just need to pass the data of User Id, Email Id and other additional data to Trackier SDK function which is mentioned below:-


```swift

func userDetails(){
    
    let event = TrackierEvent(id: TrackierEvent.LOGIN)
    
    /* Passing the UserId and User EmailId Data */
     TrackierSDK.setUserId(XXXXXXXX) // Pass user Id here
     TrackierSDK.setUserEmail("abc@gmail.com") // Pass email Id
     TrackierSDK.setUserName(userName: "abc") // Pass User Name
     TrackierSDK.setUserPhone(userPhone: "8138933891") // Pass User Phone Number
    DispatchQueue.global().async {
        sleep(1)
        TrackierSDK.trackEvent(event: event)
}
  }


```

Below are the screenshots of the above example of Passing custom data and User data to SDK.

Screenshot[8]

<img width="1000" alt="Screenshot 2022-07-04 at 5 49 15 PM" src="https://user-images.githubusercontent.com/16884982/177153481-c5708192-8605-4595-a528-5753a91b90f5.png">


## <a id="qs-add-user-info"></a>Associate User Info during initialization of SDK

To assosiate Customer Id , Customer Email and Customer additional params during initializing sdk

```swift
    // Override point for customization after application launch.
    let config = TrackierSDKConfig(appToken: "xxxx-xx-xxx-xxx", env: TrackierSDKConfig.ENV_DEVELOPMENT)
    TrackierSDK.setUserId(XXXXXXXX)
    TrackierSDK.setUserEmail("abc@gmail.com")
    TrackierSDK.initialize(config: config)
```

#### Note

<p>For additional user details , make a dictonary and pass it in setUserAdditionalDetails function</p>

```swift
    val userAdditionalDetails = Dictionary <String,AnyObject>()
    userAdditionalDetails.["userMobile",99XXXXXXXX]
    TrackierSDK.setUserAdditionalDetails(userAdditionalDetails)	
```

## <a id="qs-sdk-signing"></a>SDK Signing
```swift
let config = TrackierSDKConfig(appToken: "xx-182a-4584-aca3-xx", env: TrackierSDKConfig.ENVIRONMENT_PRODUCTION)
config.setAppSecret(secretId: "xxxx", secretKey: "xxx-xx")
```

## <a id="qs-deeplink"></a>Deep link Setup
    
There is a Universal Links iOS app opening method which needs to be implemented for deeplink to work. This method directly opens the mobile app at default activity. Universal links take the format of normal web links for example. https://yourbrand.com or https://yourbrand.u9ilnk.me

Follow the steps for configuring Universal Links

**a. Getting the app bundle ID and prefix ID**

1. Log into your Apple Developer Account.
2. On the left-hand menu, select Certificates, IDs & Profiles.
3. Under Identifiers, select App IDs.
4. Click the relevant app.
5. Copy the prefix ID and app bundle ID and insert in app settings page in Trackier MMP.

Screenshot[9]

<img width="1000" alt="Screenshot apple" src="https://user-images.githubusercontent.com/16884982/190552695-060b22bc-e269-4a53-b397-09b6162b2faf.png">

**b. Adding the prefix ID and app bundle ID in the Trackier MMP.**

- Login your Trackier Panel
- Select your application and click on Action button and login as
- In the Dashboard, Click on the `UniLink` option on the left side of panel.
- On the Unilink page, create template by click on Action button which is located on the right side header of the page.
- After creating template, Edit that template by click on the edit button.
- On the edit template page, Add the prefix ID and app bundle ID in the **Link Behaviour (When application is installed)**

Please check the screenshot for the reference

Screenshot[10]

<img width="1000" alt="Screenshot dashboard" src="https://user-images.githubusercontent.com/16884982/190556533-c05419b8-ea6c-4850-9ea3-11ce5545b764.png">

**c. Configure mobile apps to register associated domains**

Configuring mobile apps to register approved domains takes place inside Xcode. It requires the unilink subdomain that you can get from app setting page in Trackier MMP.

1. Follow this [iOS instructions](https://developer.apple.com/documentation/xcode/supporting-associated-domains)
2. Get the unilink subdomain from app settings page in Trackier MMP.
3. In Xcode, click on your project. Click on the project target.
4. Switch to Capabilities tab.
5. Turn on Associated Domain.
6. Add the unilink subdomain that you got from Trackier MMP.
7. The format is applinks:subdomain.unilink.me. Add **applinks:** before the domain as like `applinks:subdomain.unilink.me`

Screenshot[11]

<img width="1000" alt="Screenshotxcode" src="https://user-images.githubusercontent.com/16884982/190557503-a13cbf23-8485-491b-a9d7-dcd86e44c912.png">

To associate a domain with your app, you need to have the associated domain file on your domain and the appropriate entitlement in your app. Once the unilink is created, Trackier hosts the apple-app-site-association file. When a user installs your app, the system attempts to download the associated domain file and verify the domains in your Associated Domains Entitlement.

**For getting the deeplinking url:-** 

```swift
import UIKit
import trackier_ios_sdk
import AppTrackingTransparency
import AdServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, DeepLinkListener {

    var window: UIWindow?
   // call for getting the deeplinking url value
    func onDeepLinking(result: DeepLink) -> Void {
        print("==result: \(result.getUrlParams()))")
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        /*While Initializing the Sdk, You need to pass the two arguments in the TrackierSDKConfig.
         * In First argument, you need to pass the Trackier SDK api key
         * In second argument, you need to pass the environment which can be either "development", "production" or "testing". */
        
        let config = TrackierSDKConfig(appToken: "xxxx-xx-xxx-xxx", env: TrackierSDKConfig.ENV_DEVELOPMENT) //Pass your Trackier sdk api key
        config.setDeeplinkListerner(listener: self) // call for set deeplinking listner
        TrackierSDK.initialize(config: config)
        return true
    }

}

```
## <a id="qs-campaign-data"></a>Getting Campaign Data
For getting the campaign data, We have a function that return the campaign data. Please check below the example code.

```swift

func userDetails(){
    let event = TrackierEvent(id: "EwQP98t4Ns")
    var ad = TrackierSDK.getAd()
    var adID = TrackierSDK.getAdID()
    var adSet = TrackierSDK.getAdSet()
    var adSetID = TrackierSDK.getAdSetID()
    var campaign = TrackierSDK.getCampaign()
    var campaignID = TrackierSDK.getCampaignID()
    var channel = TrackierSDK.getChannel()
    var clickId = TrackierSDK.getClickId()
    var p1 = TrackierSDK.getP1()
    var p2 = TrackierSDK.getP2()
    var p3 = TrackierSDK.getP3()
    var p4 = TrackierSDK.getP4()
    var p5 = TrackierSDK.getP5()
    var dlv = TrackierSDK.getDlv()
    var pid = TrackierSDK.getPid()
    var retargetting = TrackierSDK.getIsRetargeting()
    TrackierSDK.trackEvent(event: event)
}

```

## <a id="qs-aaattribution"></a>Apple Search Ads
Apple Search Ads is an advertising platform provided by Apple Inc. that allows app developers and marketers to promote their apps within the Apple App Store search results. The platform enables advertisers to bid on specific keywords to have their app displayed prominently when users search for those keywords in the App Store.

Here is some configuration in the SDK. Please follow the below example code


```swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        /*While Initializing the Sdk, You need to pass the two arguments in the TrackierSDKConfig.
         * In First argument, you need to pass the Trackier SDK api key
        * In second argument, you need to pass the environment which can be either "development", "production" or "testing". */
        
        let config = TrackierSDKConfig(appToken: "xxxx-xx-xxx-xxx", env: TrackierSDKConfig.ENV_DEVELOPMENT) //Pass your Trackier sdk api key
        // Apple Search Ads Attribution code
        if #available(iOS 14.3, *) {
            let a = try? AAAttribution.attributionToken()
            TrackierSDK.updateAppleAdsToken(token: a!)
        } else {
            // Fallback on earlier versions
        }
        TrackierSDK.initialize(config: config)
        return true
    }
```


