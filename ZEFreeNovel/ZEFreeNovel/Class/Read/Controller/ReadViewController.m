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
#import "ZEToolBar.h"
#import "ZEReadSettingView.h"
@interface ReadViewController () <UIPageViewControllerDataSource,UIPageViewControllerDelegate,ReadDataSourceDelegate,ZEReadSettingViewDelegate>

@property (nonatomic, strong) Book *model;
@property (nonatomic, strong) ReadDataSource *datasource;
@property (nonatomic, strong) ZEToolBar *toolBar;
@property (nonatomic, strong) ZEReadSettingView *settingView;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, assign) NSInteger textFont;
/** 是否记录的章节页数 */
@property (nonatomic, assign) BOOL isShowRecordPage;
/** 是否隐藏ToolBar */
@property (nonatomic, assign) BOOL isHidden;
/** YES后 NO前 */
@property (nonatomic, assign) BOOL isRight;
/** 是否换章节 */
@property (nonatomic, assign) BOOL isTurning;

@end

@implementation ReadViewController

- (instancetype)initWithBooksInfo:(Book *)model {
    if (self = [super init]) {
#warning 需要抽取代码 ————  字体背景色的存取需要封装
        _textFont = [[NSUserDefaults standardUserDefaults] integerForKey:@"TextFont"] == 0 ? 25 : [[NSUserDefaults standardUserDefaults] integerForKey:@"TextFont"];
        _model = model;
        if ([model.isSave boolValue]) {
            _isShowRecordPage = YES;
        }
        _datasource = [[ReadDataSource alloc]init];
        _datasource.delegate = self;
        _datasource.bookId = model.bookId;
        _datasource.textFont = _textFont;
        _datasource.currentChapterIndex = [self.model.readChapter integerValue];
        [_datasource chaptersWithBookId];
    }
    return self;
}
#pragma mark 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
#warning 需要抽取代码 ————  字体背景色的存取需要封装
    NSInteger colorIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"ColorIndex"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"reader_bg%ld.png",colorIndex]]];
    UIBarButtonItem *backButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(navigationPopView)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    self.hidesBottomBarWhenPushed = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(callToolBar)];
    [self.view addGestureRecognizer:tap];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willTerminate:) name:UIApplicationWillTerminateNotification object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:false];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    _isRight = NO;
    _isTurning = NO;
    index--;
    if (index < 0) {
        _isTurning = YES;
        [self.datasource preChapter];
        index = self.datasource.lastPage;
    }
    return [self viewControllerAtIndex:index];
}
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers  {
    
    
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = ((ContentViewController *)viewController).index;
    NSLog(@"当前%ld页",index);
    if (self.datasource.currentChapterIndex == self.datasource.chapters.count - 1 && index == self.datasource.lastPage) {
        return nil;
    }
    _isRight = YES;
    _isTurning = NO;
    index++;
    if (index > self.datasource.lastPage) {
        _isTurning = YES;
        [self.datasource nextChapter];
        index = 0;
    }
    return [self viewControllerAtIndex:index];
}
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (!completed) {
        if (_isRight && _isTurning) {
            [self.datasource preChapter];
            NSLog(@"下一页且正好换章节");
        } else if (!_isRight && _isTurning) {
            [self.datasource nextChapter];
            NSLog(@"上一页且正好换章节");
        }
    }
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
/** 根据页数创建显示文字的控制器 */
- (ContentViewController *)viewControllerAtIndex:(NSUInteger)index {
    NSLog(@"创建第%ld页",index);
    // 创建一个新的控制器类，并且分配给相应的数据
    ContentViewController *contentVC = [[ContentViewController alloc] init];
    contentVC.index = index;
    contentVC.name = [self.datasource name];
    contentVC.content = [self.datasource stringWithPage:index];
    contentVC.font = self.textFont;
    contentVC.view.backgroundColor = self.view.backgroundColor;
    return contentVC;
}
#pragma mark ReadDataSourceDelegate
- (void)dataSourceDidFinish {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.datasource openChapter];
    [self initPageViewController:YES];
}
#pragma mark ZEReadSettingViewDelegate
- (void)changedFont:(NSInteger)font {
    self.textFont = font;
    self.datasource.textFont = font;
#warning 需要抽取代码 ————  字体背景色的存取需要封装 ————  字体背景色的存取需要封装
    [[NSUserDefaults standardUserDefaults] setInteger:font forKey:@"TextFont"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSInteger page = [self.datasource fontChangedPageWithCurrentPage:[_pageViewController.viewControllers.lastObject index]];
    [self showPage:page];
}
- (void)backgroudColorDidChanged:(NSInteger)colorIndex {
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"reader_bg%ld.png",colorIndex]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    _pageViewController.viewControllers.lastObject.view.backgroundColor = self.view.backgroundColor;
#warning 需要抽取代码 ————  字体背景色的存取需要封装
    [[NSUserDefaults standardUserDefaults] setInteger:colorIndex forKey:@"ColorIndex"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark UI操作
- (void)showPage:(NSInteger)page {
        NSLog(@"pageviewcontroller 设置数据 %ld",page);
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
- (void)navigationPopView {
    if (![self.model.isSave boolValue]) {
        [self showAlert];
        return;
    }
    [self.navigationController popViewControllerAnimated:NO];
    [self saveRecord];
}
// 隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    if (self.navigationController.navigationBarHidden) {
        return true;
    }
    return false;
}
#pragma mark 事件响应
- (void)willDisplayChapterList {
    ChapterListViewController *list = [[ChapterListViewController alloc]initWithSelectCallBackBlock:^(Chapter *chapter) {
        NSLog(@"%@",chapter);
        self.datasource.currentChapterIndex = [self.datasource.chapters indexOfObject:chapter];
        [self.datasource openChapter];
        self.model.readPage = @(0);
        [self.datasource cacheContentTextWithNumbers:10];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }];
    list.readChapter = self.datasource.currentChapterIndex;
    list.chapters = [NSArray arrayWithArray:self.datasource.chapters];
    [self.navigationController pushViewController:list animated:YES];
}
- (void)readSetting {
    [self.toolBar removeFromSuperview];
    [self.settingView show];
}
- (void)moreSetting {
    
}

- (void)callToolBar {
    _isHidden = !_isHidden;
    if (_isHidden) {
        NSLog(@"显示TOOLBAR");
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.view addSubview:self.toolBar];
        _pageViewController.delegate = nil;
        _pageViewController.dataSource = nil;
    } else {
        NSLog(@"隐藏TOOLBAR");
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.settingView hidden];
        [self.toolBar removeFromSuperview];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
    }
}
#pragma mark 小说的保存或删除方法
- (void)saveRecord{
    self.model.readChapter = @(self.datasource.currentChapterIndex);
    self.model.readPage = @([_pageViewController.viewControllers.lastObject index]);
    self.model.isSave = @(YES);
    self.model.readTime = [NSDate date];
    [[PersistentStack stack] save];
}
- (void)willTerminate:(NSNotification *)notification {
    [self saveRecord];
}
#pragma mark 懒加载
- (ZEToolBar *)toolBar {
    if (_toolBar == nil) {
        _toolBar = [[ZEToolBar alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 50)];
        UIBarButtonItem *listButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"reader_cover"] style:UIBarButtonItemStylePlain target:self action:@selector(willDisplayChapterList)];
        UIBarButtonItem *space1 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *setting = [[UIBarButtonItem alloc]initWithTitle:@"Aa" style:UIBarButtonItemStylePlain target:self action:@selector(readSetting)];
        UIBarButtonItem *space2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *more = [[UIBarButtonItem alloc]initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(moreSetting)];
        [_toolBar setItems:@[listButton,space1,setting,space2,more] animated:NO];
    }
    return _toolBar;
}

- (ZEReadSettingView *)settingView {
    if (_settingView == nil) {
        _settingView = [[ZEReadSettingView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 100)];
        _settingView.delegate = self;
        _settingView.textFont = self.textFont;
#warning 需要抽取代码 ————  字体背景色的存取需要封装
        _settingView.colorIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"ColorIndex"];
        [self.view addSubview:_settingView];
    }
    return _settingView;
}
@end