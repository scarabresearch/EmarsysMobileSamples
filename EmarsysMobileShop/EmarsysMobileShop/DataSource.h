//
//  DataSource.h
//  EmarsysMobileShop
//

@import Foundation;

#import "Item.h"

@interface DataSource : NSObject

+ (nonnull DataSource *)sharedDataSource;
- (NSArray<Item *> *_Nonnull)itemsFromCategory:(NSString *_Nonnull)category;

@property(readonly) NSMutableArray<NSString *> *_Nonnull categories;
@property(readonly) NSMutableArray<Item *> *_Nonnull items;

@end
