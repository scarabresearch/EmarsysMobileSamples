//
//  Item.m
//  EmarsysMobileShop
//

#import "Item.h"
#import "Item+EmarsysMobileExtensions.h"

@implementation Item

- (nonnull instancetype)initWithItem:(nonnull EMRecommendationItem *)item {
    self = [super init];
    if (self) {
        _srcItem = item;
        [self convertItem];
    }
    return self;
}

@end
