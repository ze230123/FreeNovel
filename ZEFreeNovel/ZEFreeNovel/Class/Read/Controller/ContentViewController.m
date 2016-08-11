//
//  ContentViewController.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "ContentViewController.h"
#import "TextDisplayView.h"

@interface ContentViewController ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) TextDisplayView *textView;

@end

@implementation ContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-20, 30)];
    _nameLabel.font = [UIFont systemFontOfSize:15];
    
    _textView = [[TextDisplayView alloc]initWithFrame:CGRectMake(10, 30, SCREEN_WIDTH-20, SCREEN_HEIGHT-50)];
    _textView.backgroundColor = [UIColor lightGrayColor];
    _textView.string = self.content;
    _textView.font = _font;
    [self.view addSubview:_nameLabel];
    [self.view addSubview:_textView];
}

- (void) viewWillAppear:(BOOL)paramAnimated{
    [super viewWillAppear:paramAnimated];
    _textView.string = self.content;
    _nameLabel.text = self.name;
    [_textView setNeedsDisplay];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"%@ 控制器被销毁 第 %ld 页",[[self class] description],self.index);
}

@end
