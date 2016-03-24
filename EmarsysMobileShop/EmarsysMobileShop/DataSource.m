//
//  DataSource.m
//  EmarsysMobileShop
//

#import "DataSource.h"

NS_ASSUME_NONNULL_BEGIN

@implementation DataSource

- (nullable instancetype)init {
    NSAssert(false, @"Unavailable init methods was invoked");
    return nil;
}

+ (DataSource *)sharedDataSource {
    static DataSource *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      _shared = [[DataSource alloc] initInternal];
    });
    return _shared;
}

- (instancetype)initInternal {
    self = [super init];
    if (self) {
        _items = [[NSMutableArray alloc] init];
        _categories = [[NSMutableArray alloc] init];
        NSString *path =
            [[NSBundle mainBundle] pathForResource:@"/sample" ofType:@"csv"];
        NSString *content =
            [NSString stringWithContentsOfFile:path
                                      encoding:NSUTF8StringEncoding
                                         error:NULL];
        NSArray<NSString *> *rows = [content
            componentsSeparatedByCharactersInSet:[NSCharacterSet
                                                     newlineCharacterSet]];
        for (int i = 1; i < [rows count]; i++) {
            NSString *row = [rows objectAtIndex:i];
            Item *item = [[Item alloc] init];
            NSArray *cells = [row componentsSeparatedByString:@","];
            for (int j = 0; j < [cells count]; j++) {
                switch (j) {
                case 0:
                    item.itemID = [cells objectAtIndex:j];
                    break;
                case 1:
                    item.link = [cells objectAtIndex:j];
                    break;
                case 2:
                    item.title = [cells objectAtIndex:j];
                    break;
                case 3:
                    item.image = [cells objectAtIndex:j];
                    break;
                case 4:
                    item.category = [cells objectAtIndex:j];
                    if (![_categories containsObject:item.category]) {
                        [_categories addObject:item.category];
                    }
                    break;
                case 5:
                    item.price = [[cells objectAtIndex:j] floatValue];
                    break;
                case 6:
                    item.available = [[cells objectAtIndex:j] boolValue];
                    break;
                case 7:
                    item.brand = [cells objectAtIndex:j];
                    break;
                }
            }
            [_items addObject:item];
        }
    }
    return self;
}

- (NSArray<Item *> *)itemsFromCategory:(NSString *)category {
    NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"category == %@", category];
    return [_items filteredArrayUsingPredicate:predicate];
}

@end

NS_ASSUME_NONNULL_END
