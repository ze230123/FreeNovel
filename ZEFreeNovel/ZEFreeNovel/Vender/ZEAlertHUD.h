//
//  ZEAlertHUD.h
//  提示框
//
//  Created by 泽i on 16/8/23.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZEAlertHUD : UIView

@property (nonatomic, copy) NSString *message;


+ (void)showMessage:(NSString *)message inView:(UIView*)view;

@end
