//
//  CategoriesViewController.m
//  EmarsysPredictShop
//

@import UIKit;
#import <EmarsysPredictSDK/EmarsysPredictSDK.h>

#import "CategoriesViewController.h"
#import "Cart+EmarsysPredictSDKExtensions.h"
#import "DataSource.h"
#import "RecommendedItem.h"
#import "RecommendedItemsCell.h"
#import "CategoryViewController.h"
#import "ItemDetailViewController.h"

@interface CategoriesViewController ()

@end

@implementation CategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.

    self.categoriesTableView.delegate = self;
    self.categoriesTableView.dataSource = self;
    self.recommendedTableView.delegate = self;
    self.recommendedTableView.dataSource = self;
    self.recommendResults = [[NSMutableArray alloc] init];
    self.categories = [[NSMutableArray<NSString *> alloc] init];
    self.itemsWithTopics =
        [[NSMutableDictionary<id, NSMutableArray<Item *> *> alloc] init];
    self.categories = [[NSMutableArray<NSString *> alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Deselect all rows
    for (NSIndexPath *indexPath in _categoriesTableView
             .indexPathsForSelectedRows) {
        [self.categoriesTableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    for (NSIndexPath *indexPath in _recommendedTableView
             .indexPathsForSelectedRows) {
        [self.recommendedTableView deselectRowAtIndexPath:indexPath
                                                 animated:NO];
    }

    self.shopTopics = [[DataSource sharedDataSource] categories];

    [self sendRecommend];
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.categoriesTableView) {
        return @"";
    } else {
        return [_categories objectAtIndex:section];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.categoriesTableView) {
        return 1;
    }
    return self.categories.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.categoriesTableView) {
        return self.shopTopics.count;
    }
    return 1;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowCategory"]) {
        CategoryViewController *ctr = segue.destinationViewController;
        ctr.category =
            self.shopTopics[_categoriesTableView.indexPathForSelectedRow.row];
    } else if ([segue.identifier isEqualToString:@"ShowSelectedRecItem"]) {
        ItemDetailViewController *ctr = segue.destinationViewController;
        RecommendedItem *recItem = sender;
        ctr.item = recItem.item;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.categoriesTableView) {
        UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:@"CategoryCell"];
        NSAssert(cell, @"No cell");
        cell.textLabel.text = self.shopTopics[indexPath.row];
        return cell;
    } else {
        NSString *category = [_categories objectAtIndex:indexPath.section];
        NSMutableArray *categoryItems =
            [self.itemsWithTopics objectForKey:category];

        RecommendedItemsCell *cell = [tableView
            dequeueReusableCellWithIdentifier:@"RecommendedItemCell"];
        NSAssert(cell, @"No cell");

        cell.items = categoryItems;
        cell.RecommendedCollectionView.dataSource = cell;
        cell.RecommendedCollectionView.delegate = cell;
        [cell.RecommendedCollectionView reloadData];

        return cell;
    }
}

// TOPICAL
- (void)sendRecommend {
    [self.recommendResults removeAllObjects];
    [self.categories removeAllObjects];
    [self.itemsWithTopics removeAllObjects];
    [self.recommendedTableView reloadData];

    EMSession *emarsysSession = [EMSession sharedSession];
    EMTransaction *transaction = [[EMTransaction alloc] init];
    NSArray<EMCartItem *> *cartItems = [[Cart sharedCart] convertItems];
    [transaction setCart:cartItems];

    for (int i = 0; i < 10; i++) {
        NSString *logic = [NSString stringWithFormat:@"%@%i", @"HOME_", i];
        EMRecommendationRequest *recommend =
            [[EMRecommendationRequest alloc] initWithLogic:logic];
        recommend.limit = 10;
        recommend.completionHandler =
            ^(EMRecommendationResult *_Nonnull result) {

              // Process result
              if (result.topic) {

                  if (![self.categories containsObject:result.topic]) {
                      [self.categories addObject:result.topic];
                  }
                  if (![self.itemsWithTopics objectForKey:result.topic]) {
                      NSMutableArray<Item *> *newCategoryItems =
                          [[NSMutableArray<Item *> alloc] init];
                      [self.itemsWithTopics setObject:newCategoryItems
                                               forKey:result.topic];
                  }

                  [result.products enumerateObjectsUsingBlock:^(
                                       EMRecommendationItem *_Nonnull obj,
                                       NSUInteger idx, BOOL *_Nonnull stop) {

                    Item *item = [[Item alloc] initWithItem:obj];
                    [self.recommendResults addObject:item];
                    NSMutableArray *categoryItems =
                        [self.itemsWithTopics objectForKey:result.topic];
                    [categoryItems addObject:item];
                  }];
              }

              dispatch_async(dispatch_get_main_queue(), ^{
                [self.recommendedTableView reloadData];
              });
            };
        [transaction recommend:recommend];
    }

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
