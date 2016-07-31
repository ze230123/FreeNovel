//
//  HttpUtils.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/25.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "HttpUtils.h"
#import "NSString+Extension.h"

#import "AFAppDotNetAPIClient.h"

@implementation HttpUtils

+ (void)post:(NSString *)url parameters:(NSDictionary *)parameters callBack:(void(^)(id data, NSError *error))block {
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//
//    [manager POST:url parameters:[HttpUtils createSecretParam:parameters] progress:^(NSProgress * _Nonnull uploadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        scusses(responseObject);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        
//    }];
//    [manager invalidateSessionCancelingTasks:YES];
    [[AFAppDotNetAPIClient sharedClient] POST:url
                                   parameters:[HttpUtils createSecretParam:parameters]
                                     progress:nil
                                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                 if (block) {
                                                     block(responseObject,nil);
                                                 }
                                             }
                                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                 if (block) {
                                                     block(nil,error);
                                                 }
                                             }];
}
+ (NSDictionary *)createSecretParam:(NSDictionary*)param {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    
    NSMutableDictionary *paramet = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"20855",@"showapi_appid",[formatter stringFromDate:[NSDate date]],@"showapi_timestamp", nil];
    NSArray *paramKeys = [param allKeys];
    for (NSString *key in paramKeys) {
        [paramet setObject:param[key] forKey:key];
    }
    NSArray *keys = [[paramet allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString * obj2) {
        return [obj1 compare:obj2];
    }];
    NSMutableString *temp = [NSMutableString string];
    for (NSString *key in keys) {
        [temp appendFormat:@"%@%@",key,paramet[key]];
    }
    [temp appendFormat:@"%@",@"21ca8ee0cc0c4c129ef93f50ccebe8a5"];
    [paramet setObject:temp.md5 forKey:@"showapi_sign"];
    
    return paramet;
}


@end
