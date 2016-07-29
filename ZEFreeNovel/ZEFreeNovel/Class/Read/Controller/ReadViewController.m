//
//  ReadViewController.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//
#import "PCH.pch"
#import "ReadViewController.h"
#import "ContentViewController.h"

#import "ReadBooksModel.h"
#import "BookChapter.h"
#import "ChapterContent.h"
#import "PageRangeModel.h"

#import "NSString+Extension.h"
/**
 *  视图将要出现的位置
 */
typedef NS_ENUM(NSUInteger, ZEViewAppear) {
    /**
     *  前
     */
    Before,
    /**
     *  后
     */
    After,
};


@interface ReadViewController () <UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController *pageViewController;
/// 图书的ID
@property (nonatomic, copy) NSString *bookId;
/** 图书模型 */
@property (nonatomic, strong) ReadBooksModel *bookModel;
/** 当前显示的页面编号 */
@property (nonatomic, assign) NSInteger currentPage;
/** 缓存章节数量 */
@property (nonatomic, assign) NSInteger cacheNumber;
/** 当前章节 */
@property (nonatomic, assign) NSInteger currentChapter;
/** 最后一次计算的Range */
@property (nonatomic, assign) NSRange lastRange;
/** 富文本样式 */
@property (nonatomic, strong) NSDictionary *attributes;
/** 缓存的章节内容 */
@property (nonatomic, strong) NSMutableArray *cacheChapter;
/** 章节每页Range数组 */
@property (nonatomic, strong) NSMutableArray *PageRange;
/** 是否当前章节最后一页 */
@property (nonatomic, assign) BOOL isLastPage;

@end

@implementation ReadViewController
- (instancetype)initWithBooksInfo:(NSString *)bookID {
    if (self = [super init]) {
        _bookId = bookID;
        _cacheNumber = 0;
        _currentChapter = 0;
        _currentPage = 0;
        _lastRange = NSMakeRange(0, 0);
        [self getBookChapter];
    }
    return self;
}

/// 获取图书章节目录
- (void)getBookChapter {
    [HttpUtils post:@"https://route.showapi.com/211-1" parameters:@{@"bookId":self.bookId} callBack:^(id data) {
        NSLog(@"获取章节目录完成");
        self.bookModel = [ReadBooksModel mj_objectWithKeyValues:data];
        [self getChapterContent];
    }];
}
/// 获取章节内容 默认为5章
- (void)getChapterContent {
    
    NSMutableArray *cacheList = [NSMutableArray array];
    for (NSInteger index = self.cacheNumber; index < self.cacheNumber + 5; index++) {
        BookChapter *chapter = self.bookModel.chapterList[index];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [HttpUtils post:@"https://route.showapi.com/211-4" parameters:@{@"bookId":chapter.bookId,@"cid":chapter.cid} callBack:^(id data) {
                
                ChapterContent *content = [ChapterContent mj_objectWithKeyValues:data];
                content.txt = [content.txt stringByReplacingOccurrencesOfString:@"<br /><br />" withString:@"\n"];
                [cacheList addObject:content];
                // 如果数组里的模型数量为 5 对数组里的章节内容按升序排序
                if (cacheList.count == 5) {
                    
                    [cacheList sortUsingComparator:^NSComparisonResult(ChapterContent *obj1, ChapterContent *obj2) {
                        return [obj1.cid compare:obj2.cid];
                    }];
                    [self.cacheChapter addObjectsFromArray:cacheList];
                    NSLog(@"获取章节内容完成");
                    // pageViewController 的 viewControllers.count 为0
                    if (self.pageViewController.viewControllers.count == 0) {
                        NSLog(@"pageviewcontroller 设置数据");
                        //设置UIPageViewController初始化数据, 将数据放在NSArray里面
                        //如果 options 设置了 UIPageViewControllerSpineLocationMid,注意viewControllers至少包含两个数据,且 doubleSided = YES
                        ContentViewController *initialViewController = [self viewControllerAtIndex:0 type:After];// 得到第一页
                        NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
                        
                        [_pageViewController setViewControllers:viewControllers
                                                      direction:UIPageViewControllerNavigationDirectionReverse
                                                       animated:NO
                                                     completion:nil];
                    }
                }
            }];
        });
    }
    self.cacheNumber += 5;
}

#pragma mark 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 关闭pop 返回手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    // 隐藏 navigationBar
    self.navigationController.navigationBar.hidden = true;
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"视图加载了");
    
    NSDictionary *options = @{UIPageViewControllerOptionSpineLocationKey : @(UIPageViewControllerSpineLocationMin)};
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:options];
    // 设置UIPageViewController代理和数据源
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    
    // 设置UIPageViewController 尺寸
    _pageViewController.view.frame = self.view.bounds;
    
    // 在页面上，显示UIPageViewController对象的View
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    
}

