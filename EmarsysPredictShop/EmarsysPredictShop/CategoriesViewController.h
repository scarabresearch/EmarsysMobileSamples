//
//  CategoriesViewController.h
//  EmarsysPredictShop
//

@import UIKit;

#import "Item.h"

@interface CategoriesViewController
    : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(weak, nonatomic) IBOutlet UITableView *categoriesTableView;
@property(weak, nonatomic) IBOutlet UITableView *recommendedTableView;

@property NSString *category;
@property NSArray<Item *> *items;
@property NSArray<Item *> *searchResults;
@property NSMutableArray<Item *> *recommendResults;
@property NSMutableArray<NSString *> *categories;
@property NSMutableArray<NSString *> *shopTopics;
@property NSMutableDictionary<id, NSMutableArray<Item *> *> *itemsWithTopics;
@end
