//
//  BookstackCell.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/4.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "BookstackCell.h"

@interface BookstackCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;

@end


@implementation BookstackCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-30)];
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, frame.size.height-30, frame.size.width, 30)];
        _nameLabel.font = [UIFont systemFontOfSize:15];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.numberOfLines = 2;
        [self.contentView addSubview:_imageView];
        [self.contentView addSubview:_nameLabel];
    }
    return self;
}
- (void)setImage:(UIImage *)image {
    _imageView.image = image;
}
- (void)setName:(NSString *)name {
    _nameLabel.text = name;
}
@end
