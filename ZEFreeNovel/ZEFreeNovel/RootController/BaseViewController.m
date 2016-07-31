//
//  BaseViewController.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/31.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)ze_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    [self.navigationController pushViewController:viewController animated:animated];
}

@end
