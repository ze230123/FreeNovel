//
//  ReadUtils.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/29.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookChapter.h"
#import "ChapterContent.h"
#import "ReadBooksModel.h"
#import "Book.h"
#import "PersistentStack.h"


@protocol ReadUtilsDelegate <NSObject>

- (void)getChapterContentFinished; // 章节内容加载完成

@end

/** 视图将要出现的位置 */
typedef NS_ENUM(NSUInteger, ZEViewAppear) {
    /** 前 */
    Before,
    /** 后 */
    After,
};
/**
 *  阅读工具
 */
@interface ReadUtils : NSObject
/** 书的ID */
@property (nonatomic, copy) NSString *bookId;
/** 阅读章节 */
@property (nonatomic, assign) NSInteger readChapter;
/** 阅读页数 */
@property (nonatomic, assign) NSInteger readPage;

@property (nonatomic, weak) id <ReadUtilsDelegate>delegate;
/**
 *  准备阅读
 *  做一些阅读前的准备工作、比如请求数据查找数据
 */
- (void)readyRead;

/**
 *  获取当前章节名
 *
 *  @return 章节名
 */
- (NSString *)currentChapterName;

/**
 *  计算将要显示的页数
 *
 *  @param index     当前页数
 *  @param direction 显示位置
 *
 *  @return 将要显示的页数
 */
- (NSInteger)pageForIndex:(NSInteger)index type:(ZEViewAppear)direction;
/**
 *  获取分页的内容
 *
 *  @param type 位置类型
 *
 *  @return 分页内容的富文本
 */
- (NSAttributedString *)pagingStringForType:(ZEViewAppear)direction;

/**
 *  是否需要获取更多章节内容
 */
- (void)isRequestMoreContent;
/**
 *  判断是否返回空
 *
 *  @param index 页数
 *
 *  @return true Of false
 */
- (BOOL)isFirstPageForIndex:(NSInteger)index;
- (BOOL)isLastPageForIndex:(NSInteger)index;
/**
 *  删除本地的阅读记录
 */
- (void)removeRecord;

@end
