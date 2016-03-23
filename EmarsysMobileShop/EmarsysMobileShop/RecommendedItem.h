//
//  RecommendedItem.h
//  EmarsysMobileShop
//

@import UIKit;

#import "Item.h"

@interface RecommendedItem : UICollectionViewCell

@property(weak, nonatomic) IBOutlet UIImageView *image;
@property(weak, nonatomic) IBOutlet UILabel *title;
@property(weak, nonatomic) IBOutlet UILabel *price;
@property Item *item;

@end
