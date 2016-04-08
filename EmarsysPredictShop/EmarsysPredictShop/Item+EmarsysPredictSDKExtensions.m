//
//  Item+EmarsysPredictSDKExtensions.m
//  EmarsysPredictShop
//

@import Foundation;

#import "Item+EmarsysPredictSDKExtensions.h"

@implementation Item (EmarsysPredictSDKExtensions)

- (void)convertItem {
    for (NSString *key in self.srcItem.data.allKeys) {
        if ([key isEqualToString:@"item"]) {
            self.itemID = [self.srcItem.data objectForKey:key];
        } else if ([key isEqualToString:@"link"]) {
            self.link = [self.srcItem.data objectForKey:key];
        } else if ([key isEqualToString:@"title"]) {
            self.title = [self.srcItem.data objectForKey:key];
        } else if ([key isEqualToString:@"image"]) {
            self.image = [self.srcItem.data objectForKey:key];
        } else if ([key isEqualToString:@"price"]) {
            self.price = [[self.srcItem.data objectForKey:key] floatValue];
        } else if ([key isEqualToString:@"category"]) {
            self.category = [self.srcItem.data objectForKey:key];
        } else if ([key isEqualToString:@"available"]) {
            self.available = [[self.srcItem.data objectForKey:key] boolValue];
        } else if ([key isEqualToString:@"brand"]) {
            self.brand = [self.srcItem.data objectForKey:key];
        }
    }
}

@end
