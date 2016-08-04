//
//  ReadUtils.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/29.
//  Copyright © 2016年 泽i. All rights reserved.

#import "ReadUtils.h"
#import "PageRangeModel.h"

#import "Book.h"
#import "Chapter.h"
#import "Range.h"

@interface ReadUtils ()
/** 章节目录 */
@property (nonatomic, strong) NSMutableArray *chapters;
/** 缓存章节数量 */
@property (nonatomic, assign) NSInteger cacheNumber;
/** 是否最后一页 */
@property (nonatomic, assign) BOOL isLastPage;
/** 富文本样式 */
@property (nonatomic, strong) NSDictionary *attributes;

@end

@implementation ReadUtils

- (instancetype)init {
    if (self = [super init]) {
        _chapters = [NSMutableArray array];
    }
    return self;
}
- (void)readyRead {
    NSString *string = [NSString stringWithFormat:@"bookId = %@",self.bookId];
    NSArray *chapter = [Chapter resultWithPredicate:string sortDescriptors:@[@{@"key":@"cid",@"ascending":@(true)}] inContext:[PersistentStack stack].context];
    if (!chapter.count) {
        [self getBookChapter];
        return;
    }
    [self.chapters addObjectsFromArray:chapter];
    NSString *str = [NSString stringWithFormat:@"bookId = %@ && isLoad = 1",self.bookId];
    self.cacheNumber = [Chapter countForPredicate:str inContext:[PersistentStack stack].context];
    [self startRead];
}
#pragma mark 网络请求方法
/// 获取图书章节目录
- (void)getBookChapter {
    [HttpUtils post:BOOK_CHAPTERLIST_URL parameters:@{@"bookId":self.bookId} callBack:^(NSDictionary *data, NSError *error) {
        if (!error) {
            NSLog(@"获取章节目录完成");
            NSArray *array = [data valueForKeyPath:@"showapi_res_body.book.chapterList"];
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                Chapter *chapter = [Chapter insertNewObjectIntoContext:[PersistentStack stack].context];
                [chapter loadFromDictionary:obj];
                [self.chapters addObject:chapter];
            }];
            NSLog(@"%ld",self.chapters.count);
            NSError *error;
            if (![[PersistentStack stack].context save:&error]) {
                NSLog(@"error: %@",error.localizedDescription);
            }
            [self getChapterContent];
        }
    }];
}
- (void)startRead {
    if ([self.delegate respondsToSelector:@selector(getChapterContentFinished)]) {
        [self.delegate getChapterContentFinished];
    }
}

// 获取章节内容 默认为5章
- (void)getChapterContent {
    dispatch_group_t group = dispatch_group_create();
    for (NSInteger index = self.cacheNumber; index < self.cacheNumber + 5; index++) {
        dispatch_group_enter(group);
        Chapter *chapter = self.chapters[index];
        [HttpUtils post:BOOK_CONTENT_URL parameters:@{@"bookId":chapter.bookId,@"cid":chapter.cid} callBack:^(id data, NSError *error) {
            if (!error) {
                ChapterContent *content = [ChapterContent mj_objectWithKeyValues:data];
                content.txt = [content.txt stringByReplacingOccurrencesOfString:@"<br /><br />" withString:@"\n"];
                @synchronized (self.chapters) { // NSMutableArray 是线程不安全的，所以加个同步锁
                    [[PersistentStack stack].context performBlock:^{
                        Chapter *chapter = self.chapters[index];
                        chapter.txt = content.txt;
                        chapter.isLoad = @(true);
                        NSLog(@"%@",chapter);
                    }];
                }
                dispatch_group_leave(group);
            }
        }];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"上传完成!");
        for (NSInteger index = self.cacheNumber; index < self.cacheNumber + 5; index++) {
            Chapter *chapter = self.chapters[index];
            NSLog(@"cid = %@, txt = %@",chapter.cid,chapter.txt);
        }
        NSError *error;
        if (![[PersistentStack stack].context save:&error]) {
            NSLog(@"error: %@",error.localizedDescription);
        }
        self.cacheNumber += 5;
        [self startRead];
    });

}

- (NSString *)currentChapterName {
    return [self.chapters[self.readChapter] name];
}

- (NSAttributedString *)pagingStringForType:(ZEViewAppear)direction {
    NSString *string = [NSString stringWithFormat:@"bookId = %@ && cid = %@ && page = %ld",self.bookId,[self.chapters[self.readChapter] cid],self.readPage];
    Range *range = [Range findWithPredicate:string inContext:[PersistentStack stack].context];
    self.isLastPage = [range.isLastPage boolValue];
    NSString *text = range.txt;
    switch (direction) {
        case Before: {
            break;
        }
        case After: {
            if (!text.length) {
                text = [self calculatePagingData:[self.chapters[self.readChapter] txt] type:direction];
            }
            break;
        }
    }
    return [[NSAttributedString alloc]initWithString:text attributes:self.attributes];
}
- (NSInteger)pageForIndex:(NSInteger)index type:(ZEViewAppear)direction {
    NSInteger page = index;
    switch (direction) {
        case Before: {
            page--;
            if (page < 0) {
                self.readChapter--;
                NSString *string = [NSString stringWithFormat:@"bookId = %@ && cid = %@",[self.chapters[self.readChapter] bookId],[self.chapters[self.readChapter] cid]];
                page = [Range countForPredicate:string inContext:[PersistentStack stack].context] - 1;
            }
            break;
        }
        case After: {
            page++;
            if (self.isLastPage) {
                NSLog(@"最后一页");
                page = 0;
                self.readChapter++;
                //当下一章节为缓存的倒数第二个章节时 请求跟多章节
//                [self isRequestMoreContent];
                self.isLastPage = false;
            }
            break;
        }
    }
    NSLog(@"当前章节：%ld ====================页数: %ld ===================",self.readChapter,page);
    self.readPage = page;
    return page;
}

