//
//  AppDelegate.swift
//  EmarsysPredictShopSwift
//

import UIKit
import EmarsysPredictSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Set merchant ID.
        let emarsysSession = EMSession.sharedSession()
        emarsysSession.merchantID = "1A74F439823D2CB4"
        emarsysSession.logLevel = .Warning
        return true
    }
}
