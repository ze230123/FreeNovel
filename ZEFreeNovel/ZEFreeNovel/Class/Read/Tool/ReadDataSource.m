//
//  ReadDataSource.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/8.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "ReadDataSource.h"
#import "Chapter.h"
#import "PersistentStack.h"

#import "ChapterContent.h"

#import "PagingUtils.h"

@interface ReadDataSource ()
@property (nonatomic, assign, readonly) NSInteger totalChapter;
@property (nonatomic, assign) BOOL isReloadUI;

@end

@implementation ReadDataSource {
    NSMutableArray *_chapters;
    PagingUtils *paging;
}

- (instancetype)initWithBookId:(NSString *)bookId {
    if (self = [super init]) {
//        [self _chaptersWithBookId:bookId];
    }
    return self;
}
- (instancetype)init {
    if (self = [super init]) {
        _chapters = [NSMutableArray array];
    }
    return self;
}
#pragma mark 分页
- (void)configPaging {
    paging = [[PagingUtils alloc]init];
    paging.contentFont = self.textFont;
    paging.contentText = [_chapters[self.currentChapterIndex] txt];
    paging.textRenderSize = CGSizeMake(SCREEN_WIDTH-20, SCREEN_HEIGHT-50);
    [paging paging];
}
#pragma mark 公共方法
- (void)preChapter {
    if (self.currentChapterIndex <= 0) {
        NSLog(@"已经是第一章了！！！！");
        return;
    } else {
        self.currentChapterIndex--;
        [self loadFinishWithIndex:self.currentChapterIndex-1 group:nil];
        [self configPaging];
    }
}
- (void)nextChapter {
    if (self.currentChapterIndex >= self.totalChapter) {
        NSLog(@"已经是最后一章了!!!!!");
        return;
    } else {
        self.currentChapterIndex++;
        [self needCache];
        [self configPaging];
    }
}
- (void)openChapter {
    [self configPaging];
}

- (NSString*)name {
    return [_chapters[self.currentChapterIndex] name];
}
- (NSInteger)fontChangedPageWithCurrentPage:(NSInteger)page {
    NSInteger location = [paging locationWithPage:page];
    [self configPaging];
    return [paging pageWithTextOffSet:location];
}
- (NSString *)stringWithPage:(NSInteger)page {
    return [paging stringOfPage:page];
}
- (NSInteger)lastPage {
    return [paging pageCount];
}

#pragma mark 数据请求方法
// 获取章节目录
- (void)chaptersWithBookId {
    [_chapters addObjectsFromArray:[Chapter resultWithPredicate:[NSString stringWithFormat:@"bookId == %@",self.bookId]
                                               sortDescriptors:@[@{@"key":@"cid",@"ascending":@(true)}]
                                                     inContext:[PersistentStack stack].backgroundContext]];
    self.isReloadUI = YES;
    if (!_chapters.count) {
        [HttpUtils post:BOOK_CHAPTERLIST_URL parameters:@{@"bookId":self.bookId} callBack:^(NSDictionary *data, NSError *error) {
            NSArray *array = [data valueForKeyPath:@"showapi_res_body.book.chapterList"];
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                Chapter *chapter = [Chapter insertNewObjectIntoContext:[PersistentStack stack].backgroundContext];
                [chapter loadFromDictionary:obj];
                [_chapters addObject:chapter];
            }];
            [[PersistentStack stack] save];
            [self cacheContentTextWithNumbers:10];
        }];
    } else {
        [self callFinish];
    }
}
// 获取章节内容
- (void)contentTextWith:(Chapter *)chapter group:(dispatch_group_t)group{
    if ([chapter.isLoad boolValue]) {
        return;
    }
    if (group) {
        dispatch_group_enter(group);
    }
    [HttpUtils post:BOOK_CONTENT_URL parameters:@{@"bookId":chapter.bookId,@"cid":chapter.cid} callBack:^(NSDictionary *data, NSError *error) {
        if (!error) {
            ChapterContent *content = [ChapterContent mj_objectWithKeyValues:data];
            content.txt = [content.txt deleteRedundantHTMLTags];
            Chapter *chapter = [Chapter findWithPredicate:[NSString stringWithFormat:@"bookId == %@ && cid == %@",content.bookId,content.cid]
                                                inContext:[PersistentStack stack].backgroundContext];
            NSMutableAttributedString *attStr = [content.txt attributedString];
            [attStr addAttributes:[self attributesWithFont:self.textFont] range:NSMakeRange(0, attStr.length)];
            chapter.txt = [attStr.string FirstLineAddSpaces];
            chapter.isLoad = @(YES);
            NSLog(@"cid = %@",chapter.cid);
            [[PersistentStack stack] save];
            if (group) {
                dispatch_group_leave(group);
            }
        }
    }];
}
/** 缓存number个章节的内容 */
- (void)cacheContentTextWithNumbers:(NSInteger)number {
    NSLog(@"缓存%ld章内容",number);
    dispatch_group_t group = dispatch_group_create();
    for (NSInteger idx = self.currentChapterIndex; idx <= self.currentChapterIndex+number; idx++) {
        if (idx > self.totalChapter) {
            break;
        }
        
        Chapter *chapter = _chapters[idx];
        if (!chapter.txt.length) {
            [self contentTextWith:chapter group:group];
        }
    }
    [self loadFinishWithIndex:self.currentChapterIndex-1 group:group];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//        if (self.isReloadUI) {
            [self callFinish];
//            self.isReloadUI = NO;
//        }
    });
}
/** 通知UI更新界面 */
- (void)callFinish {
    if ([self.delegate respondsToSelector:@selector(dataSourceDidFinish)]) {
        [self.delegate dataSourceDidFinish];
    }
}
/** 缓存index章节的内容 */
- (void)loadFinishWithIndex:(NSInteger)index group:(dispatch_group_t)group{
    if (index < 0) {
        return;
    }
    Chapter *chapter = _chapters[index];
    if (![chapter.isLoad boolValue]) {
        [self contentTextWith:chapter group:group];
    }
}
/** 判断是否需要缓存章节内容 */
- (void)needCache {
    if (self.currentChapterIndex + 5 > self.totalChapter) {
        return;
    }
    if (![[_chapters[self.currentChapterIndex + 5] isLoad] boolValue]) {
        [self cacheContentTextWithNumbers:10];
        NSLog(@"需要缓存章节内容");
    }
}
#pragma mark 富文本格式字典
- (NSDictionary *)attributesWithFont:(NSInteger)fontsize {
    UIFont *font = [UIFont systemFontOfSize:fontsize];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = font.pointSize / 2;
    paragraphStyle.alignment = NSTextAlignmentJustified;
//    paragraphStyle.firstLineHeadIndent = fontsize*2;
    return @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName:font};
}
- (NSInteger)totalChapter {
    return _chapters.count - 1;
}
@end
