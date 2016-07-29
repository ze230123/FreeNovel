//
//  BooksModel.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "BooksModel.h"

@implementation BooksModel



+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{
             @"Id" : @"id",
             @"latestChapter":@"newChapter"
             };
}

@end
