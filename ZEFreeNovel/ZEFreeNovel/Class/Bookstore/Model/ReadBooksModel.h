//
//  ReadBooksModel.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BooksModel.h"
#import "ReadRecord.h"
/**
 *  阅读图书模型
 */
@interface ReadBooksModel : NSObject
/** 编号 */
@property (nonatomic, copy) NSString *Id;
/** 名称 */
@property (nonatomic, copy) NSString *name;
/** 作者 */
@property (nonatomic, copy) NSString *author;
/** 最新章节 */
@property (nonatomic, copy) NSString *latestChapter;
/** 更新时间 */
@property (nonatomic, copy) NSString *updateTime;
/** 章节目录列表 */
@property (nonatomic, strong) NSArray *chapterList;
/** 阅读记录 */
@property (nonatomic, strong) ReadRecord *record;

@end
