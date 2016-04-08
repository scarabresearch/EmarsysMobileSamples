//
//  CategoryViewController.h
//  EmarsysPredictShop
//

@import UIKit;

#import "Item.h"
#import "RecommendationManager.h"
#import "ItemsManager.h"

@interface CategoryViewController
    : UIViewController <UITabBarDelegate, UISearchBarDelegate>

@property(weak, nonatomic) IBOutlet UICollectionView *recommendedCollectionView;
@property(weak, nonatomic) IBOutlet UITableView *categoryTableView;
@property(weak, nonatomic) IBOutlet UISearchBar *categorySearchBar;

@property NSString *category;
@property NSArray<Item *> *originalItems;
@property NSArray<Item *> *searchResults;
@property NSString *searchTerm;
@property RecommendationManager *recommendationManager;
@property ItemsManager *itemsManager;
@end
