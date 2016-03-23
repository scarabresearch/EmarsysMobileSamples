//
//  RecommendedDataSourceAnddelegate.h
//  EmarsysMobileShop
//

@import Foundation;
@import UIKit;

#import "Item.h"

@protocol RecommendationManagerDelegate <NSObject>

- (void)updateWithItem:(Item *)item;

@end

@interface RecommendationManager
    : NSObject <UICollectionViewDelegate, UICollectionViewDataSource>

@property NSMutableArray<Item *> *recommendResults;
@property(weak) id<RecommendationManagerDelegate> delegate;

@end
