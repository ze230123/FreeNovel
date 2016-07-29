//
//  ChapterContent.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookChapter.h"
/**
 *  章节内容模型
 */
@interface ChapterContent : BookChapter
/** 章节内容 */
@property (nonatomic, copy) NSString *txt;

@end
