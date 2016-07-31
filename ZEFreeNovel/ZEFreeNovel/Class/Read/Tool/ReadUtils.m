//
//  ReadUtils.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/29.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "ReadUtils.h"
#import "PageRangeModel.h"

@interface ReadUtils ()

/** 缓存章节数量 */
@property (nonatomic, assign) NSInteger cacheNumber;

/** 富文本样式 */
@property (nonatomic, strong) NSDictionary *attributes;

@end

@implementation ReadUtils

- (instancetype)initWithBookId:(NSString *)BookId delegate:(id)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        [self getBookChapterForBookid:BookId];
    }
    return self;
}
#pragma mark 网络请求方法
/// 获取图书章节目录
- (void)getBookChapterForBookid:(NSString*)bookId {
    [HttpUtils post:BOOK_CHAPTERLIST_URL parameters:@{@"bookId":bookId} callBack:^(id data, NSError *error) {
        if (!error) {
            NSLog(@"获取章节目录完成");
            self.bookModel = [ReadBooksModel mj_objectWithKeyValues:data];
            [self getChapterContent];
        }
    }];
}
// 获取章节内容 默认为5章
- (void)getChapterContent {
    NSMutableArray *cacheList = [NSMutableArray array];
    for (NSInteger index = self.cacheNumber; index < self.cacheNumber + 5; index++) {
        @autoreleasepool {
            BookChapter *chapter = self.bookModel.chapterList[index];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [HttpUtils post:BOOK_CONTENT_URL parameters:@{@"bookId":chapter.bookId,@"cid":chapter.cid} callBack:^(id data, NSError *error) {
                    if (!error) {
                        ChapterContent *content = [ChapterContent mj_objectWithKeyValues:data];
                        content.txt = [content.txt stringByReplacingOccurrencesOfString:@"<br /><br />" withString:@"\n"];
                        [cacheList addObject:content];
                        // 如果数组里的模型数量为 5 对数组里的章节内容按升序排序
                        if (cacheList.count == 5) {
                            [self sortForcacheChapers:cacheList];
                            if ([self.delegate respondsToSelector:@selector(getChapterContentFinished)]) {
                                [self.delegate getChapterContentFinished];
                            }
                        }
                    }
                }];
            });
        }
    }
}

/**
 *  对数组排序
 *
 *  @param chapers 内容缓存数组
 */

- (void)sortForcacheChapers:(NSMutableArray *)chapers {
    [chapers sortUsingComparator:^NSComparisonResult(ChapterContent *obj1, ChapterContent *obj2) {
        return [obj1.cid compare:obj2.cid];
    }];
    [self.bookModel.record.cacheChapters addObjectsFromArray:chapers];
    self.cacheNumber = self.bookModel.record.cacheChapters.count;
}

- (NSString *)currentChapterName {
    return [self.bookModel.record.cacheChapters[self.bookModel.record.currentChapter] name];
}

- (NSAttributedString *)pagingStringForType:(ZEViewAppear)direction {
//    NSLog(@"当前章节CID &&&&&&&&&&&&&&&&&  %ld  #################### %@ ==================",self.currentChapter,[self.cacheChapters[self.currentChapter] cid]);
    NSString *text = [self calculatePagingData:[self.bookModel.record.cacheChapters[self.bookModel.record.currentChapter] txt] type:direction];
    return [[NSAttributedString alloc]initWithString:text attributes:self.attributes];
}

- (NSInteger)pageForIndex:(NSInteger)index type:(ZEViewAppear)direction {
    NSInteger page = index;
    switch (direction) {
        case Before: {
            page--;
            if (self.bookModel.record.isLastPage) {
                self.bookModel.record.isLastPage = false;
            }
            if (page < 0) {
//                NSLog(@"******************* 上 *** 一 *** 章 **********************");
                self.bookModel.record.currentChapter--;
                self.bookModel.record.lastRange = NSMakeRange(0, 0);
                page = [self.bookModel.record.PageRange[self.bookModel.record.currentChapter] rangeList].count - 1;
            }
            // 存储当前的页数
            break;
        }
        case After: {
            page++;
            if (self.bookModel.record.isLastPage) {
                page = 0;
                self.bookModel.record.currentChapter++;
                //当下一章节为缓存的倒数第二个章节时 请求跟多章节
                [self isRequestMoreContent];
                self.bookModel.record.lastRange = NSMakeRange(0, 0);
                self.bookModel.record.isLastPage = false;
//                NSLog(@"******************* 下 *** 一 *** 章 **********************");
            }
            break;
        }
    }
    NSLog(@"当前页数 ==================== %ld ===================",page);
    self.bookModel.record.currentPage = page;
    return page;
}

