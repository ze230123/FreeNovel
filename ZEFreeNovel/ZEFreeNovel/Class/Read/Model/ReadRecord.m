//
//  ReadRecord.m
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/31.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import "ReadRecord.h"

@implementation ReadRecord

- (instancetype)init {
    if (self = [super init]) {
        _currentChapter = 0;
        _currentPage = 0;
        _lastRange = NSMakeRange(0, 0);
        _PageRange = [NSMutableArray array];
        _cacheChapters = [NSMutableArray array];
    }
    return self;
}

@end
