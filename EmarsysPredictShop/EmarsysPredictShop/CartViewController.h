//
//  CartViewController.h
//  EmarsysPredictShop
//

@import UIKit;

#import "Item.h"

@interface CartViewController
    : UIViewController <UITableViewDataSource, UITableViewDelegate,
                        UICollectionViewDelegate, UICollectionViewDataSource>

@property(weak, nonatomic) IBOutlet UIBarButtonItem *buyButton;
@property(weak, nonatomic) IBOutlet UITableView *cartItemsTableView;
@property(weak, nonatomic) IBOutlet UICollectionView *recommendedCollectionView;
- (IBAction)buy:(id)sender;

@property NSMutableArray<Item *> *recommendResults;
@end
