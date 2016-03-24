//
//  CartItem.h
//  EmarsysMobileShop
//

@import Foundation;

#import "Item.h"

NS_ASSUME_NONNULL_BEGIN

@interface CartItem : NSObject

@property(readwrite) Item *item;
@property(readwrite) int count;

@end

NS_ASSUME_NONNULL_END
