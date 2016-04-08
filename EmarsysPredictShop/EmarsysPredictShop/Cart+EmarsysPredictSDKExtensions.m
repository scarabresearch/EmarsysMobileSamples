//
//  Cart+EmarsysPredictSDKExtensions.m
//  EmarsysPredictShop
//

@import Foundation;

#import "Cart+EmarsysPredictSDKExtensions.h"

@implementation Cart (EmarsysPredictSDKExtensions)

- (NSArray<EMCartItem *> *)convertItems {
    NSMutableArray<EMCartItem *> *ret = [[NSMutableArray alloc] init];
    for (CartItem *toWrap in self.cartItems) {
        EMCartItem *wrapped =
            [[EMCartItem alloc] initWithItemID:toWrap.item.itemID
                                         price:toWrap.item.price
                                      quantity:toWrap.count];
        [ret addObject:wrapped];
    }
    return ret;
}

@end
