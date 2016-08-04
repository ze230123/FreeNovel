//
//  ModelObject.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/2.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface ModelObject : NSManagedObject

+ (id)entityName;
+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)content;

+ (void)removeAllObjectWithPredicate:(NSString *)predicate inContext:(NSManagedObjectContext *)context;

+ (NSArray *)resultWithPredicate:(NSString *)predicate sortDescriptors:(NSArray*)sorts inContext:(NSManagedObjectContext *)context;

+ (NSInteger)countForPredicate:(NSString *)predicate inContext:(NSManagedObjectContext *)context;

+ (id)findWithPredicate:(NSString *)predicate inContext:(NSManagedObjectContext *)context;

+ (id)findOrCreateWithPredicate:(NSString *)predicate inContext:(NSManagedObjectContext *)context;

@end
