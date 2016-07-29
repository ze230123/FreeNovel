//
//  BooksListCell.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/7/27.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BooksModel.h"
/**
 *  图书列表Cell
 */
@interface BooksListCell : UICollectionViewCell

- (void)setImage:(UIImage *)image;
- (void)setBooksInfo:(BooksModel *)model;

@end
