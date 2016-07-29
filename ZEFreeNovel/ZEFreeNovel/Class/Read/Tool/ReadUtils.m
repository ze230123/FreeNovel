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

/** 当前显示的页面编号 */
@property (nonatomic, assign) NSInteger currentPage;
/** 当前章节 */
@property (nonatomic, assign) NSInteger currentChapter;
/** 最后一次计算的Range */
@property (nonatomic, assign) NSRange lastRange;
/** 富文本样式 */
@property (nonatomic, strong) NSDictionary *attributes;
/** 缓存的章节内容 */
@property (nonatomic, strong) NSMutableArray *cacheChapters;
/** 章节每页Range数组 */
@property (nonatomic, strong) NSMutableArray *PageRange;
/** 是否当前章节最后一页 */
@property (nonatomic, assign) BOOL isLastPage;

@end

@implementation ReadUtils

- (instancetype)init {
    if (self = [super init]) {
        _cacheNumber = 0;
        _currentChapter = 0;
        _currentPage = 0;
        _lastRange = NSMakeRange(0, 0);
    }
    return self;
}

- (void)sortForcacheChapers:(NSMutableArray *)chapers {
    [chapers sortUsingComparator:^NSComparisonResult(ChapterContent *obj1, ChapterContent *obj2) {
        return [obj1.cid compare:obj2.cid];
    }];
    [self.cacheChapters addObjectsFromArray:chapers];
    _cacheNumber = self.cacheChapters.count;
    NSLog(@"获取章节内容完成");
}

- (NSString *)currentChapterName {
    return [self.cacheChapters[self.currentChapter] name];
}

- (NSAttributedString *)pagingStringForType:(ZEViewAppear)direction {
    NSLog(@"当前章节CID &&&&&&&&&&&&&&&&&  %ld  #################### %@ ==================",self.currentChapter,[self.cacheChapters[self.currentChapter] cid]);
    NSString *text = [self calculatePagingData:[self.cacheChapters[self.currentChapter] txt] type:direction];
    return [[NSAttributedString alloc]initWithString:text attributes:self.attributes];
}

- (NSInteger)pageForIndex:(NSInteger)index type:(ZEViewAppear)direction {
    NSInteger page = index;
    switch (direction) {
        case Before: {
            page--;
            if (self.isLastPage) {
                self.isLastPage = false;
            }
            if (page < 0) {
                NSLog(@"******************* 上 *** 一 *** 章 **********************");
                self.currentChapter--;
                self.lastRange = NSMakeRange(0, 0);
                page = [self.PageRange[self.currentChapter] rangeList].count - 1;
            }
            // 存储当前的页数
            break;
        }
        case After: {
            page++;
            if (self.isLastPage) {
                page = 0;
                self.currentChapter++;
                //当下一章节为缓存的倒数第二个章节时 请求跟多章节
                self.lastRange = NSMakeRange(0, 0);
                NSLog(@"******************* 下 *** 一 *** 章 **********************");
            }
            break;
        }
    }
    NSLog(@"当前页数 ==================== %ld ===================",page);
    self.currentPage = page;
    return page;
}

- (BOOL)isRequestMoreContent {
    if ((self.currentChapter == self.cacheChapters.count - 1) && self.isLastPage) {
        return YES;
    }
    self.isLastPage = false;
    return false;
}
- (BOOL)isReturnNilForIndex:(NSInteger)index {
    if ((self.currentChapter == 0 && index == 0) || (index == NSNotFound)) {
        return true;
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
                PageRangeModel *pageRang = self.PageRange[self.currentChapter];
                NSInteger location = [pageRang.rangeList[self.currentPage][@"location"] integerValue];
                NSInteger length = [pageRang.rangeList[self.currentPage][@"length"] integerValue];
                // 设置正确的截取范围
                range = NSMakeRange(location, length);
                break;
            }
            case After: {
                NSLog(@"下一页");
                // 要显示的是下一页内容
                // 设置 初始 location 为 上一次计算的 location + length
                NSInteger location = self.lastRange.location + self.lastRange.length;
                // 设置 初始 length
                // 如果 初始location + 250 大于 text.length 说明 将要显示章节的最后一页
                NSInteger length = location + 250 < text.length ? 250 : text.length - location;
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
                        NSLog(@"计算后   location = %ld , length = %ld %%%%%%%%%%%%%%%%%%",range.location,range.length);
                        textSize = [[text substringWithRange:range] boundingRectWithSize:size
                                                                                 options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading
                                                                              attributes:self.attributes
                                                                                 context:nil].size;
                        NSLog(@"计算后  textHeight ===== %f  ,,,,   显示区域  height ====== %f",textSize.height,size.height);
                    }
                    NSLog(@"^^^^^^^^^^^^^^   计算高度  大于  初始高度  ^^^^^^^^^^^^^^^^^^ ");
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
                    NSLog(@"……………………………………………  计算高度  小于  初始高度  ……………………………………………");
                }
                // 设置存储每页截取范围的字典
                NSDictionary *dict = @{@"location":@(range.location),@"length":@(range.length),@"page":@(self.currentPage)};
                // 创建范围模型
                PageRangeModel *rangeModel = [[PageRangeModel alloc]initWithNumber:self.currentChapter];
                // 当 缓存每页范围的数组为空时 或者 数组元素个数 等于当前章节时 将字典添加到范围模型  将范围模型添加到缓存数组中
                // 当 缓存数组个数大于当前章节 且 缓存数组中当前章节的范围模型 不包含 相同的字典是 将字典添加到 当前章节的范围模型中
                if (!self.PageRange.count || self.PageRange.count == self.currentChapter ) {
                    
                    [rangeModel.rangeList addObject:dict];
                    [self.PageRange addObject:rangeModel];
                    NSLog(@"数组添加模型");
                } else if (self.PageRange.count > self.currentChapter && !([[self.PageRange[self.currentChapter] rangeList] containsObject:dict])) {
                    
                    [[self.PageRange[self.currentChapter] rangeList] addObject:dict];
                    NSLog(@"数组里模型添加字典");
                }
                NSLog(@"***************************************************************************************");
                // 当前为最后一页时
                if (range.location + range.length == text.length) {
                    
                    self.isLastPage = true;
                    NSLog(@"最后一页");
                }
                
                break;
            }
        }
        // 存储刚计算好的截取范围
        self.lastRange = range;
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

- (NSMutableArray *)cacheChapters {
    if (_cacheChapters == nil) {
        _cacheChapters = [NSMutableArray array];
    }
    return _cacheChapters;
}

- (NSMutableArray *)PageRange {
    if (_PageRange == nil) {
        _PageRange = [NSMutableArray array];
    }
    return _PageRange;
}


@end
