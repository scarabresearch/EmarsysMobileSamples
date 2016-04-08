//
//  CategoryViewController.m
//  EmarsysPredictShop
//

@import EmarsysPredictSDK;
@import Foundation;

#import "CategoryViewController.h"
#import "ItemDetailViewController.h"
#import "Cart+EmarsysPredictSDKExtensions.h"
#import "DataSource.h"
#import "RecommendedItem.h"

@implementation CategoryViewController

static NSString *const reuseIdentifier = @"ItemCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.recommendationManager = [[RecommendationManager alloc] init];
    self.recommendationManager.recommendResults = [[NSMutableArray alloc] init];
    self.itemsManager = [[ItemsManager alloc] init];
    self.itemsManager.items = [[NSArray<Item *> alloc] init];
    self.categoryTableView.dataSource = _itemsManager;
    self.categoryTableView.delegate = _itemsManager;
    self.categorySearchBar.delegate = self;
    self.recommendedCollectionView.dataSource = self.recommendationManager;
    self.recommendedCollectionView.delegate = self.recommendationManager;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Deselect all rows
    for (NSIndexPath *indexPath in self.categoryTableView
             .indexPathsForSelectedRows) {
        [self.categoryTableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    self.title = self.category;
    self.originalItems =
        [[DataSource sharedDataSource] itemsFromCategory:self.category];
    self.itemsManager.items = (self.searchTerm && self.searchTerm.length)
                                  ? self.searchResults
                                  : self.originalItems;
    [self sendRecommend];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowItem"]) {
        ItemDetailViewController *ctr = segue.destinationViewController;
        ctr.item =
            self.itemsManager
                .items[self.categoryTableView.indexPathForSelectedRow.row];
    } else if ([segue.identifier isEqualToString:@"ShowRecommendedItem"]) {
        ItemDetailViewController *ctr = segue.destinationViewController;
        RecommendedItem *recItem = sender;
        ctr.item = recItem.item;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    if (searchText && searchText.length) {
        NSPredicate *resultPredicate = [NSPredicate
            predicateWithFormat:@"title BEGINSWITH[c] %@", searchText];
        self.searchResults =
            [self.originalItems filteredArrayUsingPredicate:resultPredicate];
        self.itemsManager.items = self.searchResults;
        self.searchTerm = searchText;
    } else {
        [searchBar resignFirstResponder];
        self.searchTerm = nil;
        self.searchResults = nil;
        self.itemsManager.items = self.originalItems;
    }
    [self.categoryTableView reloadData];
    [self sendRecommend];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {
    [aSearchBar resignFirstResponder];
}

- (BOOL)searchBar:(UISearchBar *)searchBar
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {

    if ([text isEqualToString:@"\n"]) {
        [searchBar resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)sendRecommend {

    EMSession *emarsysSession = [EMSession sharedSession];
    EMTransaction *transaction = [[EMTransaction alloc] init];
    NSArray<EMCartItem *> *cartItems = [[Cart sharedCart] convertItems];
    [transaction setCart:cartItems];

    if (self.searchTerm) {
        [transaction setSearchTerm:self.searchTerm];
    }

    [self.recommendationManager.recommendResults removeAllObjects];

    NSString *logic;
    NSMutableArray<NSString *> *exludeItems = nil;

    if (self.searchResults != nil && self.searchResults.count > 0) {
        Item *firstItem = [self.searchResults objectAtIndex:0];
        [transaction setView:firstItem.itemID];

        if (self.searchResults.count > 1) {
            exludeItems = [[NSMutableArray<NSString *> alloc] init];
            int i;
            for (i = 1; i < [self.searchResults count]; i++) {
                Item *item = [self.searchResults objectAtIndex:i];
                [exludeItems addObject:item.itemID];
            }
        }

        logic = @"RELATED";

    } else {
        [transaction setCategory:self.category];
        logic = @"CATEGORY";
    }

    EMRecommendationRequest *recommend =
        [[EMRecommendationRequest alloc] initWithLogic:logic];

    if (exludeItems) {
        [recommend excludeItemsWhere:@"item" isIn:exludeItems];
    }

    recommend.limit = 10;

    recommend.completionHandler = ^(EMRecommendationResult *_Nonnull result) {

      // Process result
      NSLog(@"%@", result.featureID);
      [result.products
          enumerateObjectsUsingBlock:^(EMRecommendationItem *_Nonnull obj,
                                       NSUInteger idx, BOOL *_Nonnull stop) {
            Item *item = [[Item alloc] initWithItem:obj];
            [self.recommendationManager.recommendResults addObject:item];
          }];

      dispatch_async(dispatch_get_main_queue(), ^{
        [self.recommendedCollectionView reloadData];
      });
    };
    [transaction recommend:recommend];

    // Firing the transaction. Should be the last call on the page, called only
    // once.
    [emarsysSession sendTransaction:transaction
                       errorHandler:^(NSError *_Nonnull error) {
                         // Some error happened
                         NSLog(@"value: %@", error);
                         return;
                       }];
}

@end
