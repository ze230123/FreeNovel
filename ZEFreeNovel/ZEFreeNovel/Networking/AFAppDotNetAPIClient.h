//
//  AFAppDotNetAPIClient.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/31.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface AFAppDotNetAPIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
