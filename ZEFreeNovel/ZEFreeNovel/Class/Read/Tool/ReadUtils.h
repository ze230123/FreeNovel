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
@interface ReadUtils : NSObject {
    NSInteger _cacheNumber;
}
/** 缓存章节数量 */
@property (nonatomic, assign, readonly) NSInteger cacheNumber;
/**
 *  对数组排序
 *
 *  @param chapers 内容缓存数组
 */
- (void)sortForcacheChapers:(NSMutableArray *)chapers;
//- (void)getChapterContent;
/**
 *  获取当前章节名
 *
 *  @return 章节名
 */
- (NSString *)currentChapterName;

/**
 *  计算每页的字数并返回截取后的字符串
 *
 *  @param text      要截取的字符串
 *  @param direction 截取的字符串要显示的位置
 *
 *  @return 截取好的字符串
 */

- (NSString *)calculatePagingData:(NSString *)text type:(ZEViewAppear)direction;
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
 *
 *  @return true Of false
 */
- (BOOL)isRequestMoreContent;
/**
 *  判断是否返回空
 *
 *  @param index 页数
 *
 *  @return true Of false
 */
- (BOOL)isReturnNilForIndex:(NSInteger)index;

@end
