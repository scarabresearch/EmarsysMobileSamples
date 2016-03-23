//
//  Cart.h
//  EmarsysMobileShop
//

@import Foundation;

#import "Item.h"
#import "CartItem.h"

@interface Cart : NSObject

+ (nonnull Cart *)sharedCart;
- (void)addItem:(Item *_Nonnull)item;

@property(readonly) NSMutableArray<CartItem *> *_Nonnull cartItems;

@end
