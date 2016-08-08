//
//  Chapter.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/3.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreData/CoreData.h>
#import "ModelObject.h"

@class Range;
NS_ASSUME_NONNULL_BEGIN

@interface Chapter : ModelObject


- (void)loadFromDictionary:(NSDictionary *)dictionary;
+ (Chapter *)findOrCreatePodWithIdentifier:(NSString *)identifier inContext:(NSManagedObjectContext *)context;

// Insert code here to declare functionality of your managed object subclass
@end

NS_ASSUME_NONNULL_END

#import "Chapter+CoreDataProperties.h"
