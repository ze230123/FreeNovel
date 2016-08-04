//
//  ReadBooksModel.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "ReadBooksModel.h"
#import "BookChapter.h"

@implementation ReadBooksModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"chapterList" : [BookChapter class],
             };
}

+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{
             @"Id" : @"showapi_res_body.book.id",
             @"name":@"showapi_res_body.book.name",
             @"author":@"showapi_res_body.book.author",
             @"updateTime":@"showapi_res_body.book.updateTime",
             @"latestChapter":@"showapi_res_body.book.newChapter",
             @"chapterList":@"showapi_res_body.book.chapterList"
             };
}

- (instancetype)init {
    if (self = [super init]) {
//        _record = [[ReadRecord alloc]init];
    }
    return self;
}
//showapi_res_body.book.
//"showapi_res_body": {
//    "book": {
//        "author": "肉丝抓饭",
//        "chapterList": [
//                        {
//                            "bookId": "124227",
//                            "cid": "22048512",
//                            "name": "第一章 古界"
//                        }
//                        ],
//        "id": "124227",
//        "name": "审判界 下载",
//        "newChapter": " 第19章 我准备好了",
//        "size": "83K",
//        "type": "1",
//        "typeName": "玄幻魔法",
//        "updateTime": "15-08-09"
//    },
//    "ret_code": 0

@end
