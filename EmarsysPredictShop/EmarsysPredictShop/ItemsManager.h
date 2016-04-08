//
//  ItemsManager.h
//  EmarsysPredictShop
//

@import Foundation;
@import UIKit;

#import "Item.h"

@interface ItemsManager : NSObject <UITableViewDataSource, UITableViewDelegate>

@property NSArray<Item *> *items;

@end
