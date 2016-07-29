//
//  BookChapter.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <Foundation/Foundation.h>
/// 章节目录模型
@interface BookChapter : NSObject
/** 图书编号 */
@property (nonatomic, copy) NSString *bookId;
/** 章节编号 */
@property (nonatomic, copy) NSString *cid;
/** 章节名 */
@property (nonatomic, copy) NSString *name;

@end
