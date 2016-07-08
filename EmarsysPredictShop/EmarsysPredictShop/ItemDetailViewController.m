//
//  ItemDetailViewController.m
//  EmarsysPredictShop
//

@import Foundation;
#import <EmarsysPredictSDK/EmarsysPredictSDK.h>

#import "ItemDetailViewController.h"
#import "Cart+EmarsysPredictSDKExtensions.h"
#import "RecommendedItem.h"

@interface ItemDetailViewController () <RecommendationManagerDelegate>

@end

@implementation ItemDetailViewController

static NSString *const reuseIdentifier = @"ItemCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.recommendationManager = [[RecommendationManager alloc] init];
    self.recommendationManager.recommendResults = [[NSMutableArray alloc] init];
    self.recommendationManager.delegate = self;
    self.recommendedCollectionView.dataSource = self.recommendationManager;
    self.recommendedCollectionView.delegate = self.recommendationManager;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateItem];
}

- (void)updateWithItem:(Item *)newItem {
    self.item = newItem;
    [self updateItem];
}

- (void)updateItem {
    self.name.text = self.item.title;
    self.availability.text = [NSString
        stringWithFormat:@"Availability: %@",
                         self.item.available ? @"IN STOCK" : @"OUT OF STOCK"];
    self.availability.textColor =
        self.item.available
            ? [UIColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:1.0]
            : [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0];
    self.price.text = [NSString stringWithFormat:@"$%.02f", self.item.price];

    NSURL *url = [NSURL URLWithString:_item.image];

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
            [self.image setImage:image];
          });
        }];

    [task resume];

    [self sendRecommend];
}

- (IBAction)addToCart:(id)sender {
    [[Cart sharedCart] addItem:_item];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CartChanged"
                                                        object:nil];
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Item added to cart"
                         message:nil
                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *defaultAction =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action){
                               }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];

    [self sendRecommend];
}

- (void)sendRecommend {
    [self.recommendationManager.recommendResults removeAllObjects];
    [self.recommendedCollectionView reloadData];

    EMSession *emarsysSession = [EMSession sharedSession];
    EMTransaction *transaction =
        [[EMTransaction alloc] initWithSelectedItemView:_item.srcItem];

    NSArray<EMCartItem *> *cartItems = [[Cart sharedCart] convertItems];
    [transaction setCart:cartItems];

    // Passing on item ID to report product view. Item ID should match the
    // value listed in the Product Catalog
    [transaction setView:_item.itemID];

    NSString *logic = @"RELATED";

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *userLogic = [defaults objectForKey:ItemDetailLogic];
    if (userLogic) {
        logic = userLogic;
    }

    EMRecommendationRequest *recommend =
        [[EMRecommendationRequest alloc] initWithLogic:logic];

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
