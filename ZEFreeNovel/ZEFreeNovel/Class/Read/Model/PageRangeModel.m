//
//  PageRangeModel.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/29.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "PageRangeModel.h"

@implementation PageRangeModel

- (instancetype)initWithNumber:(NSInteger)chapterNumber {
    if (self = [super init]) {
        _chapterNumber = chapterNumber;
        _rangeList = [NSMutableArray array];
    }
    return self;
}

@end
