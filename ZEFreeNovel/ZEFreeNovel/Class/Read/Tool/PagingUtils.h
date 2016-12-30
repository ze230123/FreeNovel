//
//  PagingUtils.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/8.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PagingUtils : NSObject

@property (nonatomic, copy  ) NSString   *contentText;
@property (nonatomic, assign) NSUInteger contentFont;
@property (nonatomic, assign) CGSize     textRenderSize;

- (void)paging;
/**
 *  一共分了多少页
 *
 *  @return 一章所分的页数
 */
- (NSUInteger)pageCount;
/**
 *  获得page页的文字内容
 *
 *  @param page 页
 *
 *  @return 内容
 */
- (NSString *)stringOfPage:(NSUInteger)page;

- (NSInteger)locationWithPage:(NSInteger)page;

- (NSInteger)pageWithTextOffSet:(NSInteger)OffSet;

@end
