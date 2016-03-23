//
//  RecommendedItemsCell.m
//  EmarsysMobileShop
//

#import "RecommendedItemsCell.h"
#import "RecommendedItem.h"

@implementation RecommendedItemsCell

static NSString *const reuseIdentifier = @"ItemCell";

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:
    (UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecommendedItem *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                  forIndexPath:indexPath];

    // Configure the cell

    NSAssert(cell, @"No cell");

    Item *item = self.items[indexPath.row];

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

#pragma mark <UICollectionViewDelegate>

@end
