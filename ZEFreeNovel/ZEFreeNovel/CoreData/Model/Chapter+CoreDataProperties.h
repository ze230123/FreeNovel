//
//  Chapter+CoreDataProperties.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/4.
//  Copyright © 2016年 泽i. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Chapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface Chapter (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *cid;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *txt;
@property (nullable, nonatomic, retain) NSNumber *isLoad;
@property (nullable, nonatomic, retain) NSString *bookId;

@end

NS_ASSUME_NONNULL_END
