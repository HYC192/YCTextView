//
//  YCEditToolBar.m
//  YCTextView
//
//  Created by mac on 2018/6/12.
//  Copyright © 2018年 YC. All rights reserved.
//

#import "YCEditToolBar.h"
#import "YCFontSettingView.h"
#import "UIButton+YCExtension.h"

#define kUIColorFromRGB(rgbValue)                                                                                                                                                  \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]
#define kDefaultToolbarHeight 50 //默认Toolbar尺寸
#define kItemsWidth 38 //默认item尺寸
@interface YCEditToolBar ()
/**
 按键数组
 */
@property (nonatomic, strong) NSMutableArray *actionItems;
/**
 控件背景
 */
@property (nonatomic, strong) UIImageView *backgroundImageView;
/**
 扩展视图容器
 */
@property (nonatomic, strong) UIView *activityButtomView;
/**
 顶部控件视图
 */
@property (nonatomic, strong) UIView *toolbarView;
/**
 键盘切换按键
 */
@property (nonatomic, strong) UIButton *keyboardBtn;
/**
 文字设置按键
 */
@property (nonatomic, strong) UIButton *fontSetBtn;
/**
 文字设置选择视图
 */
@property (nonatomic, strong) UIView *fontSetBottomView;
/**
 图片选择按键
 */
@property (nonatomic, strong) UIButton *photoBtn;
/**
 录音按键
 */
@property (nonatomic, strong) UIButton *recordBtn;
/**
 信纸按键
 */
@property (nonatomic, strong) UIButton *paperBtn;
/**
 文库按键
 */
@property (nonatomic, strong) UIButton *wordModelBtn;
/**
 预览按键
 */
@property (nonatomic, strong) UIButton *previewBtn;
/**
 音乐按键
 */
@property (nonatomic, strong) UIButton *musicBtn;

@end
@implementation YCEditToolBar
#pragma mark - Lifecycle
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor yellowColor];
        _activityButtomView = nil;
        [self _setupSubviews];
    }
    return self;
}

#pragma mark - Custom Accessor
- (UIImageView *)backgroundImageView
{
    if (_backgroundImageView == nil) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundImageView.backgroundColor = [UIColor orangeColor];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _backgroundImageView;
}

- (UIView *)toolbarView
{
    if (_toolbarView == nil) {
        _toolbarView = [[UIView alloc] initWithFrame:self.bounds];
    }
    return _toolbarView;
}

