//
//  HttpUtils.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/25.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  网络请求类
 */
@interface HttpUtils : NSObject
/**
 *  post请求
 *
 *  @param url        URL
 *  @param parameters 附加参数
 *  @param scusses    完成回调Block
 */
+ (void)post:(NSString *)url parameters:(NSDictionary *)parameters callBack:(void(^)(id data, NSError *error))block;


@end
