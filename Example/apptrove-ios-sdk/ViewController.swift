//
//  ViewController.swift
//  apptrove-ios-sdk
//
//  Created by AppTrove on 03/18/2021.
//  Copyright (c) 2021 AppTrove. All rights reserved.
//

import UIKit
import apptrove_ios_sdk

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        userDetails();
    }
}

func userDetails(){
    
    let event = AppTroveEvent(id: AppTroveEvent.LOGIN)
    
    /*Passing the UserId and User EmailId Data */
    AppTroveSDK.setUserID(userId: "2998329") //Pass the UserId values here
    AppTroveSDK.setUserEmail(userEmail: "abc@gmail.com"); //Pass the user email id in the argument.
    AppTroveSDK.setUserName(userName: "abc")
    AppTroveSDK.setUserPhone(userPhone: "xxxxxxxxxx")
    event.setDiscount(discount: 3.0)
    event.setCouponCode(couponCode: "test2")
    /*Passing the custom value in the events */
    event.addEventValue(prop: "customeValue1", val: "test1");
    event.addEventValue(prop: "customeValue2", val: "XXXXX");
    AppTroveSDK.trackEvent(event: event)
}

func eventsRevenueTracking(){

    let event = AppTroveEvent(id: AppTroveEvent.LOGIN)

    //Passing the revenue events be like below example
    event.setRevenue(revenue: 10.0, currency: "INR"); //Pass your generated revenue here.
    event.currency = "INR";  //Pass your currency here.
    event.orderId = "orderID";
    event.param1 = "param1";
    event.param2 = "param2";
    event.addEventValue(prop: "customeValue1", val: "test1");
    event.addEventValue(prop: "customeValue2", val: "XXXXX");
    AppTroveSDK.trackEvent(event: event)
}

func eventsTracking(){
    let event = AppTroveEvent(id:"sEMWSCTXeu")
    
    /*Below are the function for the adding the extra data,
      You can add the extra data like login details of user or anything you need.
      We have 10 params to add data, Below 5 are mentioned*/
    
    event.param1 = "this is a param1 value"
    event.param2 = "this is a param2 value"
    event.param3 = "this is a param3 value"
    event.param4 = "this is a param4 value"
    event.param5 = "this is a param5 value"
    DispatchQueue.global().async {
        sleep(1)
        AppTroveSDK.trackEvent(event: event)
    }
}
    
extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}

