//
//  DeepLinkListener.swift
//  apptrove-ios-sdk
//
//  Created by Sanu Gupta on 17/02/23.
//

import Foundation

public protocol DeepLinkListener {
    func onDeepLinking(result: DeepLink) -> Void
}
