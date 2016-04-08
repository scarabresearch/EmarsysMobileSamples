//
//  DataSource.h
//  EmarsysPredictShop
//

@import Foundation;

#import "Item.h"

NS_ASSUME_NONNULL_BEGIN

@interface DataSource : NSObject

+ (nonnull DataSource *)sharedDataSource;
- (NSArray<Item *> *)itemsFromCategory:(NSString *)category;

@property(readonly) NSMutableArray<NSString *> *categories;
@property(readonly) NSMutableArray<Item *> *items;

@end

NS_ASSUME_NONNULL_END
