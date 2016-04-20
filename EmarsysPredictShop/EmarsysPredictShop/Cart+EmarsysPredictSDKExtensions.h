//
//  Cart+EmarsysPredictSDKExtensions.h
//  EmarsysPredictShop
//

#import <EmarsysPredictSDK/EmarsysPredictSDK.h>

#import "Cart.h"

@interface Cart (EmarsysPredictSDKExtensions)

- (NSArray<EMCartItem *> *)convertItems;

@end
