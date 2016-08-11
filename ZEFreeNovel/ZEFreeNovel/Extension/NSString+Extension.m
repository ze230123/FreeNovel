//
//  NSString+Extension.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/25.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "NSString+Extension.h"


@implementation NSString (Extension)

- (NSString *)md5 {
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    
    return result;
}

- (NSString *)addOne {
    NSInteger num = [self integerValue];
    num += 1;
    return [NSString stringWithFormat:@"%ld",num];
}


- (NSString *)paging:(NSRange)range {
    return [self substringWithRange:range];
}

- (NSString *)deleteRedundantHTMLTags {
    return [self stringByReplacingOccurrencesOfString:@"<br /><br />" withString:@"<br/>"];
}

- (NSMutableAttributedString *)attributedString {
    return [[NSMutableAttributedString alloc]initWithData:[self dataUsingEncoding:NSUnicodeStringEncoding]
                                                  options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
                                       documentAttributes:nil
                                                    error:nil];
}

- (NSString *)FirstLineAddSpaces {
    NSMutableString *string = [NSMutableString stringWithString:[self stringByReplacingOccurrencesOfString:@"\n" withString:@"\n  "]];
    [string insertString:@"  " atIndex:0];
    return string;
}


@end
