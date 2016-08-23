//
//  ZEAlertHUD.m
//  提示框
//
//  Created by 泽i on 16/8/23.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "ZEAlertHUD.h"

@implementation ZEAlertHUD {
    UILabel *_lable;
}

+ (void)showMessage:(NSString *)message inView:(UIView *)view {
    ZEAlertHUD *hud = [[ZEAlertHUD alloc]initWithFrame:view.bounds];
    hud.message = message;
    [view addSubview:hud];
    [hud show];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI {
    _lable = [[UILabel alloc]init];
//    _lable.hidden = YES;
    _lable.alpha = 0.0;
    _lable.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    _lable.font = [UIFont systemFontOfSize:17];
    _lable.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
    _lable.textColor = [UIColor whiteColor];
    _lable.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_lable];
}

- (void)show {
    _lable.text = self.message;
    CGSize textSize = [self.message sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}];
    CGRect frame = _lable.frame;
    frame.size = CGSizeMake(textSize.width+10, textSize.height+5);
    _lable.frame = frame;
    _lable.center = self.center;

    [UIView animateWithDuration:0.3 animations:^{
        _lable.alpha = 1.0;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hidded];
        });
    }];
}

- (void)hidded {
    [UIView animateWithDuration:0.2
                     animations:^{
                         _lable.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void)dealloc {
    NSLog(@"视图被销毁了");
}

@end
