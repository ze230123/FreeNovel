//
//  TabBarController.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/25.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "TabBarController.h"

#import "StacksViewController.h"
#import "BookstoreViewController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    StacksViewController *stacks = [[StacksViewController alloc]init];
    UINavigationController *stacksNav = [[UINavigationController alloc]initWithRootViewController:stacks];
    stacksNav.title = @"书库";
    
    BookstoreViewController *bookstore = [[BookstoreViewController alloc]init];
    UINavigationController *bookstoreNav = [[UINavigationController alloc]initWithRootViewController:bookstore];
    bookstoreNav.title = @"书城";
    
    self.viewControllers = @[stacksNav,bookstoreNav];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
