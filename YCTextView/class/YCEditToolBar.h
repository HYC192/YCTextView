//
//  YCEditToolBar.h
//  YCTextView
//
//  Created by mac on 2018/6/12.
//  Copyright © 2018年 YC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YCEditToolBarDelegate <NSObject>

@optional

/**
 改变视图高度

 @param inputHeight 高度变化值
 */
- (void)didChangeInputHeight:(CGFloat)inputHeight;
/**
 是否显示隐藏视图

 @param tag 区分
 @param show 判断值
 */
- (void)_changeToolbarBottomViewShowHideAction:(NSInteger)tag
                                        isShow:(BOOL)show;
@end
@interface YCEditToolBar : UIView
/**
 是否弹窗了键盘
 */
@property (nonatomic, getter=isPopKeyboard) BOOL popKeyboard;
/**
 代理
 */
@property (nonatomic, weak) id<YCEditToolBarDelegate> delegate;
/**
 显示高度

 @param bottomHeight 传入变化高度
 */
- (void)willShowBottomHeight:(CGFloat)bottomHeight;
/**
 默认高度
 */
+ (CGFloat)defaultHeight;
@end

@interface YCEditToolbarItem : NSObject

@property (strong, nonatomic, readonly) UIButton *button;

@property (strong, nonatomic) UIView *bottomView;

- (instancetype)initWithButton:(UIButton *)button
                      withView:(UIView *)bottomView;

@end
