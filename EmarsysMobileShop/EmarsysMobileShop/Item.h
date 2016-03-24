//
//  Item.h
//  EmarsysMobileShop
//

@import Foundation;
@import EmarsysMobile;

NS_ASSUME_NONNULL_BEGIN

@interface Item : NSObject

@property(readwrite) NSString *itemID;
@property(readwrite, nullable) NSString *link;
@property(readwrite, nullable) NSString *title;
@property(readwrite, nullable) NSString *image;
@property(readwrite, nullable) NSString *category;
@property(readwrite) float price;
@property(readwrite) bool available;
@property(readwrite, nullable) NSString *brand;
@property(readonly, nullable) EMRecommendationItem *srcItem;

- (instancetype)initWithItem:(EMRecommendationItem *)item;

@end

NS_ASSUME_NONNULL_END
