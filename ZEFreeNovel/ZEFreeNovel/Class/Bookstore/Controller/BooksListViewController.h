//
//  BooksListViewController.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "TypeModel.h"

/// 图书列表视图控制器
@interface BooksListViewController : UIViewController

/**
 *  初始化
 *
 *  @param model 图书类型模型
 *
 *  @return 控制器实例
 */
- (instancetype)initWithType:(TypeModel *)model;

@end
