//
//  ZEToolBar.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/11.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "ZEToolBar.h"

@implementation ZEToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self UI];
    }
    return self;
}

- (void)UI {
//    UIBarButtonItem *listButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"reader_cover"] style:UIBarButtonItemStylePlain target:self action:@selector(listTap)];
//    UIBarButtonItem *space1 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
//    UIBarButtonItem *setting = [[UIBarButtonItem alloc]initWithTitle:@"Aa" style:UIBarButtonItemStylePlain target:self action:@selector(setting)];
//    UIBarButtonItem *space2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
//    UIBarButtonItem *more = [[UIBarButtonItem alloc]initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(more)];
//    [self setItems:@[listButton,space1,setting,space2,more] animated:NO];
}
- (void)listTap {
//    if ([self.delegate respondsToSelector:@selector(willDisplayChapterList)]) {
//        [self.delegate willDisplayChapterList];
//    }
}
- (void)setting {
    
}
- (void)more {
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
