//
//  UIButton+YCExtension.h
//  YCTextView
//
//  Created by mac on 2018/6/13.
//  Copyright © 2018年 YC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YCButtonEdgeInsetsStyle) {
    YCButtonEdgeInsetsStyleTop, // image在上，label在下
    YCButtonEdgeInsetsStyleLeft, // image在左，label在右
    YCButtonEdgeInsetsStyleBottom, // image在下，label在上
    YCButtonEdgeInsetsStyleRight // image在右，label在左
};
@interface UIButton (YCExtension)
/**
 设置button的titleLabel和imageView的布局样式，及间距

 @param style titleLabel和imageView的布局样式
 @param space titleLabel和imageView的间距
 */
- (void)YCLayoutButtonWithEdgeInsetsStyle:(YCButtonEdgeInsetsStyle)style
                          imageTitleSpace:(CGFloat)space;
@end
