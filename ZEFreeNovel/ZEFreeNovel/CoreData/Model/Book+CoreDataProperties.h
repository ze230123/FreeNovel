//
//  Book+CoreDataProperties.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/4.
//  Copyright © 2016年 泽i. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Book.h"

NS_ASSUME_NONNULL_BEGIN

@interface Book (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *bookId;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *readChapter;
@property (nullable, nonatomic, retain) NSNumber *readPage;
@property (nullable, nonatomic, retain) NSNumber *isSave;
@property (nullable, nonatomic, retain) NSDate *readTime;

@end

NS_ASSUME_NONNULL_END
