//
//  NSString+Extension.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/25.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)
/**
 *  进行MD5加密
 *
 *  @return 加密后的字符串
 */
- (NSString *)md5;
/**
 *  数字字符串加一操作
 *
 *  @return 加一后的字符串
 */
- (NSString *)addOne;

- (NSString *)paging:(NSRange)range;

@end
