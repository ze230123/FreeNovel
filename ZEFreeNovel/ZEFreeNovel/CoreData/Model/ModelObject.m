//
//  ModelObject.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/2.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "ModelObject.h"

@implementation ModelObject

+ (id)entityName {
    return NSStringFromClass(self);
}

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)content {
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:content];
}
+ (id)findWithPredicate:(NSString *)predicate inContext:(NSManagedObjectContext *)context {
    NSArray *result = [self resultWithPredicate:predicate sortDescriptors:nil inContext:context];
    if (result.lastObject) {
        return result.lastObject;
    }
    return nil;
}

+ (void)removeAllObjectWithPredicate:(NSString *)predicate inContext:(NSManagedObjectContext *)context {
    NSArray *result = [self resultWithPredicate:predicate sortDescriptors:nil inContext:context];
    for (id range in result) {
        [context deleteObject:range];
    }
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"error: %@",error.localizedDescription);
    }
}

+ (NSInteger)countForPredicate:(NSString *)predicate inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [self requestWithPredicate:predicate sortDescriptors:nil];
    NSError *error;
    NSUInteger count = [context countForFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error: %@",error.localizedDescription);
    }
    return count;
}

+ (NSArray *)resultWithPredicate:(NSString *)predicate sortDescriptors:(NSArray*)sorts inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [self requestWithPredicate:predicate sortDescriptors:sorts];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error: %@",error);
    }
    return result;
}
+ (id)findOrCreateWithPredicate:(NSString *)predicate inContext:(NSManagedObjectContext *)context {
    id obj = [self findWithPredicate:predicate inContext:context];
    if (!obj) {
        obj = [self insertNewObjectIntoContext:context];
    }
    return obj;
}


+ (NSFetchRequest *)requestWithPredicate:(NSString *)predicate sortDescriptors:(NSArray*)sort {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:predicate];
    NSMutableArray *sorts = [NSMutableArray array];
    for (NSDictionary *dict in sort) {
        [sorts addObject:[NSSortDescriptor sortDescriptorWithKey:dict[@"key"] ascending:[dict[@"ascending"] boolValue]]];
    }
    if (sorts.count) {
        fetchRequest.sortDescriptors = sorts;
    }
    return fetchRequest;
}
@end
