//
//  TypeListCell.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "TypeListCell.h"

@interface TypeListCell ()

@property (nonatomic, strong) UILabel *typeName;

@end

@implementation TypeListCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.typeName];
        [self.typeName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setLableText:(NSString *)text {
    self.typeName.text = text;
}

- (UILabel *)typeName {
    if (_typeName == nil) {
        _typeName = [[UILabel alloc]init];
        _typeName.textAlignment = NSTextAlignmentCenter;
    }
    return _typeName;
}

@end
