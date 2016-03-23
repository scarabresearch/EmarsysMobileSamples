//
//  ItemsManager.m
//  EmarsysMobileShop
//

#import "ItemsManager.h"

@implementation ItemsManager

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"ItemCell"];
    NSAssert(cell, @"No cell");

    Item *item = self.items[indexPath.row];

    [(UILabel *)[cell.contentView viewWithTag:11] setText:item.title];
    [(UILabel *)[cell.contentView viewWithTag:12]
        setText:[NSString stringWithFormat:@"$%.02f", item.price]];

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
            UITableViewCell *updateCell =
                (id)[tableView cellForRowAtIndexPath:indexPath];
            if (!updateCell) {
                return;
            }
            [(UIImageView *)[updateCell.contentView viewWithTag:13]
                setImage:image];
          });

        }];
    [task resume];

    return cell;
}
@end
