//
//  ReadBooksModel.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BooksModel.h"
/**
 *  阅读图书模型
 */
@interface ReadBooksModel : BooksModel
/** 章节目录列表 */
@property (nonatomic, strong) NSArray *chapterList;

@end