- (void)removeRecord {
    NSString *string = [NSString stringWithFormat:@"bookId = %@",self.bookId];
    [Book removeAllObjectWithPredicate:string inContext:[PersistentStack stack].context];
    [Range removeAllObjectWithPredicate:string inContext:[PersistentStack stack].context];
    [Chapter removeAllObjectWithPredicate:string inContext:[PersistentStack stack].context];
}

- (BOOL)isFirstPageForIndex:(NSInteger)index {
    if ((self.readChapter == 0 && index == 0) || (index == NSNotFound)) {
        return true;
    }
    return false;
}
- (BOOL)isLastPageForIndex:(NSInteger)index {
    if (self.chapters.count == self.readChapter - 1) {
//        if ([self.records[self.readChapter] count] == self.readPage - 1) {
//            return true;
//        }
    }
    return false;
}

- (NSString *)calculatePagingData:(NSString *)text type:(ZEViewAppear)direction {
    
    if (text.length == 0) {
        return @"";
    } else {
        // 计算显示区域的Size
        CGSize size = CGSizeMake(SCREEN_WIDTH-20, SCREEN_HEIGHT-50);
        // 设置初始的 截取范围
        NSRange baseRange = NSMakeRange(0, 0);
        if (self.readPage) {
            NSString *string = [NSString stringWithFormat:@"cid = %@ && page = %ld",[self.chapters[self.readChapter] cid],self.readPage-1];
            NSLog(@"查询条件 = %@",string);
            Range *range = [Range findWithPredicate:string inContext:[PersistentStack stack].context];
            if (range) {
                baseRange = [text rangeOfString:range.txt];
            }
        }
        NSLog(@"location = %ld , length = %ld",baseRange.location,baseRange.length);
        NSLog(@"下一页");
        // 要显示的是下一页内容
        // 设置 初始 location 为 上一次计算的 location + length
        NSInteger location = baseRange.location + baseRange.length;
        // 设置 初始 length
        // 如果 初始location + 250 大于 text.length 说明 将要显示章节的最后一页
        NSInteger length = location + 250 < text.length ? 250 : text.length - location;
        // 设置初始 范围
        baseRange.location = location;
        baseRange.length = length;
        // 计算 截取的字符串初始Size
        CGSize textSize = [[text substringWithRange:baseRange] boundingRectWithSize:size
                                                                        options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading
                                                                     attributes:self.attributes
                                                                        context:nil].size;
        NSLog(@"初始 textHeight = %f",textSize.height);
        // 判断初始Size.height 是否大于 显示区域的height
        if (textSize.height > size.height) {
            // 循环减少初始 length 的数值  直到初始 Size.height 小于显示区域的 height
            while (textSize.height > size.height) {
                baseRange.length -= 1;
                textSize = [[text substringWithRange:baseRange] boundingRectWithSize:size
                                                                         options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading
                                                                      attributes:self.attributes
                                                                         context:nil].size;
            }
            // 判断是否为最后一页
        } else if (baseRange.location + baseRange.length != text.length) {
            // 循环增加初始 length 的数值 直到初始Size.height 大于显示区域的 height
            while (textSize.height < size.height) {
                baseRange.length += 1;
                textSize = [[text substringWithRange:baseRange] boundingRectWithSize:size
                                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                      attributes:self.attributes
                                                                         context:nil].size;
            }
            // 计算完成后 length 会多一个数 将多的减掉
            baseRange.length -= 1;
        }
        // 当前为最后一页时
        if (baseRange.location + baseRange.length == text.length) {
            self.isLastPage = true;
            NSLog(@"最后一页");
        }
        NSString *txt = [text substringWithRange:baseRange];
        NSDictionary *dict = @{@"page":@(self.readPage),
                               @"txt":txt,
                               @"bookId":[self.chapters[self.readChapter] bookId],
                               @"cid":[self.chapters[self.readChapter] cid],
                               @"isLastPage":@(self.isLastPage)};
        Range *pageRange = [Range insertNewObjectIntoContext:[PersistentStack stack].context];
        [pageRange loadFromDictionary:dict];
        NSError *error;
        if (![[PersistentStack stack].context save:&error]) {
            NSLog(@"error: %@",error.localizedDescription);
        }
        return txt;
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
    NSLog(@"%@ 工具被销毁",[[self class] description]);
}
@end
