//
//  Cart+EmarsysPredictSDKExtensions.h
//  EmarsysPredictShop
//

@import EmarsysPredictSDK;

#import "Cart.h"

@interface Cart (EmarsysPredictSDKExtensions)

- (NSArray<EMCartItem *> *)convertItems;

@end
