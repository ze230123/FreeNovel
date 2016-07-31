//
//  StacksViewController.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/25.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "StacksViewController.h"

@interface StacksViewController ()

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *books;

@end

@implementation StacksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"书库";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addStacks:) name:@"AddStacks" object:nil];
}

- (void)addStacks:(NSNotification *)notification {
    NSLog(@"%@",notification.userInfo);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"%@ 控制器被销毁",[[self class] description]);
}


@end
