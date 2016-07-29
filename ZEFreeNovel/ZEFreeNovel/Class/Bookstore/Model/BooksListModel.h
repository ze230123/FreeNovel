//
//  BooksListModel.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <Foundation/Foundation.h>
/// 图书列表模型
@interface BooksListModel : NSObject

@property (nonatomic, copy) NSString *allNum;
@property (nonatomic, copy) NSString *allPages;
@property (nonatomic, copy) NSString *currentPage;
@property (nonatomic, copy) NSString *maxResult;
@property (nonatomic, strong) NSMutableArray *contentlist;

@end
