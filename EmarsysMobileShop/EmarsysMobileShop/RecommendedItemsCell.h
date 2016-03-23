//
//  RecommendedItemsCell.h
//  EmarsysMobileShop
//

@import UIKit;

#import "Item.h"

@interface RecommendedItemsCell
    : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource>

@property(weak, nonatomic) IBOutlet UICollectionView *RecommendedCollectionView;
@property NSArray<Item *> *items;

@end
