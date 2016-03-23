//
//  SearchViewController.h
//  EmarsysMobileShop
//

@import UIKit;

#import "Item.h"
#import "RecommendationManager.h"
#import "ItemsManager.h"

@interface SearchViewController
    : UIViewController <UITabBarDelegate, UISearchBarDelegate>

@property(weak, nonatomic) IBOutlet UITableView *itemsTableView;
@property(weak, nonatomic) IBOutlet UICollectionView *recommendedCollectionView;
@property(weak, nonatomic) IBOutlet UISearchBar *itemSearchBar;

@property NSString *searchTerm;
@property RecommendationManager *recommendationManager;
@property ItemsManager *itemsManager;

@end
