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
#import "Book.h"
#import "PersistentStack.h"
@interface BookstackViewController () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *books;

@end

@implementation BookstackViewController
#pragma mark 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"书库";
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.books = [Book resultWithPredicate:nil sortDescriptors:@[@{@"key":@"readTime",@"ascending":@(false)}] inContext:[PersistentStack stack].context];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    ReadViewController *read = [[ReadViewController alloc]initWithBooksInfo:self.books[indexPath.item]];
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:read animated:true];
    self.hidesBottomBarWhenPushed=NO;
}
#pragma mark 懒加载
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake((SCREEN_WIDTH-80)/3, ((SCREEN_WIDTH-80)/3)*1.7);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(20, 20, 10, 20);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[BookstackCell class] forCellWithReuseIdentifier:@"BookStackCell"];
    }
    return _collectionView;
}
@end
