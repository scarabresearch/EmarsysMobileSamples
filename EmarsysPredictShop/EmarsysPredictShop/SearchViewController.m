//
//  SearchViewController.m
//  EmarsysPredictShop
//

#import "SearchViewController.h"
#import "ItemDetailViewController.h"
#import "RecommendedItem.h"
#import "DataSource.h"
#import "Cart+EmarsysPredictSDKExtensions.h"

@implementation SearchViewController

static NSString *const reuseIdentifier = @"RecommendedItemCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.recommendationManager = [[RecommendationManager alloc] init];
    self.recommendationManager.recommendResults = [[NSMutableArray alloc] init];
    self.itemsManager = [[ItemsManager alloc] init];
    self.itemsManager.items = [[DataSource sharedDataSource] items];
    self.itemsTableView.dataSource = _itemsManager;
    self.itemsTableView.delegate = _itemsManager;
    self.itemSearchBar.delegate = self;
    self.recommendedCollectionView.dataSource = self.recommendationManager;
    self.recommendedCollectionView.delegate = self.recommendationManager;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Deselect all rows
    for (NSIndexPath *indexPath in _itemsTableView.indexPathsForSelectedRows) {
        [self.itemsTableView deselectRowAtIndexPath:indexPath animated:NO];
    }

    [self sendRecommend];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowItem"]) {
        ItemDetailViewController *ctr = segue.destinationViewController;
        ctr.item = self.itemsManager
                       .items[self.itemsTableView.indexPathForSelectedRow.row];
    } else if ([segue.identifier isEqualToString:@"ShowRecommendedItem"]) {
        ItemDetailViewController *ctr = segue.destinationViewController;
        RecommendedItem *recItem = sender;
        ctr.item = recItem.item;
    }
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    if ((searchText && searchText.length)) {
        NSPredicate *resultPredicate = [NSPredicate
            predicateWithFormat:@"title CONTAINS[c] %@", searchText];
        self.itemsManager.items = [[[DataSource sharedDataSource] items]
            filteredArrayUsingPredicate:resultPredicate];
        self.searchTerm = searchText;
    } else {
        self.searchTerm = nil;
        self.itemsManager.items = [[DataSource sharedDataSource] items];
        [searchBar resignFirstResponder];
    }
    [self.itemsTableView reloadData];
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

    EMRecommendationRequest *recommend =
        [[EMRecommendationRequest alloc] initWithLogic:@"PERSONAL"];

    recommend.limit = 10;

    recommend.completionHandler = ^(EMRecommendationResult *_Nonnull result) {

      // Process result
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
