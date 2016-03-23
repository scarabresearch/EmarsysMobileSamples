//
//  RecommendedDataSourceAnddelegate.m
//  EmarsysMobileShop
//

#import "RecommendationManager.h"
#import "RecommendedItem.h"

@implementation RecommendationManager

static NSString *const reuseIdentifier = @"RecommendedItemCell";

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

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate) {
        [self.delegate updateWithItem:self.recommendResults[indexPath.row]];
    }
}

@end
