//
//  ContentViewController.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "ContentViewController.h"

@interface ContentViewController ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextView *textView;

@end

@implementation ContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:true];

    self.view.backgroundColor = [UIColor whiteColor];
    
    _nameLabel = [[UILabel alloc]init];
    _nameLabel.font = [UIFont systemFontOfSize:15];
    
    _textView = [[UITextView alloc]init];
    _textView.userInteractionEnabled = false;
//    _textView.selectable = false;
    _textView.textContainerInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
    [self.view addSubview:_nameLabel];
    [self.view addSubview:_textView];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.view);
        make.left.equalTo(self.view).offset(20);
        make.height.mas_equalTo(30);
    }];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.nameLabel.mas_bottom);
        make.bottom.equalTo(self.view).offset(-20);
    }];
}

- (void) viewWillAppear:(BOOL)paramAnimated{
    [super viewWillAppear:paramAnimated];
    _textView.attributedText = _content;
    _nameLabel.text = _name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"%@ 控制器被销毁 第 %ld 页",[[self class] description],self.index);
}



//- (CGSize) measureFrame: (CTFrameRef) frame
//{
//    CGPathRef framePath = CTFrameGetPath(frame);
//    CGRect frameRect = CGPathGetBoundingBox(framePath);
//    
//    CFArrayRef lines = CTFrameGetLines(frame);
//    CFIndex numLines = CFArrayGetCount(lines);
//    
//    CGFloat maxWidth = 0;
//    CGFloat textHeight = 0;
//    
//    // Now run through each line determining the maximum width of all the lines.
//    // We special case the last line of text. While we've got it's descent handy,
//    // we'll use it to calculate the typographic height of the text as well.
//    CFIndex lastLineIndex = numLines - 1;
//    for(CFIndex index = 0; index < numLines; index++)
//    {
//        CGFloat ascent, descent, leading, width;
//        CTLineRef line = (CTLineRef) CFArrayGetValueAtIndex(lines, index);
//        width = CTLineGetTypographicBounds(line, &ascent,  &descent, &leading);
//        
//        if(width > maxWidth)
//        {
//            maxWidth = width;
//        }
//        
//        if(index == lastLineIndex)
//        {
//            // Get the origin of the last line. We add the descent to this
//            // (below) to get the bottom edge of the last line of text.
//            CGPoint lastLineOrigin;
//            CTFrameGetLineOrigins(frame, CFRangeMake(lastLineIndex, 1), &lastLineOrigin);
//            
//            // The height needed to draw the text is from the bottom of the last line
//            // to the top of the frame.
//            textHeight =  CGRectGetMaxY(frameRect) - lastLineOrigin.y + descent;
//        }
//    }
//    
//    // For some text the exact typographic bounds is a fraction of a point too
//    // small to fit the text when it is put into a context. We go ahead and round
//    // the returned drawing area up to the nearest point.  This takes care of the
//    // discrepencies.
//    return CGSizeMake(ceil(maxWidth), ceil(textHeight));
//}



@end
