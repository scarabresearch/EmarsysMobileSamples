//
//  CartItem.h
//  EmarsysMobileShop
//

@import Foundation;

#import "Item.h"

@interface CartItem : NSObject
@property(readwrite) Item *_Nonnull item;
@property(readwrite) int count;
@end
