//
//  PagingUtils.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/8.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "PagingUtils.h"

@implementation PagingUtils {
    NSMutableArray *array;
}

- (instancetype)init {
    if (self = [super init]) {
        array = [NSMutableArray array];
    }
    return self;
}
- (void)paging {

    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:_contentText];
    [str addAttributes:[self attributesWithFont:_contentFont] range:NSMakeRange(0, str.length)];
    
    CFAttributedStringRef cfAttStr = (__bridge CFAttributedStringRef)str;
    //直接桥接，引用计数不变
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(cfAttStr);
    int textPos = 0;
    NSInteger totalPage = 0;
    NSUInteger strLength = [str length];
    while (textPos < strLength)
    {
        CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, _textRenderSize.width, _textRenderSize.height), NULL);
        //设置路径
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        //生成frame
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        NSRange range = NSMakeRange(frameRange.location, frameRange.length);
        [array addObject:NSStringFromRange(range)];
        //获取范围并转换为NSRange，然后以NSString形式保存
        textPos += frameRange.length;
        //移动当前文本位置
        CFRelease(frame);
        CGPathRelease(path);
        totalPage++;
        //释放路径和frame，页数加1
    }
    CFRelease(framesetter);
}
- (NSUInteger)pageCount {
    return array.count-1;
}
- (NSString *)stringOfPage:(NSUInteger)page {
    if (page > array.count) {
        return @"";
    }
    NSRange range = NSRangeFromString(array[page]);
    return [_contentText substringWithRange:range];
}
- (NSInteger)locationWithPage:(NSInteger)page {
    NSRange range = NSRangeFromString(array[page]);
    return range.location;
}
- (NSInteger)pageWithTextOffSet:(NSInteger)OffSet {
    for (NSInteger idx = 0; idx < array.count; idx++) {
        NSRange range = NSRangeFromString(array[idx]);
        if (range.location <= OffSet && range.location + range.length > OffSet) {
            return idx;
        }
    }
    return 0;
}
- (NSDictionary *)attributesWithFont:(NSInteger)fontsize {
    UIFont *font = [UIFont systemFontOfSize:fontsize];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = font.pointSize / 2;
    paragraphStyle.alignment = NSTextAlignmentJustified;
//    paragraphStyle.firstLineHeadIndent = fontsize*2;
    return @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName:font};
}

@end
