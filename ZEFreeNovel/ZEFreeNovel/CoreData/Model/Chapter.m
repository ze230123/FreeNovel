//
//  Chapter.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/3.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "Chapter.h"

@implementation Chapter

- (void)loadFromDictionary:(NSDictionary *)dictionary {
    self.cid = dictionary[@"cid"];
    self.name = dictionary[@"name"];
    self.bookId = dictionary[@"bookId"];
    self.txt = @"";
    self.isLoad = @(NO);
}

+ (Chapter *)findOrCreatePodWithIdentifier:(NSString *)identifier inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"cid = %@", identifier];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error: %@", error.localizedDescription);
    }
    if (result.lastObject) {
        return result.lastObject;
    } else {
        Chapter *chapter = [self insertNewObjectIntoContext:context];
        return chapter;
    }
}
// Insert code here to add functionality to your managed object subclass

@end
