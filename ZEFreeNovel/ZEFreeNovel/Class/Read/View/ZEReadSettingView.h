//
//  ZEReadSettingView.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/11.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol ZEReadSettingViewDelegate;

/** 字体背景色设置视图 */
@interface ZEReadSettingView : UIView

@property (nonatomic, assign) NSInteger colorIndex;

@property (nonatomic, assign) NSInteger textFont;

@property (nonatomic, weak) id <ZEReadSettingViewDelegate>delegate;
/**
 *  显示
 */
- (void)show;
/**
 *  隐藏
 */
- (void)hidden;

@end


@protocol ZEReadSettingViewDelegate <NSObject>

- (void)changedFont:(NSInteger)font;

- (void)backgroudColorDidChanged:(NSInteger)colorIndex;
@end
