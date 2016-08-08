//
//  ChapterListViewController.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/5.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "ChapterListViewController.h"

@interface ChapterListViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) SelectCallBack callback;
@property (nonatomic, assign) BOOL ascending;

@property (nonatomic, strong) Chapter *currentChapter;
@end

@implementation ChapterListViewController

- (instancetype)initWithSelectCallBackBlock:(SelectCallBack)block {
    if (self = [super init]) {
        self.callback = block;
        _ascending = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]initWithTitle:@"排序" style:UIBarButtonItemStylePlain target:self action:@selector(paixu)];
    self.navigationItem.rightBarButtonItem = buttonItem;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.currentChapter = self.chapters[self.readChapter];
    if (self.readChapter - 7 > 0) {
        NSLog(@"当前章节：%ld",self.readChapter);
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.readChapter-7 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
}

- (void)paixu {
    self.ascending = !self.ascending;
    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"cid" ascending:self.ascending];//yes升序排列，no,降序排列
    NSArray *array = [self.chapters sortedArrayUsingDescriptors:@[sd1]];
    self.chapters = array;
    [self.tableView reloadData];
}
- (void)dealloc {
    NSLog(@"%@ 控制器被销毁",[[self class] description]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chapters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.textColor = [[self.chapters[indexPath.item] isLoad]boolValue] ? [UIColor blackColor] : [UIColor lightGrayColor];
    cell.textLabel.text = [self.chapters[indexPath.item] name];
    if (self.currentChapter == self.chapters[indexPath.row]) {
        cell.textLabel.textColor = [UIColor blueColor];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.callback(self.chapters[indexPath.row]);
    [self.navigationController popViewControllerAnimated:false];
}
#pragma mark 懒加载
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ListCell"];
    }
    return _tableView;
}

@end
