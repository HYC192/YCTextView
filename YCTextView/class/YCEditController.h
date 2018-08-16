//
//  YCEditController.h
//  YCTextView
//
//  Created by mac on 2018/5/29.
//  Copyright © 2018年 YC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YCEditToolBar.h" //底部控件

typedef NS_ENUM(NSInteger, YCEditObjType) {
    YCEditObjTypeTextView = 1,
    YCEditObjTypeScrollerView,
    YCEditObjTypeView
};
@interface YCEditController : UIViewController<YCEditToolBarDelegate>
/**
 底部控件工具
 */
@property (nonatomic, strong) YCEditToolBar *editToolBar;

/**
 传入内容
 */
@property (nonatomic, strong) NSString *messageContent;
@end
