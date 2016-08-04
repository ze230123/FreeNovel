//
//  Range.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/3.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ModelObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface Range : ModelObject

- (void)loadFromDictionary:(NSDictionary *)dictionary;
//+ (Range *)findRangeWithPredicate:(NSString *)predicate inContext:(NSManagedObjectContext *)context;
//+ (NSInteger)CountForPredicate:(NSString *)predicate inContext:(NSManagedObjectContext *)context;
//+ (void)removeAllObjectWithPredicate:(NSString *)predicate inContext:(NSManagedObjectContext *)context;
// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Range+CoreDataProperties.h"
