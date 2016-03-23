//
//  Cart+EmarsysMobileExtensions.h
//  EmarsysMobileShop
//

@import EmarsysMobile;

#import "Cart.h"

@interface Cart (EmarsysMobileExtensions)

- (NSArray<EMCartItem *> *)convertItems;

@end
