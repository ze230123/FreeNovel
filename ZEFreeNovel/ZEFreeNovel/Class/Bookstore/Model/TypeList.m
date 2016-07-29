//
//  TypeList.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "TypeList.h"

@implementation TypeList

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"typeList" : [TypeModel class],
             };
}

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"typeList" : @"showapi_res_body.typeList",
             };
}





@end
