//
//  ReadRecord.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/31.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReadRecord : NSObject

/** 当前显示的页面编号 */
@property (nonatomic, assign) NSInteger currentPage;
/** 当前章节 */
@property (nonatomic, assign) NSInteger currentChapter;
/** 最后一次计算的Range */
@property (nonatomic, assign) NSRange lastRange;
/** 缓存的章节内容 */
@property (nonatomic, strong) NSMutableArray *cacheChapters;
/** 章节每页Range数组 */
@property (nonatomic, strong) NSMutableArray *PageRange;
/** 是否当前章节最后一页 */
@property (nonatomic, assign) BOOL isLastPage;


@end
