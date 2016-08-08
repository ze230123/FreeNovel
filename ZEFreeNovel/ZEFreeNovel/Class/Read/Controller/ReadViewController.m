//
//  ReadViewController.m
//  ZEFreeNovel
//

//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//
#import "ReadViewController.h"
#import "ContentViewController.h"
#import "ChapterListViewController.h"

#import "ReadDataSource.h"

#import "UIPageViewController+UIGestureRecognizers.h"

@interface ReadViewController () <UIPageViewControllerDataSource,UIPageViewControllerDelegate,ReadDataSourceDelegate>
@property (nonatomic, strong) UIView *tapView;
@property (nonatomic, strong) Book *model;
@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, assign) BOOL isShowRecordPage;
@property (nonatomic, strong) ReadDataSource *datasource;

@end

@implementation ReadViewController

- (instancetype)initWithBooksInfo:(Book *)model {
    if (self = [super init]) {
        _model = model;
        if ([model.isSave boolValue]) {
            _isShowRecordPage = YES;
        }
        _datasource = [[ReadDataSource alloc]init];
        _datasource.delegate = self;
        _datasource.bookId = model.bookId;
        _datasource.textFont = 25;
        _datasource.currentChapterIndex = [self.model.readChapter integerValue];
        [_datasource chaptersWithBookId];
    }
    return self;
}
#pragma mark 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(navigationPopView)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    UIBarButtonItem *listButton = [[UIBarButtonItem alloc]initWithTitle:@"目录" style:UIBarButtonItemStylePlain target:self action:@selector(pushListViewController)];
    self.navigationItem.rightBarButtonItem = listButton;

    self.hidesBottomBarWhenPushed = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:false];
    [self.navigationController setToolbarHidden:YES animated:false];
    [self.tapView removeFromSuperview];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:false];
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
    if (self.datasource.currentChapterIndex == 0 && index == 0) {
        return nil;
    }
    index--;
    if (index < 0) {
        [self.datasource preChapter];
        index = self.datasource.lastPage;
    }
    return [self viewControllerAtIndex:index];
}
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = ((ContentViewController *)viewController).index;
    index++;
    if (index > self.datasource.lastPage) {
        [self.datasource nextChapter];
        index = 0;
    }
    return [self viewControllerAtIndex:index];
}

#pragma mark - 根据index得到对应的UIViewController

- (void)initPageViewController:(BOOL)isFormList {
    if (_pageViewController) {
        [_pageViewController removeFromParentViewController];
        _pageViewController = nil;
    }
    _pageViewController = [[UIPageViewController alloc]init];
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    if (self.isShowRecordPage) {
        [self showPage:[self.model.readPage integerValue]];
        self.isShowRecordPage = NO;
    } else {
        [self showPage:0];
    }
}
/**
 *  根据页数和页面出现方向创建显示文字的控制器
 */
- (ContentViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    // 创建一个新的控制器类，并且分配给相应的数据
    ContentViewController *contentVC = [[ContentViewController alloc] init];
    contentVC.index = index;
    contentVC.name = [self.datasource name];
    contentVC.content = [self.datasource stringWithPage:index];
    contentVC.font = 25;
    return contentVC;
}
#pragma mark ReadUtilsDelegate
- (void)dataSourceDidFinish {
    [self.datasource openChapter];
    [self initPageViewController:YES];
}
#pragma mark UI操作
- (void)showPage:(NSInteger)page {
        NSLog(@"pageviewcontroller 设置数据");
        ContentViewController *initialViewController = [self viewControllerAtIndex:page];// 得到第一页
        [_pageViewController setViewControllers:@[initialViewController]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:false
                                     completion:nil];
}
- (void)showAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"觉得这本书不错，就加入书架吧" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *clAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[PersistentStack stack] removeRecordWith:self.model.bookId];
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
- (void)pushListViewController {
    ChapterListViewController *list = [[ChapterListViewController alloc]initWithSelectCallBackBlock:^(Chapter *chapter) {
        NSLog(@"%@",chapter);
        self.datasource.currentChapterIndex = [self.datasource.chapters indexOfObject:chapter];
        [self.datasource openChapter];
        self.model.readPage = @(0);
        [self.datasource cacheContentTextWithNumbers:10];
    }];
    list.readChapter = self.datasource.currentChapterIndex;
    list.chapters = [NSArray arrayWithArray:self.datasource.chapters];
    [self.navigationController pushViewController:list animated:YES];
}
- (void)navigationPopView {
    if (![self.model.isSave boolValue]) {
        [self showAlert];
        return;
    }
    [self.navigationController popViewControllerAnimated:NO];
    [self saveRecord];
}

- (void)showhide {
    NSLog(@"显示导航栏");
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self.view addSubview:self.tapView];
}
- (void)hiddenNavigationBar {
    NSLog(@"隐藏导航栏");
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
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
- (void)saveRecord {
    self.model.readChapter = @(self.datasource.currentChapterIndex);
    self.model.readPage = @([_pageViewController.viewControllers.lastObject index]);
    self.model.isSave = @(YES);
    self.model.readTime = [NSDate date];
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

@end