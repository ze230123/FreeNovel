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
@property (nonatomic, strong) UIView *tapView;
@end

@implementation BookstackCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-30)];
        _tapView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-30)];
        _tapView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.3];
        _tapView.hidden = YES;
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, frame.size.height-30, frame.size.width, 30)];
        _nameLabel.font = [UIFont systemFontOfSize:15];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.numberOfLines = 2;
        [self.contentView addSubview:_imageView];
        [self.contentView addSubview:_tapView];
        [self.contentView addSubview:_nameLabel];
        [self showRight];
    }
    return self;
}
- (void)setImage:(UIImage *)image {
    _imageView.image = image;
}
- (void)setName:(NSString *)name {
    _nameLabel.text = name;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    _tapView.hidden = !selected;
    NSLog(@"%d",!selected);
}

-(void) showRight {
    UIBezierPath *bezierPath=[UIBezierPath bezierPathWithOvalInRect:CGRectMake(_tapView.bounds.size.width-30, _tapView.bounds.size.height-30, 20, 20)];
    UIBezierPath *dBezierPath = [UIBezierPath bezierPath];
    [dBezierPath moveToPoint:CGPointMake((_tapView.bounds.size.width-30) + 20/4, (_tapView.bounds.size.height-30)+ 20/2)];
    [dBezierPath addLineToPoint:CGPointMake((_tapView.bounds.size.width-30) + 20/2, (_tapView.bounds.size.height-30)+ 20/4*3)];
    [dBezierPath addLineToPoint:CGPointMake((_tapView.bounds.size.width-30) + 20/4*3, (_tapView.bounds.size.height-30)+ 20/3)];
    
    CAShapeLayer *shape=[CAShapeLayer layer];
    shape.lineWidth=1;
    shape.fillColor=[UIColor cyanColor].CGColor;
    shape.strokeColor=[UIColor cyanColor].CGColor;
    
    CAShapeLayer *dShape = [CAShapeLayer layer];
    dShape.lineWidth = 3;
    dShape.fillColor=[UIColor clearColor].CGColor;
    dShape.strokeColor=[UIColor whiteColor].CGColor;
    dShape.lineCap = kCALineCapRound;
    dShape.lineJoin = kCALineJoinRound;
    
    shape.path=bezierPath.CGPath;
    dShape.path = dBezierPath.CGPath;
    [shape addSublayer:dShape];
    [self.tapView.layer addSublayer:shape];
}
@end
