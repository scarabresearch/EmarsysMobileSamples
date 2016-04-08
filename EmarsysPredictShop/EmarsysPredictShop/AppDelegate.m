//
//  AppDelegate.m
//  EmarsysPredictShop
//

@import EmarsysPredictSDK;
@import AdSupport;

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Set merchant ID.
    EMSession *emarsysSession = [EMSession sharedSession];
    emarsysSession.merchantID = @"1A74F439823D2CB4";
    emarsysSession.logLevel = EMLogLevelWarning;
    return YES;
}

@end
