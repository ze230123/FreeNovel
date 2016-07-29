//
//  ReadViewController.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BooksModel.h"

/**
 *  阅读模块
 */
@interface ReadViewController : UIViewController

/**
 *  初始化
 *
 *  @param bookID 图书ID
 *
 *  @return 实例对象
 */
- (instancetype)initWithBooksInfo:(NSString *)bookID;

@end
