//
//  Item.h
//  EmarsysMobileShop
//

@import Foundation;
@import EmarsysMobile;

@interface Item : NSObject

@property(readwrite) NSString *_Nonnull itemID;
@property(readwrite) NSString *_Nullable link;
@property(readwrite) NSString *_Nullable title;
@property(readwrite) NSString *_Nullable image;
@property(readwrite) NSString *_Nullable category;
@property(readwrite) float price;
@property(readwrite) bool available;
@property(readwrite) NSString *_Nullable brand;
@property(readonly) EMRecommendationItem *_Nullable srcItem;

- (nonnull instancetype)initWithItem:(nonnull EMRecommendationItem *)item;
@end
