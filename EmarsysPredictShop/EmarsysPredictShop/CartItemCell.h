//
//  CartItemCell.h
//  EmarsysPredictShop
//

@import UIKit;

@interface CartItemCell : UITableViewCell

@property(weak, nonatomic) IBOutlet UIImageView *image;
@property(weak, nonatomic) IBOutlet UILabel *title;
@property(weak, nonatomic) IBOutlet UILabel *count;
@property(weak, nonatomic) IBOutlet UILabel *cost;

@end
