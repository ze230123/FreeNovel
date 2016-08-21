//
//  ReadDataSource.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/8.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReadDataSourceDelegate <NSObject>

- (void)dataSourceDidFinish;

@end

/**
 *  书籍内容来源
 */
@interface ReadDataSource : NSObject
/** 当前书籍的编号 */
@property (nonatomic, copy) NSString *bookId;
@property (nonatomic, strong, readonly) NSArray *chapters;
/** 当前章节数 */
@property (nonatomic, assign) NSInteger currentChapterIndex;
@property (nonatomic, assign, readonly) NSInteger lastPage;
@property (nonatomic, assign) NSInteger textFont;

@property (nonatomic, weak) id<ReadDataSourceDelegate>delegate;

- (instancetype)initWithBookId:(NSString *)bookId;
- (void)chaptersWithBookId;
- (void)openChapter;
- (void)preChapter;
- (void)nextChapter;

- (void)cacheContentTextWithNumbers:(NSInteger)number;
/** 根据当前页数计算并返回改变字号后的页数 */
- (NSInteger)fontChangedPageWithCurrentPage:(NSInteger)page;

- (NSString*)stringWithPage:(NSInteger)page;

- (NSString*)name;
@end
