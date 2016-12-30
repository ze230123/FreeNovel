//
//  ZEReadSettingView.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/11.
//  Copyright © 2016年 泽i. All rights reserved.
//

#define MIN_FONT 17
#define MAX_FONT 30

#import "ZEReadSettingView.h"

@implementation ZEReadSettingView {
    UISegmentedControl *fontControl;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (void)setTextFont:(NSInteger)textFont {
    _textFont = textFont;
    [self createSegmentedControl];
}
- (void)setColorIndex:(NSInteger)colorIndex {
    _colorIndex = colorIndex;
    [self createColorButtons];
}
- (void)createColorButtons {
    for (NSInteger idx = 0; idx < 5 ; idx++) {
        UIButton * themeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        themeButton.layer.cornerRadius = 2.0f;
        themeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        themeButton.frame = CGRectMake(20 + 36*idx + (self.frame.size.width - 60 - 6 *36)*(idx)/3, 40, 36, 36);
        
        if (idx == self.colorIndex) {
            themeButton.selected = YES;
        }
        
        [themeButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"reader_bg%ld.png",idx]] forState:UIControlStateNormal];
        [themeButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"reader_bg%ld.png",idx]] forState:UIControlStateSelected];

        [themeButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"reader_bg_s.png"]] forState:UIControlStateSelected];
        [themeButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"reader_bg_s.png"]] forState:UIControlStateHighlighted];
        themeButton.tag = 7000+idx;
        [themeButton addTarget:self action:@selector(themeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:themeButton];
        
    }
}
- (void)createSegmentedControl {
    fontControl = [[UISegmentedControl alloc]initWithItems:@[@"Aa-",@"Aa+"]];
    fontControl.frame = CGRectMake(20, 5, self.frame.size.width, 35);
    fontControl.momentary = YES;
    [fontControl addTarget:self action:@selector(fontSetting:) forControlEvents:UIControlEventValueChanged];
    [self segmentedControlState:fontControl];
    
    fontControl.frame = CGRectMake(20, 5, SCREEN_WIDTH-40, 30);
    [self addSubview:fontControl];
}
- (void)themeButtonPressed:(UIButton *)sender{
    if (!sender.isSelected) {
        [sender setSelected:YES];
        if ([self.delegate respondsToSelector:@selector(backgroudColorDidChanged:)]) {
            [self.delegate backgroudColorDidChanged:sender.tag - 7000];
        }
    }
    for (int i = 0; i < 5; i++) {
        UIButton * button = (UIButton *)[self viewWithTag:7000+i];
        if (button.tag != sender.tag) {
            [button setSelected:NO];
        }
    }
}

- (void)fontSetting:(UISegmentedControl *)sender {
    NSInteger index = sender.selectedSegmentIndex;
    switch (index) {
        case 0:
            self.textFont = self.textFont - 1 <= MIN_FONT ? MIN_FONT : self.textFont - 1;
            if (![sender isEnabledForSegmentAtIndex:1]) {
                [sender setEnabled:YES forSegmentAtIndex:1];
            }
            break;
        case 1:
            self.textFont = self.textFont + 1 >= MAX_FONT ? MAX_FONT : self.textFont + 1;
            if (![sender isEnabledForSegmentAtIndex:0]) {
                [sender setEnabled:YES forSegmentAtIndex:0];
            }
            break;
        default:
            break;
    }
    [self segmentedControlState:sender];
    NSLog(@"现在的字号：%ld",self.textFont);
    if ([self.delegate respondsToSelector:@selector(changedFont:)]) {
        [self.delegate changedFont:self.textFont];
    }
}
- (void)segmentedControlState:(UISegmentedControl *)sender {
    if (self.textFont == MIN_FONT) {
        [sender setEnabled:NO forSegmentAtIndex:0];
    } else if (self.textFont == MAX_FONT) {
        [sender setEnabled:NO forSegmentAtIndex:1];
    }
}

- (void)show {
    CGRect frame = self.frame;
    frame.origin.y -= 100;
    [UIView animateWithDuration:0.1 animations:^{
        self.frame = frame;
    }];
}
- (void)hidden {
    CGRect frame = self.frame;
    frame.origin.y += 100;
    [UIView animateWithDuration:0.1 animations:^{
        self.frame = frame;
    } completion:^(BOOL finished) {
    }];
}

@end
