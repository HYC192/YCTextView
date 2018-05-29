//
//  YCTextView.h
//  YCTextView
//
//  Created by mac on 2018/5/28.
//  Copyright © 2018年 YC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YCTextView : UITextView
/**
 提示文字
 */
@property (nonatomic, copy) NSString *placeHolder;
/**
 提示文字颜色
 */
@property (nonatomic, strong) UIColor *placeHolderTextColor;
@end
