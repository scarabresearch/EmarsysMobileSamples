//
//  CartViewController.m
//  EmarsysMobileShop
//

@import Foundation;

#import "CartViewController.h"
#import "AppDelegate.h"
#import "ItemDetailViewController.h"
#import "Cart+EmarsysMobileExtensions.h"
#import "DataSource.h"
#import "RecommendedItemsCell.h"
#import "RecommendedItem.h"
#import "CartItemCell.h"

@implementation CartViewController

static NSString *const reuseIdentifier = @"ItemCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self.cartItemsTableView
                                             selector:@selector(reloadData)
                                                 name:@"CartChanged"
                                               object:nil];

    self.recommendResults = [[NSMutableArray alloc] init];
    self.cartItemsTableView.dataSource = self;
    self.cartItemsTableView.delegate = self;
    self.recommendedCollectionView.dataSource = self;
    self.recommendedCollectionView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Deselect all rows
    for (NSIndexPath *indexPath in _cartItemsTableView
             .indexPathsForSelectedRows) {
        [self.cartItemsTableView deselectRowAtIndexPath:indexPath animated:NO];
    }

    [self sendRecommend];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if ([Cart sharedCart].cartItems.count == 0) {
        self.buyButton.enabled = false;
    } else {
        self.buyButton.enabled = true;
    }
    return [Cart sharedCart].cartItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    CartItemCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"CartItemCell"];
    NSAssert(cell, @"No cell");

    CartItem *cartItem = [Cart sharedCart].cartItems[indexPath.row];

    [cell.cost
        setText:[NSString stringWithFormat:@"$%.02f", cartItem.item.price *
                                                          cartItem.count]];
    [cell.title setText:cartItem.item.title];
    [cell.count setText:[NSString stringWithFormat:@"%d", cartItem.count]];

    NSURL *url = [NSURL URLWithString:cartItem.item.image];

    NSURLSessionTask *task = [[NSURLSession sharedSession]
          dataTaskWithURL:url
        completionHandler:^(NSData *_Nullable data,
                            NSURLResponse *_Nullable response,
                            NSError *_Nullable error) {

          if (!data) {
              return;
          }

          UIImage *image = [UIImage imageWithData:data];
          if (!image) {
              return;
          }

          dispatch_async(dispatch_get_main_queue(), ^{
            CartItemCell *updateCell =
                (id)[tableView cellForRowAtIndexPath:indexPath];
            if (!updateCell) {
                return;
            }
            updateCell.image.image = image;
          });

        }];
    [task resume];

    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CartShowItem"]) {
        ItemDetailViewController *ctr = segue.destinationViewController;
        ctr.item =
            [Cart sharedCart]
                .cartItems[self.cartItemsTableView.indexPathForSelectedRow.row]
                .item;
    } else if ([segue.identifier isEqualToString:@"CartShowRecommendedItem"]) {
        ItemDetailViewController *ctr = segue.destinationViewController;
        RecommendedItem *recItem = sender;
        ctr.item = recItem.item;
    }
}

- (BOOL)tableView:(UITableView *)tableView
    canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView beginUpdates];
    [[Cart sharedCart].cartItems removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
    [self sendRecommend];
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Remove from cart was successful."
                         message:nil
                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *defaultAction =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action){
                               }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)buy:(id)sender {
    EMTransaction *transaction = [[EMTransaction alloc] init];
    /// Report the list of items in the visitor's shopping cart. This command
    /// should be
    /// called on every page. Make sure all cart items are passed to the
    /// command. If
    /// the visitor's cart is empty, send the empty array [].
    NSArray<EMCartItem *> *cartItems = [[Cart sharedCart] convertItems];
    [transaction setCart:cartItems];

    /// Report a purchase event. This command should be called on the order
    /// confirmation page to report successful purchases. Also make sure all
    /// purchased items are passed to the command.
    NSString *orderID = [[NSUUID UUID] UUIDString];
    [transaction setPurchase:orderID ofItems:cartItems];

    /// Send transaction to the recommender server.
    EMSession *emarsysSession = [EMSession sharedSession];
    [emarsysSession sendTransaction:transaction
                       errorHandler:^(NSError *_Nonnull error) {
                         NSLog(@"Error: %@ %@", error, [error userInfo]);
                       }];

    [[Cart sharedCart].cartItems removeAllObjects];
    [self.cartItemsTableView reloadData];
    [self sendRecommend];

    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Buy was successful."
                         message:nil
                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *defaultAction =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action){
                               }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInCollectionView:
    (UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.recommendResults.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    RecommendedItem *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                  forIndexPath:indexPath];

    // Configure the cell

    NSAssert(cell, @"No cell");

    Item *item = self.recommendResults[indexPath.row];

    [cell.title setText:item.title];
    cell.item = item;
    NSURL *url = [NSURL URLWithString:item.image];

    NSURLSessionTask *task = [[NSURLSession sharedSession]
          dataTaskWithURL:url
        completionHandler:^(NSData *_Nullable data,
                            NSURLResponse *_Nullable response,
                            NSError *_Nullable error) {

          if (!data) {
              return;
          }

          UIImage *image = [UIImage imageWithData:data];

          if (!image) {
              return;
          }

          dispatch_async(dispatch_get_main_queue(), ^{
            RecommendedItem *updateCell =
                (id)[collectionView cellForItemAtIndexPath:indexPath];

            if (!updateCell) {
                return;
            }

            [updateCell.image setImage:image];
          });
        }];
    [task resume];

    return cell;
}

- (void)sendRecommend {

    EMSession *emarsysSession = [EMSession sharedSession];
    EMTransaction *transaction = [[EMTransaction alloc] init];

    /// Report the list of items in the visitor's shopping cart. This command
    /// should be
    /// called on every page. Make sure all cart items are passed to the
    /// command. If
    /// the visitor's cart is empty, send the empty array [].
    NSArray<EMCartItem *> *cartItems = [[Cart sharedCart] convertItems];
    [transaction setCart:cartItems];

    self.recommendResults = [[NSMutableArray alloc] init];

    EMRecommendationRequest *recommend =
        [[EMRecommendationRequest alloc] initWithLogic:@"CART"];
    recommend.limit = 10;
    recommend.completionHandler = ^(EMRecommendationResult *_Nonnull result) {

      // Process result
      NSLog(@"%@", result.featureID);
      [result.products
          enumerateObjectsUsingBlock:^(EMRecommendationItem *_Nonnull obj,
                                       NSUInteger idx, BOOL *_Nonnull stop) {

            Item *item = [[Item alloc] initWithItem:obj];
            [self.recommendResults addObject:item];
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