// 隐藏状态栏
- (BOOL)prefersStatusBarHidden { //设置隐藏显示
    
    return true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPageViewControllerDataSource And UIPageViewControllerDelegate
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = ((ContentViewController *)viewController).index;
    // 当前章节和当前页数都为0 代表当前为图书第一张的第一页
    if ((self.currentChapter == 0 && index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    if (self.isLastPage) {
        self.isLastPage = false;
    }
    if (index < 0) {
        NSLog(@"******************* 上 *** 一 *** 章 **********************");
        self.currentChapter--;
        self.lastRange = NSMakeRange(0, 0);
        index = [self.PageRange[self.currentChapter] rangeList].count - 1;
    }
    NSLog(@"当前页数 ==================== %ld ===================",index);
    // 存储当前的页数
    self.currentPage = index;
    return [self viewControllerAtIndex:index type:Before];

}
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = ((ContentViewController *)viewController).index;
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (self.isLastPage) {
        index = 0;
        self.currentChapter++;
        self.lastRange = NSMakeRange(0, 0);
        self.isLastPage = false;
        NSLog(@"******************* 下 *** 一 *** 章 **********************");
    }
    self.currentPage = index;
    NSLog(@"当前页数 ==================== %ld ===================",index);
    return [self viewControllerAtIndex:index type:After];
}

#pragma mark - 根据index得到对应的UIViewController
/**
 *  根据页数和页面出现方向创建显示文字的控制器
 *
 *  @param index 页数
 *  @param type  视图将要出现的位置 类型为结构体
                 Before  前
                 After   后
 *
 *  @return 返回控制器实例
 */
- (ContentViewController *)viewControllerAtIndex:(NSUInteger)index type:(ZEViewAppear)type {
    
    // 创建一个新的控制器类，并且分配给相应的数据
    ContentViewController *contentVC = [[ContentViewController alloc] init];
    contentVC.index = index;
    NSLog(@"当前章节CID &&&&&&&&&&&&&&&&&  %ld  #################### %@ ==================",self.currentChapter,[self.cacheChapter[self.currentChapter] cid]);
    NSString *text = [self calculatePagingData:[self.cacheChapter[self.currentChapter] txt] type:type];
    contentVC.content = [[NSAttributedString alloc]initWithString:text attributes:self.attributes];
    
    return contentVC;
}

/**
 *  计算每页的字数并返回截取后的字符串
 *
 *  @param text      要截取的字符串
 *  @param direction 截取的字符串要显示的位置
 *
 *  @return 截取好的字符串
 */
- (NSString *)calculatePagingData:(NSString *)text type:(ZEViewAppear)direction {
    
    if (text.length == 0) {
        return nil;
    } else {
        // 计算显示区域的Size
        CGSize size = CGSizeMake(SCREEN_WIDTH-30, SCREEN_HEIGHT-20);
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
                                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                                             attributes:self.attributes
                                                                                context:nil].size;
                NSLog(@"初始 textHeight = %f",textSize.height);
                // 判断初始Size.height 是否大于 显示区域的height
                if (textSize.height > size.height) {
                    // 循环减少初始 length 的数值  直到初始 Size.height 小于显示区域的 height
                    while (textSize.height > size.height) {
                        range.length -= 1;
                        textSize = [[text substringWithRange:range] boundingRectWithSize:size
                                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                                              attributes:self.attributes
                                                                                 context:nil].size;
                    }
                    // 判断是否为最后一页
                } else if (range.location + range.length != text.length) {
                    // 循环增加初始 length 的数值 直到初始Size.height 大于显示区域的 height
                    while (textSize.height < size.height) {
                        range.length += 1;
                        textSize = [[text substringWithRange:range] boundingRectWithSize:size
                                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                                              attributes:self.attributes
                                                                                 context:nil].size;
                    }
                    // 计算完成后 length 会多一个数 将多的减掉
                    range.length -= 1;
                }
                NSLog(@"计算后   location = %ld , length = %ld currentPage = %ld",range.location,range.length,self.currentPage);
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

- (NSMutableArray *)cacheChapter {
    if (_cacheChapter == nil) {
        _cacheChapter = [NSMutableArray array];
    }
    return _cacheChapter;
}

- (NSMutableArray *)PageRange {
    if (_PageRange == nil) {
        _PageRange = [NSMutableArray array];
    }
    return _PageRange;
}

@end
