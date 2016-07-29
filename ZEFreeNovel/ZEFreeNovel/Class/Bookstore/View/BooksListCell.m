//
//  BooksListCell.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "BooksListCell.h"

@interface BooksListCell ()
/** 图片 */
@property (nonatomic, strong) UIImageView *imageView;
/** 书名 */
@property (nonatomic, strong) UILabel *nameLable;
/** 作者 */
@property (nonatomic, strong) UILabel *authorLable;
/** 最新章节 */
@property (nonatomic, strong) UILabel *latestChapter;

@end

@implementation BooksListCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.nameLable];
        [self.contentView addSubview:self.authorLable];
        [self.contentView addSubview:self.latestChapter];
        
        [self subViewsaddConstraint];
    }
    return self;
}
/// 子视图添加约束
- (void)subViewsaddConstraint {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.contentView).offset(8);
        make.size.mas_equalTo(CGSizeMake(self.frame.size.height-36, self.frame.size.height-16));
    }];
    [self.nameLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_top).offset(8);
        make.left.equalTo(self.imageView.mas_right).offset(8);
        make.right.equalTo(self.contentView).offset(-8);
    }];
    [self.authorLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLable.mas_bottom).offset(8);
        make.leading.equalTo(self.nameLable.mas_leading);
        make.right.equalTo(self.contentView).offset(-8);
    }];
    [self.latestChapter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.authorLable.mas_bottom).offset(8);
        make.leading.equalTo(self.authorLable.mas_leading);
        make.right.equalTo(self.contentView).offset(-8);
    }];
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)setBooksInfo:(BooksModel *)model {
    self.nameLable.text = model.name;
    self.authorLable.text = model.author;
    self.latestChapter.text = model.latestChapter;
}

#pragma make 懒加载
- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc]init];
    }
    return _imageView;
}
- (UILabel *)nameLable {
    if (_nameLable == nil) {
        _nameLable = [[UILabel alloc]init];
        _nameLable.font = [UIFont systemFontOfSize:15];
    }
    return _nameLable;
}
- (UILabel *)authorLable {
    if (_authorLable == nil) {
        _authorLable = [[UILabel alloc]init];
        _authorLable.font = [UIFont systemFontOfSize:15];
    }
    return _authorLable;
}
- (UILabel *)latestChapter {
    if (_latestChapter == nil) {
        _latestChapter = [[UILabel alloc]init];
        _latestChapter.font = [UIFont systemFontOfSize:15];
    }
    return _latestChapter;
}
@end
