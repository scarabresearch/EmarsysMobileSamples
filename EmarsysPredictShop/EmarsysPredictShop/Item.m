//
//  Item.m
//  EmarsysPredictShop
//

#import "Item.h"
#import "Item+EmarsysPredictSDKExtensions.h"

NS_ASSUME_NONNULL_BEGIN

@implementation Item

- (instancetype)initWithItem:(EMRecommendationItem *)item {
    self = [super init];
    if (self) {
        _srcItem = item;
        [self convertItem];
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
