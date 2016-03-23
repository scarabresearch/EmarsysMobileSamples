//
//  Cart.m
//  EmarsysMobileShop
//

#import "Cart.h"

@implementation Cart

- (nullable instancetype)init {
    NSAssert(false, @"Unavailable init methods was invoked");
    return nil;
}

- (nonnull instancetype)initInternal {
    self = [super init];
    if (self) {
        _cartItems = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (nonnull Cart *)sharedCart {
    static Cart *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      _shared = [[Cart alloc] initInternal];
    });
    return _shared;
}

- (void)addItem:(Item *_Nonnull)item {
    for (CartItem *next in _cartItems) {
        if ([next.item.itemID isEqualToString:item.itemID]) {
            next.count++;
            return;
        }
    }
    CartItem *newItem = [[CartItem alloc] init];
    newItem.item = item;
    newItem.count = 1;
    [_cartItems addObject:newItem];
}

@end