- (UIButton *)keyboardBtn{
    if (_keyboardBtn == nil) {
        _keyboardBtn = [[UIButton alloc] init];
        UIImage *imageNormal2 = [UIImage imageNamed:@"icon_letter_edit_lessen_n"];
        UIImage *imageHighlighted2 = [UIImage imageNamed:@"icon_letter_edit_lessen_n"];
        UIImage *imageSelected2 = [UIImage imageNamed:@"icon_letter_edit_lessen_p"];
        
        [_keyboardBtn setImage:imageNormal2 forState:UIControlStateNormal];
        [_keyboardBtn setImage:imageHighlighted2 forState:UIControlStateHighlighted];
        [_keyboardBtn setImage:imageSelected2 forState:UIControlStateSelected];
        [_keyboardBtn setTitle:@"" forState:UIControlStateNormal];
        [_keyboardBtn setTitleColor:kUIColorFromRGB(0x9E938E) forState:UIControlStateNormal];
        [_keyboardBtn setTitleColor:kUIColorFromRGB(0x595350) forState:UIControlStateHighlighted];
        [_keyboardBtn setTitleColor:kUIColorFromRGB(0x69BF30) forState:UIControlStateSelected];
        [_keyboardBtn.titleLabel setFont:[UIFont systemFontOfSize:10]];
        
        _keyboardBtn.contentMode = UIViewContentModeScaleAspectFit;
        _keyboardBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _keyboardBtn.tag = 1000;
        [_keyboardBtn addTarget:self action:@selector(changeKeyboardAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _keyboardBtn;
}

- (UIButton *)fontSetBtn{
    if (_fontSetBtn == nil) {
        _fontSetBtn = [[UIButton alloc] init];
        UIImage *imageNormal2 = [UIImage imageNamed:@"icon_letter_edit_font_n"];
        UIImage *imageHighlighted2 = [UIImage imageNamed:@"icon_letter_edit_font_n"];
        UIImage *imageSelected2 = [UIImage imageNamed:@"icon_letter_edit_font_p"];
        
        [_fontSetBtn setImage:imageNormal2 forState:UIControlStateNormal];
        [_fontSetBtn setImage:imageHighlighted2 forState:UIControlStateHighlighted];
        [_fontSetBtn setImage:imageSelected2 forState:UIControlStateSelected];
        [_fontSetBtn setTitle:@"文字" forState:UIControlStateNormal];
        [_fontSetBtn setTitleColor:kUIColorFromRGB(0x9E938E) forState:UIControlStateNormal];
        [_fontSetBtn setTitleColor:kUIColorFromRGB(0x595350) forState:UIControlStateHighlighted];
        [_fontSetBtn setTitleColor:kUIColorFromRGB(0x69BF30) forState:UIControlStateSelected];
        [_fontSetBtn.titleLabel setFont:[UIFont systemFontOfSize:10]];
        
        _fontSetBtn.contentMode = UIViewContentModeScaleAspectFit;
        _fontSetBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _fontSetBtn.tag = 1001;
        [_fontSetBtn addTarget:self action:@selector(changeFontAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fontSetBtn;
}

- (UIView *)fontSetBottomView
{
    if (_fontSetBottomView == nil) {
        _fontSetBottomView = [[YCFontSettingView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.toolbarView.frame), self.frame.size.width, 230)];
        _fontSetBottomView.backgroundColor = [UIColor grayColor];
    }
    return _fontSetBottomView;
}

- (NSMutableArray *)actionItems
{
    if (_actionItems == nil) {
        _actionItems = [[NSMutableArray alloc] init];
    }
    return _actionItems;
}

- (void)setPopKeyboard:(BOOL)popKeyboard{
    _popKeyboard = popKeyboard;
    if (_keyboardBtn) {
        if (self.keyboardBtn.isSelected ^ popKeyboard) {
            self.keyboardBtn.selected = popKeyboard;
            for (YCEditToolbarItem *item in self.actionItems) {
                if (item.button == self.keyboardBtn) {
                    continue;
                }
                item.button.selected = NO;
            }
        }
    }
}

#pragma mark - Action
//改变键盘状态
- (void)changeKeyboardAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    for (YCEditToolbarItem *item in self.actionItems) {
        if (item.button == sender) {
            continue;
        }
        item.button.selected = NO;
    }
    
    if ([_delegate respondsToSelector:@selector(_changeToolbarBottomViewShowHideAction:isShow:)]) {
        [_delegate _changeToolbarBottomViewShowHideAction:sender.tag isShow:sender.selected];
    }
}

//更改字体，颜色，大小
- (void)changeFontAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    YCEditToolbarItem *fontItem = nil;
    for (YCEditToolbarItem *item in self.actionItems) {
        if (item.button == sender) {
            fontItem = item;
            continue;
        }
        item.button.selected = NO;
    }
    
    if ([_delegate respondsToSelector:@selector(_changeToolbarBottomViewShowHideAction:isShow:)]) {
        [_delegate _changeToolbarBottomViewShowHideAction:sender.tag isShow:sender.selected];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (sender.selected) {
            [self _willShowBottomView:fontItem.bottomView];
        }
        else
        {
            [self _willShowBottomView:nil];
        }
    });
}

#pragma mark ------------------- Privacy ----------------------
- (void)_setupSubviews
{
//    [self addSubview:self.backgroundImageView];
    [self addSubview:self.toolbarView];
    
    YCEditToolbarItem *keyboardItem = [[YCEditToolbarItem alloc] initWithButton:self.keyboardBtn withView:nil];
    YCEditToolbarItem *fontSetItem = [[YCEditToolbarItem alloc] initWithButton:self.fontSetBtn withView:self.fontSetBottomView];
    [self setInputViewActionItems:@[keyboardItem, fontSetItem]];
}

- (void)setInputViewActionItems:(NSArray *)inputViewItems
{
    for (YCEditToolbarItem *item in self.actionItems) {
        [item.button removeFromSuperview];
        [item.bottomView removeFromSuperview];
    }
    [self.actionItems removeAllObjects];
    
    NSInteger count = inputViewItems.count;
    CGFloat margin = (self.toolbarView.frame.size.width/count-kItemsWidth)/2.0;
    CGFloat oX = 0;
    CGFloat itemHeight = kItemsWidth;
    for (id item in inputViewItems) {
        if ([item isKindOfClass:[YCEditToolbarItem class]]) {
            YCEditToolbarItem *editItem = (YCEditToolbarItem *)item;
            if (editItem.button) {
                CGRect itemFrame = editItem.button.frame;
                if (itemFrame.size.height == 0) {
                    itemFrame.size.height = itemHeight;
                }
                if (itemFrame.size.height == 0) {
                    itemFrame.size.height = itemHeight;
                }
                
                if (itemFrame.size.width == 0) {
                    itemFrame.size.width = itemFrame.size.height;
                }
                
                oX += margin;
                itemFrame.origin.x = oX;
                itemFrame.origin.y = (self.toolbarView.frame.size.height - itemFrame.size.height)/2;
                editItem.button.frame = itemFrame;
                oX += (itemFrame.size.width+margin);
                [editItem.button YCLayoutButtonWithEdgeInsetsStyle:YCButtonEdgeInsetsStyleTop imageTitleSpace:0];
                [self.toolbarView addSubview:editItem.button];
                [self.actionItems addObject:editItem];
            }
        }
    }
}

- (void)_willShowBottomView:(UIView *)bottomView
{
    if (![self.activityButtomView isEqual:bottomView]) {
        CGFloat bottomHeight = bottomView ? bottomView.frame.size.height : 0;
        [self _willShowBottomHeight:bottomHeight];
        
        if (bottomView) {
            CGRect rect = bottomView.frame;
            rect.origin.y = CGRectGetMaxY(self.toolbarView.frame);
            bottomView.frame = rect;
            [self addSubview:bottomView];
        }
        
        if (self.activityButtomView) {
            [self.activityButtomView removeFromSuperview];
        }
        self.activityButtomView = bottomView;
    }
}

- (void)_willShowBottomHeight:(CGFloat)bottomHeight
{
    CGRect fromFrame = self.frame;
    CGFloat toHeight = self.toolbarView.frame.size.height+bottomHeight;
    CGRect toFrame = CGRectMake(fromFrame.origin.x, fromFrame.origin.y+(fromFrame.size.height-toHeight), fromFrame.size.width, toHeight);
    if (bottomHeight == 0 && self.frame.size.height == self.toolbarView.frame.size.height) {
        return;
    }
    //清除之前视图
    if (self.activityButtomView) {
        [self.activityButtomView removeFromSuperview];
    }
    self.activityButtomView = nil;
    self.frame = toFrame;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didChangeInputHeight:)]) {
        [_delegate didChangeInputHeight:toHeight];
    }
}

#pragma mark ------------------- Public ----------------------
+ (CGFloat)defaultHeight
{
    return kDefaultToolbarHeight;
}

- (void)willShowBottomHeight:(CGFloat)bottomHeight
{
    [self _willShowBottomHeight:bottomHeight];
}


@end

@implementation YCEditToolbarItem
- (instancetype)initWithButton:(UIButton *)button withView:(UIView *)bottomView
{
    self = [super init];
    if (self) {
        _button = button;
        _bottomView = bottomView;
    }
    return self;
}
@end
