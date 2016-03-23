//
//  Cart+EmarsysMobileExtensions.m
//  EmarsysMobileShop
//

@import Foundation;

#import "Cart+EmarsysMobileExtensions.h"

@implementation Cart (EmarsysMobileExtensions)

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
