//
//  BookstoreViewController.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/25.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "BookstoreViewController.h"
#import "BooksListViewController.h"
#import "TypeList.h"
#import "TypeModel.h"
#import "TypeListCell.h"

@interface BookstoreViewController () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) TypeList *typeList;

@end

@implementation BookstoreViewController
#pragma mark 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"书城";
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [HttpUtils post:BOOK_TYPELIST_URL parameters:nil callBack:^(id data) {
        NSLog(@"类型列表完成");
        self.typeList = [TypeList mj_objectWithKeyValues:data];
        [self.collectionView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.typeList.typeList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TypeListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TypeListCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    TypeModel *model = self.typeList.typeList[indexPath.item];
    cell.backgroundColor = [UIColor lightGrayColor];
    cell.layer.cornerRadius = 20;
    [(TypeListCell *)cell setLableText:model.name];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.hidesBottomBarWhenPushed=YES;
    BooksListViewController *booksList = [[BooksListViewController alloc]initWithType:self.typeList.typeList[indexPath.item]];
    [self ze_pushViewController:booksList animated:true];
    self.hidesBottomBarWhenPushed=NO;
}

#pragma mark 懒加载
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake((SCREEN_WIDTH-60)/2, (SCREEN_WIDTH-60)/4);
        layout.minimumLineSpacing = 30;
        layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[TypeListCell class] forCellWithReuseIdentifier:@"TypeListCell"];
    }
    return _collectionView;
}
@end
