//
//  PersistentStack.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/2.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Range.h"
#import "Book.h"
#import "Chapter.h"

@interface PersistentStack : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *context;
@property (nonatomic, strong, readonly) NSManagedObjectContext *backgroundContext;

+ (instancetype)stack;
- (void)removeRecordWith:(NSString *)bookId;

- (void)save;
@end
