//
//  TextDisplayView.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/7.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "TextDisplayView.h"
#import <CoreText/CoreText.h>

@interface TextDisplayView ()


@end

@implementation TextDisplayView
//
//- (instancetype)initWithFrame:(CGRect)frame text:(NSAttributedString *)text {
//    self = [super initWithFrame:frame];
//    if (self) {
//        _string = text;
//        self.backgroundColor = [UIColor whiteColor];
//    }
//    return self;
//}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // 步骤 1
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 步骤 2
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // 步骤 3
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    // 步骤 4
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:self.string];
    [attString addAttributes:[self coreTextAttributes] range:NSMakeRange(0, attString.length)];
    CTFramesetterRef framesetter =
    CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CTFrameRef frame =
    CTFramesetterCreateFrame(framesetter,
                             CFRangeMake(0, [_string length]), path, NULL);
    
    // 步骤 5
    CTFrameDraw(frame, context);
    
    // 步骤 6
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}

- (NSDictionary *)coreTextAttributes {
    UIFont *font_ = [UIFont systemFontOfSize:self.font];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = font_.pointSize / 2;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    
    NSDictionary *dic = @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName:font_};
    return dic;
}

@end
