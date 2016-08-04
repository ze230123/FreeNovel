//
//  Range.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/3.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "Range.h"

@implementation Range

- (void)loadFromDictionary:(NSDictionary *)dictionary {
    self.bookId = dictionary[@"bookId"];
    self.cid = dictionary[@"cid"];
    self.page = dictionary[@"page"];
    self.txt = dictionary[@"txt"];
    self.isLastPage = dictionary[@"isLastPage"];
}

//+ (NSInteger)CountForPredicate:(NSString *)predicate inContext:(NSManagedObjectContext *)context {
//    NSArray *result = [self resultWithPredicate:predicate inContext:context];
//    return result.count;
//}
//
//+ (void)removeAllObjectWithPredicate:(NSString *)predicate inContext:(NSManagedObjectContext *)context {
//    NSArray *result = [self resultWithPredicate:predicate inContext:context];
//    for (Range *range in result) {
//        [context deleteObject:range];
//    }
//}
//
//+ (NSArray *)resultWithPredicate:(NSString *)predicate inContext:(NSManagedObjectContext *)context {
//    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
//    fetchRequest.predicate = [NSPredicate predicateWithFormat:predicate];
//    NSError *error = nil;
//    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
//    if (error) {
//        NSLog(@"error: %@",error);
//    }
//    return result;
//}

// Insert code here to add functionality to your managed object subclass

@end
