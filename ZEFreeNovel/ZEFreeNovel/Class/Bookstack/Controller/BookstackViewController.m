//
//  StacksViewController.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/25.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "BookstackViewController.h"
#import "ReadViewController.h"
#import "BookstackCell.h"
#import "PersistentStack.h"
#import "AFAppDotNetAPIClient.h"

@interface BookstackViewController () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *books;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UIBarButtonItem *finishButton;
@property (nonatomic, strong) UIBarButtonItem *deleteButton;
@property (nonatomic, assign) BOOL edit;
@end

@implementation BookstackViewController
#pragma mark 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    _books = [NSMutableArray array];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"书库";
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.collectionView addGestureRecognizer:_longPress];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    NSArray *result = [Book resultWithPredicate:nil sortDescriptors:@[@{@"key":@"readTime",@"ascending":@(false)}] inContext:[PersistentStack stack].backgroundContext];
    [self.books removeAllObjects];
    [self.books addObjectsFromArray:result];
    [self.collectionView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"%@ 控制器被销毁",[[self class] description]);
}

#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.books.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BookStackCell" forIndexPath:indexPath];
    return cell;
}
#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    Book *book = self.books[indexPath.item];
    BookstackCell *stackCell = (BookstackCell *)cell;
    [stackCell setImage:[UIImage imageNamed:@"book"]];
    [stackCell setName:book.name];
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.edit) {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
        ReadViewController *read = [[ReadViewController alloc]initWithBooksInfo:self.books[indexPath.item]];
        self.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:read animated:true];
        self.hidesBottomBarWhenPushed=NO;
    }
}
- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    if (self.edit) {
        return;
    }
    if (_longPress.state == UIGestureRecognizerStateBegan) {
        [self setNavigationBarWithEdit];
        NSIndexPath *selectIndexPath = [self.collectionView indexPathForItemAtPoint:[_longPress locationInView:self.collectionView]];
        // 找到当前的cell
        [self.collectionView selectItemAtIndexPath:selectIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }
}
- (void)setNavigationBarWithEdit {
    self.edit = YES;
    self.navigationItem.rightBarButtonItem = self.finishButton;
    self.navigationItem.leftBarButtonItem = self.deleteButton;
    self.title = nil;
}
- (void)setNavigationBarWithFinish {
    self.edit = NO;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    self.title = @"书架";
}
- (void)finish {
    NSArray *selectItems =  self.collectionView.indexPathsForSelectedItems;
    for (NSIndexPath *indexPath in selectItems) {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
    [self setNavigationBarWithFinish];
    NSLog(@"完成");
}
- (void)deleteBook {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"您确定要删除选中的小说吗" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除选中小说" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSArray *deleteItems = self.collectionView.indexPathsForSelectedItems;
        for (NSIndexPath *indexPath in deleteItems) {
            Book *book = self.books[indexPath.item];
            [self.books removeObject:book];
            [[PersistentStack stack] removeRecordWith:book.bookId];
        }
        [[PersistentStack stack] save];
        [self.collectionView deleteItemsAtIndexPaths:deleteItems];
        [self setNavigationBarWithFinish];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:deleteAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark 懒加载
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake((SCREEN_WIDTH-80)/3, ((SCREEN_WIDTH-80)/3)*1.7);
        layout.minimumLineSpacing = 40;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(20, 20, 10, 20);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.allowsMultipleSelection = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[BookstackCell class] forCellWithReuseIdentifier:@"BookStackCell"];
    }
    return _collectionView;
}
- (UIBarButtonItem *)finishButton {
    if (_finishButton == nil) {
        _finishButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finish)];
    }
    return _finishButton;
}
- (UIBarButtonItem *)deleteButton {
    if (_deleteButton == nil) {
        _deleteButton = [[UIBarButtonItem alloc]initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteBook)];
    }
    return _deleteButton;
}

@end
