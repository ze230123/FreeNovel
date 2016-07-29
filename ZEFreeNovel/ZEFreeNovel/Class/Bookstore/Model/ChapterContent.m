//
//  ChapterContent.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "ChapterContent.h"

@implementation ChapterContent

//"showapi_res_body": {
//    "cid": "22048512",
//    "cname": "第一章 古界",
//    "id": "124227",
//    "ret_code": 0,
//    "txt": "上古世界，昏天黑地，可依旧有人类坚强生活，......."
//}
+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{
             @"bookId" : @"showapi_res_body.id",
             @"name":@"showapi_res_body.cname",
             @"cid":@"showapi_res_body.cid",
             @"txt":@"showapi_res_body.txt"
             };
}


@end
