//
//  ZEToolBar.h
//  ZEFreeNovel
//
//  Created by 泽i on 16/8/11.
//  Copyright © 2016年 泽i. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ZEToolBarDelegate <UIToolbarDelegate>

- (void)willDisplayChapterList;
- (void)readSetting;
- (void)moreSetting;

@end

@interface ZEToolBar : UIToolbar


@end
