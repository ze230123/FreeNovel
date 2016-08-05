//
//  ReadViewController.m
//  ZEFreeNovel
//

//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//
#import "ReadViewController.h"
#import "ContentViewController.h"

#import "ReadUtils.h"

#import "UIPageViewController+UIGestureRecognizers.h"

@interface ReadViewController () <UIPageViewControllerDataSource,UIPageViewControllerDelegate,ReadUtilsDelegate>
@property (nonatomic, strong) ReadUtils *utils;
@property (nonatomic, strong) UIView *tapView;
@property (nonatomic, strong) Book *model;
@property (nonatomic, strong) UIPageViewController *pageViewController;

@end

@implementation ReadViewController

- (instancetype)initWithBooksInfo:(Book *)model {
    if (self = [super init]) {
        _model = model;
        _utils = [[ReadUtils alloc]init];
        _utils.delegate = self;
        _utils.bookId = model.bookId;
        _utils.readChapter = [model.readChapter integerValue];
        _utils.readPage = [model.readPage integerValue];
    }
    return self;
}

#pragma mark 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *barButtonItemLeft=[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(navigationPopView)];
    [[self navigationItem] setLeftBarButtonItem:barButtonItemLeft];

    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self.navigationController setNavigationBarHidden:YES animated:false];
    
    NSDictionary *options = @{UIPageViewControllerOptionSpineLocationKey : @(UIPageViewControllerSpineLocationMin)};
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:options];
    
    // 设置UIPageViewController代理和数据源
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    _pageViewController.view.frame = self.view.bounds;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.utils readyRead];
}

- (void)dealloc {
    NSLog(@"%@ 控制器被销毁",[[self class] description]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPageViewControllerDataSource And UIPageViewControllerDelegate
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = ((ContentViewController *)viewController).index;
    // 当前章节和当前页数都为0 代表当前为图书第一张的第一页
    if ([self.utils isFirstPageForIndex:index]) {
        return nil;
    }
    NSInteger page = [self.utils pageForIndex:index type:Before];
    return [self viewControllerAtIndex:page type:Before];
}
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = ((ContentViewController *)viewController).index;
    if ([self.utils isLastPageForIndex:index]) {
        return nil;
    }
    NSInteger page = [self.utils pageForIndex:index type:After];
//    [self.utils isRequestMoreContent];
    return [self viewControllerAtIndex:page type:After];
}

#pragma mark - 根据index得到对应的UIViewController
/**
 *  根据页数和页面出现方向创建显示文字的控制器
 */
- (ContentViewController *)viewControllerAtIndex:(NSUInteger)index type:(ZEViewAppear)type {
    
    // 创建一个新的控制器类，并且分配给相应的数据
    ContentViewController *contentVC = [[ContentViewController alloc] init];
    contentVC.index = index;
    contentVC.name = [self.utils currentChapterName];
    contentVC.content = [self.utils pagingStringForType:type];
    return contentVC;
}
#pragma mark ReadUtilsDelegate
- (void)getChapterContentFinished {
    [self setPageViewControllers];
}
#pragma mark UI操作
- (void)setPageViewControllers {
    if (self.pageViewController.viewControllers.count == 0) {
        NSLog(@"pageviewcontroller 设置数据");
        ContentViewController *initialViewController = [self viewControllerAtIndex:[self.model.readPage integerValue] type:After];// 得到第一页
        [_pageViewController setViewControllers:@[initialViewController]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:true
                                     completion:nil];
    }
}

- (void)navigationPopView {
    if (![self.model.isSave boolValue]) {
        [self showAlert];
        return;
    }
    [self.navigationController popViewControllerAnimated:false];
    [self saveRecord];
}

- (void)showhide {
    NSLog(@"显示导航栏");
    [self.navigationController setNavigationBarHidden:false animated:true];
    [self.view addSubview:self.tapView];
}
- (void)hiddenNavigationBar {
    NSLog(@"隐藏导航栏");
    [self.navigationController setNavigationBarHidden:true animated:true];
    [self.tapView removeFromSuperview];
}
// 隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    if (self.navigationController.navigationBarHidden) {
        return true;
    }
    return false;
}

#pragma mark 小说的保存或删除方法
- (void)removeRecord {
    [self.utils removeRecord];
    [[PersistentStack stack] save];
}
- (void)saveRecord {
    Book *book = [Book findWithPredicate:[NSString stringWithFormat:@"bookId = %@",self.model.bookId] inContext:[PersistentStack stack].context];
    book.readChapter = @(self.utils.readChapter);
    book.readPage = @(self.utils.readPage);
    book.isSave = @(true);
    book.readTime = [NSDate date];
    [[PersistentStack stack] save];
}
#pragma mark 懒加载
- (UIView *)tapView {
    if (_tapView == nil) {
        _tapView = [[UIView alloc]initWithFrame:self.view.bounds];
        _tapView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenNavigationBar)];
        [_tapView addGestureRecognizer:tap];
    }
    return _tapView;
}

- (void)showAlert {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"觉得这本书不错，就加入书架吧" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *clAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             [self removeRecord];
            [self.navigationController popViewControllerAnimated:false];
        }];
        UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"加入书架" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self saveRecord];
            [self.navigationController popViewControllerAnimated:false];
        }];
        [alert addAction:clAction];
        [alert addAction:addAction];
    [self presentViewController:alert animated:YES completion:nil];
}
@end