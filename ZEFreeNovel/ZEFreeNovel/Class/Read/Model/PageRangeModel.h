//
//  PageRangeModel.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/29.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  范围模型
 */
@interface PageRangeModel : NSObject
/** 章节编号 */
@property (nonatomic, assign) NSInteger chapterNumber;
/** 每页范围数组 */
@property (nonatomic, strong) NSMutableArray *rangeList;
/**
 *  初始化
 *
 *  @param chapterNumber 章节编号
 *
 *  @return 模型实例
 */
- (instancetype)initWithNumber:(NSInteger)chapterNumber;

@end
