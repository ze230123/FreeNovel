//
//  ChapterListViewController.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/5.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chapter.h"

typedef void(^SelectCallBack)(Chapter *chapter);

@interface ChapterListViewController : UIViewController

@property (nonatomic, assign) NSInteger readChapter;
@property (nonatomic, strong) NSArray *chapters;

- (instancetype)initWithSelectCallBackBlock:(SelectCallBack)block;

@end
