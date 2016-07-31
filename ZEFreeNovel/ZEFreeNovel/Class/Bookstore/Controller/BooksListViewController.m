//
//  BooksListViewController.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//


#import "BooksListViewController.h"
#import "ReadViewController.h"
#import "BooksModel.h"
#import "BooksListModel.h"

#import "BooksListCell.h"


@interface BooksListViewController () <UICollectionViewDataSource,UICollectionViewDelegate>
/** 书籍列表模型 */
@property (nonatomic, strong) BooksListModel *listModel;
/** 图书类型模型 */
@property (nonatomic, strong) TypeModel *type;

@property (nonatomic, strong) UICollectionView *collectionView;


@end

@implementation BooksListViewController

- (instancetype)initWithType:(TypeModel *)model {
    if (self = [super init]) {
        _type = model;
    }
    return self;
}

#pragma mark 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.type.name;
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [HttpUtils post:BOOK_BOOKSLIST_URL parameters:@{@"typeId":self.type.Id} callBack:^(id data, NSError *error) {
        if (!error) {
            self.listModel = [BooksListModel mj_objectWithKeyValues:data];
            [self.collectionView reloadData];
        }
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    self.type = nil;
    self.listModel = nil;
    NSLog(@"%@ 控制器被销毁",[[self class] description]);
}
#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listModel.contentlist.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BookListCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    BooksModel *model = self.listModel.contentlist[indexPath.item];
    BooksListCell *listCell = (BooksListCell *)cell;
    [listCell setImage:[UIImage imageNamed:@"book"]];
    [listCell setBooksInfo:model];
    if (indexPath.item == (self.listModel.contentlist.count - 5)) {
        [self getMoreBooks];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    BooksModel *model = self.listModel.contentlist[indexPath.item];
    self.hidesBottomBarWhenPushed=YES;
    ReadViewController *read = [[ReadViewController alloc]initWithBooksInfo:model.Id];
    [self ze_pushViewController:read animated:false];
}

#pragma mark 获取更多图书
- (void)getMoreBooks {
    NSLog(@"更多图书");
    [HttpUtils post:BOOK_BOOKSLIST_URL parameters:@{@"typeId":self.type.Id,@"page":self.listModel.currentPage.addOne} callBack:^(id data, NSError *error) {
        if (!error) {
            BooksListModel *moreList = [BooksListModel mj_objectWithKeyValues:data];
            self.listModel.currentPage = moreList.currentPage;
            [self.listModel.contentlist addObjectsFromArray:moreList.contentlist];
            [self.collectionView reloadData];

        }
    }];
}


#pragma mark 懒加载
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(SCREEN_WIDTH, 100);
        layout.minimumLineSpacing = 5;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[BooksListCell class] forCellWithReuseIdentifier:@"BookListCell"];
    }
    return _collectionView;
}
@end