- (void)isRequestMoreContent {
    if ((self.bookModel.record.currentChapter == self.bookModel.record.cacheChapters.count - 2)) {
        [self getChapterContent];
    }
}
- (BOOL)isFirstPageForIndex:(NSInteger)index {
    if ((self.bookModel.record.currentChapter == 0 && index == 0) || (index == NSNotFound)) {
        return true;
    }
    return false;
}
- (BOOL)isLastPageForIndex:(NSInteger)index {
    if ([[self.bookModel.record.cacheChapters[self.bookModel.record.currentChapter] name] isEqualToString:self.bookModel.latestChapter]) {
        NSDictionary *range = [self.bookModel.record.PageRange.lastObject rangeList].lastObject;
        NSInteger location = [range[@"location"] integerValue];
        NSInteger length = [range[@"length"] integerValue];
        if (location + length == [self.bookModel.record.cacheChapters[self.bookModel.record.currentChapter] txt].length) {
            return true;
        }
    }
    return false;
}

- (NSString *)calculatePagingData:(NSString *)text type:(ZEViewAppear)direction {
    
    if (text.length == 0) {
        return nil;
    } else {
        // 计算显示区域的Size
        CGSize size = CGSizeMake(SCREEN_WIDTH-20, SCREEN_HEIGHT-50);
        // 设置初始的 截取范围
        NSRange range = NSMakeRange(0, 0);
        // 判断将要出现的位置
        switch (direction) {
            case Before: {
                NSLog(@"上一页");
                // 要显示的是上一页内容 直接在 lastPageRange 数组里 取得上一页的截取范围
                PageRangeModel *pageRang = self.bookModel.record.PageRange[self.bookModel.record.currentChapter];
                NSInteger location = [pageRang.rangeList[self.bookModel.record.currentPage][@"location"] integerValue];
                NSInteger length = [pageRang.rangeList[self.bookModel.record.currentPage][@"length"] integerValue];
                // 设置正确的截取范围
                range = NSMakeRange(location, length);
                break;
            }
            case After: {
                NSLog(@"下一页");
                // 要显示的是下一页内容
                // 设置 初始 location 为 上一次计算的 location + length
                NSInteger location = self.bookModel.record.lastRange.location + self.bookModel.record.lastRange.length;
                // 设置 初始 length
                // 如果 初始location + 250 大于 text.length 说明 将要显示章节的最后一页
                NSInteger length = location + 250 < text.length ? 250 : text.length - location;
                if (self.bookModel.record.PageRange.count > self.bookModel.record.currentChapter) {
                    if ([self.bookModel.record.PageRange[self.bookModel.record.currentChapter] chapterNumber] == self.bookModel.record.currentChapter) {
                        if ([self.bookModel.record.PageRange[self.bookModel.record.currentChapter] rangeList].count > self.bookModel.record.currentPage) {
                            PageRangeModel *pageRang = self.bookModel.record.PageRange[self.bookModel.record.currentChapter];
                            location = [pageRang.rangeList[self.bookModel.record.currentPage][@"location"] integerValue];
                            length = [pageRang.rangeList[self.bookModel.record.currentPage][@"length"] integerValue];
                        }
                    }
                }

                // 设置初始 范围
                range = NSMakeRange(location, length);
                NSLog(@"初始   location = %ld , length = %ld textLength = %ld",range.location,range.length,text.length);
                // 计算 截取的字符串初始Size
                CGSize textSize = [[text substringWithRange:range] boundingRectWithSize:size
                                                                                options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading
                                                                             attributes:self.attributes
                                                                                context:nil].size;
                NSLog(@"初始 textHeight = %f",textSize.height);
                // 判断初始Size.height 是否大于 显示区域的height
                if (textSize.height > size.height) {
                    // 循环减少初始 length 的数值  直到初始 Size.height 小于显示区域的 height
                    while (textSize.height > size.height) {
                        range.length -= 1;
//                        NSLog(@"计算后   location = %ld , length = %ld %%%%%%%%%%%%%%%%%%",range.location,range.length);
                        textSize = [[text substringWithRange:range] boundingRectWithSize:size
                                                                                 options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading
                                                                              attributes:self.attributes
                                                                                 context:nil].size;
//                        NSLog(@"计算后  textHeight ===== %f  ,,,,   显示区域  height ====== %f",textSize.height,size.height);
                    }
//                    NSLog(@"^^^^^^^^^^^^^^   计算高度  大于  初始高度  ^^^^^^^^^^^^^^^^^^ ");
                    // 判断是否为最后一页
                } else if (range.location + range.length != text.length) {
                    // 循环增加初始 length 的数值 直到初始Size.height 大于显示区域的 height
                    while (textSize.height < size.height) {
                        range.length += 1;
                        textSize = [[text substringWithRange:range] boundingRectWithSize:size
                                                                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                              attributes:self.attributes
                                                                                 context:nil].size;
                    }
                    // 计算完成后 length 会多一个数 将多的减掉
                    range.length -= 1;
//                    NSLog(@"……………………………………………  计算高度  小于  初始高度  ……………………………………………");
                }
                // 设置存储每页截取范围的字典
                NSDictionary *dict = @{@"location":@(range.location),@"length":@(range.length),@"page":@(self.bookModel.record.currentPage)};
                // 创建范围模型
                PageRangeModel *rangeModel = [[PageRangeModel alloc]initWithNumber:self.bookModel.record.currentChapter];
                // 当 缓存每页范围的数组为空时 或者 数组元素个数 等于当前章节时 将字典添加到范围模型  将范围模型添加到缓存数组中
                // 当 缓存数组个数大于当前章节 且 缓存数组中当前章节的范围模型 不包含 相同的字典是 将字典添加到 当前章节的范围模型中
                if (!self.bookModel.record.PageRange.count || self.bookModel.record.PageRange.count == self.bookModel.record.currentChapter ) {
                    
                    [rangeModel.rangeList addObject:dict];
                    [self.bookModel.record.PageRange addObject:rangeModel];
                    NSLog(@"数组添加模型");
                } else if (self.bookModel.record.PageRange.count > self.bookModel.record.currentChapter && !([[self.bookModel.record.PageRange[self.bookModel.record.currentChapter] rangeList] containsObject:dict])) {
                    
                    [[self.bookModel.record.PageRange[self.bookModel.record.currentChapter] rangeList] addObject:dict];
                    NSLog(@"数组里模型添加字典");
                }
                NSLog(@"%@",self.bookModel.record.PageRange);
//                NSLog(@"***************************************************************************************");
                // 当前为最后一页时
                if (range.location + range.length == text.length) {
                    
                    self.bookModel.record.isLastPage = true;
                    NSLog(@"最后一页");
                }
                
                break;
            }
        }
        // 存储刚计算好的截取范围
        self.bookModel.record.lastRange = range;
        return [text substringWithRange:range];
    }
}

#pragma mark - 懒加载
- (NSDictionary *)attributes {
    if (_attributes == nil) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 10;    //行间距
        paragraphStyle.maximumLineHeight = 60;   /**最大行高*/
        paragraphStyle.firstLineHeadIndent = 20.f;    /**首行缩进宽度*/
        paragraphStyle.alignment = NSTextAlignmentJustified;
        
        _attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:25], NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:[UIColor colorWithRed:76./255. green:75./255. blue:71./255. alpha:1]};
    }
    return _attributes;
}


- (void)dealloc {
    self.bookModel = nil;
    NSLog(@"%@ 工具被销毁",[[self class] description]);
}
@end
