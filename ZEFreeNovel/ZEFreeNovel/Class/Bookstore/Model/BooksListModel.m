//
//  BooksListModel.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "BooksListModel.h"
#import "BooksModel.h"

@implementation BooksListModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"contentlist" : [BooksModel class],
             };
}

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"allNum":@"showapi_res_body.pagebean.allNum",
             @"allPages":@"showapi_res_body.pagebean.allPages",
             @"currentPage":@"showapi_res_body.pagebean.currentPage",
             @"maxResult":@"showapi_res_body.pagebean.maxResult",
             @"contentlist" : @"showapi_res_body.pagebean.contentlist"
             };
}


@end
