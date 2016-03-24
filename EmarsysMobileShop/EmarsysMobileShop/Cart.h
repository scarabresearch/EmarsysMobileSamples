//
//  Cart.h
//  EmarsysMobileShop
//

@import Foundation;

#import "Item.h"
#import "CartItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface Cart : NSObject

+ (Cart *)sharedCart;
- (void)addItem:(Item *)item;

@property(readonly) NSMutableArray<CartItem *> *cartItems;

@end

NS_ASSUME_NONNULL_END
