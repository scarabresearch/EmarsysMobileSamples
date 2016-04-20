//
//  ItemDetailViewController.h
//  EmarsysPredictShop
//

@import UIKit;
#import <EmarsysPredictSDK/EmarsysPredictSDK.h>

#import "Item.h"
#import "LoginViewController.h"
#import "RecommendationManager.h"

@interface ItemDetailViewController : UIViewController

@property(weak, nonatomic) IBOutlet UIImageView *image;
@property(weak, nonatomic) IBOutlet UILabel *name;
@property(weak, nonatomic) IBOutlet UILabel *availability;
@property(weak, nonatomic) IBOutlet UILabel *price;
@property(weak, nonatomic) IBOutlet UICollectionView *recommendedCollectionView;
- (IBAction)addToCart:(id)sender;

@property Item *item;
@property RecommendationManager *recommendationManager;
@end
