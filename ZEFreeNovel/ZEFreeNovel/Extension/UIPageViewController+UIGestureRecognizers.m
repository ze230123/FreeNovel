//
//  UIPageViewController+UIGestureRecognizers.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/30.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "UIPageViewController+UIGestureRecognizers.h"
@class ReadViewController;
@implementation UIPageViewController (UIGestureRecognizers) 


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    CGPoint point = [gestureRecognizer locationInView:self.view];
    NSLog(@"x == %f  , y == %f",point.x,point.y);
    if (point.x >= 80 && point.x <= SCREEN_WIDTH-80 && self.parentViewController.navigationController.navigationBarHidden) {
        if ([self.parentViewController respondsToSelector:@selector(showhide)]) {
            [self.parentViewController performSelector:@selector(showhide)];
        }
    }
    return YES;
}


@end
