//
//  ReadViewController.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//
#import "ReadViewController.h"
#import "ContentViewController.h"

#import "ReadBooksModel.h"

#import "ReadUtils.h"
#import "NSString+Extension.h"

@interface ReadViewController () <UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, strong) ReadUtils *utils;
/// 图书的ID
@property (nonatomic, copy) NSString *bookId;
/** 图书模型 */
@property (nonatomic, strong) ReadBooksModel *bookModel;

@end
@implementation ReadViewController

- (instancetype)initWithBooksInfo:(NSString *)bookID {
    if (self = [super init]) {
        _bookId = bookID;
        _utils = [[ReadUtils alloc]init];
        [self getBookChapter];
        
    }
    return self;
}

/// 获取图书章节目录
- (void)getBookChapter {
    [HttpUtils post:BOOK_CHAPTERLIST_URL parameters:@{@"bookId":self.bookId} callBack:^(id data) {
        NSLog(@"获取章节目录完成");
        self.bookModel = [ReadBooksModel mj_objectWithKeyValues:data];
        [self getChapterContent];
    }];
}
/// 获取章节内容 默认为5章
- (void)getChapterContent {
    
    NSMutableArray *cacheList = [NSMutableArray array];
    for (NSInteger index = self.utils.cacheNumber; index < self.utils.cacheNumber + 5; index++) {
        BookChapter *chapter = self.bookModel.chapterList[index];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [HttpUtils post:BOOK_CONTENT_URL parameters:@{@"bookId":chapter.bookId,@"cid":chapter.cid} callBack:^(id data) {
                
                ChapterContent *content = [ChapterContent mj_objectWithKeyValues:data];
                content.txt = [content.txt stringByReplacingOccurrencesOfString:@"<br /><br />" withString:@"\n"];
                [cacheList addObject:content];
                // 如果数组里的模型数量为 5 对数组里的章节内容按升序排序
                if (cacheList.count == 5) {
                    [self.utils sortForcacheChapers:cacheList];
                    [self setPageViewControllers];
                    }
            }];
        });
    }
}

- (void)setPageViewControllers {
    
    if (self.pageViewController.viewControllers.count == 0) {
        NSLog(@"pageviewcontroller 设置数据");
        ContentViewController *initialViewController = [self viewControllerAtIndex:0 type:After];// 得到第一页
        [_pageViewController setViewControllers:@[initialViewController]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:NO
                                     completion:nil];
    }
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
    if ([self.utils isReturnNilForIndex:0]) {
        return nil;
    }
    NSInteger page = [self.utils pageForIndex:index type:Before];
    return [self viewControllerAtIndex:page type:Before];
}
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = ((ContentViewController *)viewController).index;
    if (index == NSNotFound) {
        return nil;
    }
    NSInteger page = [self.utils pageForIndex:index type:After];
    if ([self.utils isRequestMoreContent]) {
        [self getChapterContent];
    }
    return [self viewControllerAtIndex:page type:After];
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
    contentVC.name = [self.utils currentChapterName];
    contentVC.content = [self.utils pagingStringForType:type];
    
    return contentVC;
}
    
@end