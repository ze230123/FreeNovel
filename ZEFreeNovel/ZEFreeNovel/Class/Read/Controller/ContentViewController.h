//
//  ContentViewController.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  内容显示视图控制器
 */
@interface ContentViewController : UIViewController
/** 显示的字符串 */
@property (nonatomic, copy) NSAttributedString *content;
/** 页面编号 */
@property (nonatomic, assign) NSInteger index;

@end
