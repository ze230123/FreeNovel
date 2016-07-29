//
//  BooksModel.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//
#import "TypeModel.h"

/// 图书信息模型
@interface BooksModel : TypeModel
/** 作者 */
@property (nonatomic, copy) NSString *author;
/** 最新章节 */
@property (nonatomic, copy) NSString *latestChapter;
/** 图书大小 */
@property (nonatomic, copy) NSString *size;
/** 类型 */
@property (nonatomic, copy) NSString *type;
/** 类型名 */
@property (nonatomic, copy) NSString *typeName;
/** 更新时间 */
@property (nonatomic, copy) NSString *updateTime;

@end
