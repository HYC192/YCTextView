//
//  YCEditController.m
//  YCTextView
//
//  Created by mac on 2018/5/29.
//  Copyright © 2018年 YC. All rights reserved.
//

#import "YCEditController.h"
#import "YCTextView.h"
#import "YCAttachmentView.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <libextobjc/EXTScope.h>
#import "YCEditConvertManager.h"

#define kDevice_iPhoneX CGSizeEqualToSize(CGSizeMake(375, 812), [[UIScreen mainScreen] bounds].size)
#define NavHeight (kDevice_iPhoneX?84:64)
#define kIPhoneXNoneHeight (kDevice_iPhoneX?34:0)
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define TexViewDefaultHeight 10
#define TextToImageSpace 6
#define MoreHeight 50
#define InputViewBarHeight 50
#define EditePothoDefHeight 100
#define kPlaceHoldText @"请输入正文"  //textview默认提示文字

@interface YCEditController ()<UITextViewDelegate,NSTextStorageDelegate,UIScrollViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate, YCAttachmentViewDelegate>
/**
 顶部背景视图
 */
@property (nonatomic, strong) UIImageView *topImageView;
/**
 中间视图
 */
@property (nonatomic, strong) UIImageView *centerImageView;
/**
 底部视图
 */
@property (nonatomic, strong) UIImageView *bottomImageView;
/**
 滚动视图
 */
@property (nonatomic, strong) UIScrollView *textScrollView;
/**
 插入控件数组
 */
@property (nonatomic,strong) NSMutableArray *insertObjecArray;
/**
 插入图片数组
 */
@property (nonatomic,strong) NSMutableArray *insertImageArray;
/**
 当前scorller高度
 */
@property (nonatomic,assign) CGFloat currentScrHeight;

/**
 获取保存光标位置
 */
@property (nonatomic, strong) YCTextView *selectionTextView;
/**
 视图间距
 */
@property (nonatomic, assign) UIEdgeInsets edgeMargin;
@end

@implementation YCEditController
#pragma mark - Lifecycle
- (void)dealloc{
    [self removeobserverForKeyBord];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _initData];
    [self _settingUpNavigations];
    [self _settingUpSubviews];
    [self _addKeyBordNotifiy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Accessor
- (UIImageView *)topImageView{
    if (_topImageView == nil) {
        _topImageView = [[UIImageView alloc] init];
        _topImageView.backgroundColor = [UIColor redColor];
    }
    return _topImageView;
}

- (UIImageView *)centerImageView{
    if (_centerImageView == nil) {
        _centerImageView = [[UIImageView alloc] init];
        _centerImageView.backgroundColor = [UIColor orangeColor];
    }
    return _centerImageView;
}

- (UIImageView *)bottomImageView{
    if (_bottomImageView == nil) {
        _bottomImageView = [[UIImageView alloc] init];
        _bottomImageView.backgroundColor = [UIColor greenColor];
    }
    return _bottomImageView;
}

- (UIScrollView *)textScrollView{
    if (!_textScrollView) {
        _textScrollView = [[UIScrollView alloc] init];
        _textScrollView.delegate = self;
    }
    return _textScrollView;
}

- (NSMutableArray *)insertObjecArray
{
    if (_insertObjecArray == nil) {
        _insertObjecArray = [[NSMutableArray alloc] init];
    }
    return _insertObjecArray;
}

- (NSMutableArray *)insertImageArray
{
    if (_insertImageArray == nil) {
        _insertImageArray = [[NSMutableArray alloc] init];
    }
    return _insertImageArray;
}

#pragma mark - Action
- (void)selectPhotoAction:(id)sender
{
    //相册
    UIImagePickerController *pick = [[UIImagePickerController alloc]init];
    pick.delegate = self;
    [self presentViewController:pick animated:YES completion:nil];
}

//键盘显示
- (void)keyboardWillShow:(NSNotification *)aNotification{
    
}

//键盘隐藏
- (void)keyboardWillHide:(NSNotification *)aNotification{
    
}

//键盘高度变化
- (void)keyBoardWillChageFrame:(NSNotification *)notification{
    NSDictionary * infoDict = [notification userInfo];
    CGFloat duration = [[infoDict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect endFrame = [[infoDict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [[infoDict objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect newFrame = self.inputView.frame;
    
    CGFloat offset_y = endFrame.origin.y - beginFrame.origin.y;
    
    //获取当前的inputview的高
    CGFloat height = CGRectGetHeight(self.inputView.frame);
    CGFloat endHeight = kScreenHeight-NavHeight;
    
//    height = height > InputViewBarHeight ? height : InputViewBarHeight;
    height = 0;
    
    if (offset_y<0) {
        if (endFrame.origin.y < endHeight) {
            newFrame.origin.y = endHeight - endFrame.size.height-height;
        }
        else
        {//避免一些 键盘在屏幕下方浮动的现象
            newFrame.origin.y = endHeight - height;
        }
    }
    else
    {//键盘下移或消失
        if (endFrame.origin.y >= endHeight) {//键盘完全消失
            newFrame.origin.y = endHeight - height;
        }
        else
        {//键盘只是变矮了一点
            newFrame.origin.y = endHeight - endFrame.size.height - height;
        }
    }
    CGRect frame = CGRectMake(0, newFrame.origin.y, kScreenWidth, height);
    [self changeFrameAnimation:duration newFrame:frame oldFrame:self.inputView.frame];
}

#pragma mark ------------------- Privacy ----------------------
- (void)_initData
{
    _edgeMargin = UIEdgeInsetsMake(0, 15, 0, 15);
    _currentScrHeight = 0;
}

- (void)_addKeyBordNotifiy {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)removeobserverForKeyBord{
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
}

- (void)_settingUpNavigations
{
    self.title = @"图文混排";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    [btn setTitle:@"添加图片" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn addTarget:self action:@selector(selectPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)_settingUpSubviews
{
    [self.view addSubview:self.centerImageView];
    [self.view addSubview:self.topImageView];
    [self.view addSubview:self.textScrollView];
    [self.view addSubview:self.bottomImageView];
    
    if (@available(iOS 11.0, *)) {
        self.textScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    @weakify(self);
    [self.centerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.centerImageView.mas_top);
        make.left.equalTo(self.centerImageView.mas_left);
        make.right.equalTo(self.centerImageView.mas_right);
        make.height.mas_equalTo(50);
    }];
    
    [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.centerImageView.mas_bottom);
        make.left.equalTo(self.centerImageView.mas_left);
        make.right.equalTo(self.centerImageView.mas_right);
        make.height.mas_equalTo(50);
    }];
    
    [self.textScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.topImageView.mas_bottom);
        make.left.equalTo(self.centerImageView.mas_left);
        make.right.equalTo(self.centerImageView.mas_right);
        make.bottom.equalTo(self.bottomImageView.mas_top);
//        make.height.mas_equalTo(kScreenHeight-NavHeight-kIPhoneXNoneHeight);
    }];
    
    if (self.messageContent && self.messageContent.length > 0) {
        [self _convertContentToObject:self.messageContent];
    }
    else
    {
        [self creatTextViewWithObject:self.textScrollView index:0 text:nil type:YCEditObjTypeScrollerView];
    }
    [self.view addSubview:self.inputView];
}

/**
 创建文本控件
 
 @param object 参照对象
 @param index 插入位置
 @param text 文本
 @param type 类型
 @return GADetialTextView
 */
- (YCTextView *)creatTextViewWithObject:(id)object
                                  index:(NSInteger)index
                                   text:(NSString *)text
                                   type:(YCEditObjType)type
{
    YCTextView *textView = [[YCTextView alloc] init];
    [self.insertObjecArray insertObject:textView atIndex:index];
    
    textView.text = text;
    textView.font = [UIFont systemFontOfSize:17.0];
    textView.textColor = [UIColor blackColor];
    CGFloat height = [textView sizeThatFits:CGSizeMake(kScreenWidth, CGFLOAT_MAX)].height;
    if (!height) {
        height = TexViewDefaultHeight;
    }
    textView.delegate = self;
    textView.dataDetectorTypes = UIDataDetectorTypeLink;
    [textView setAutocorrectionType:UITextAutocorrectionTypeNo];
    [textView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    //[textView becomeFirstResponder];
    [self.textScrollView addSubview:textView];
    UIView *viewObject = nil;
    UITextView *textViewObject = nil;
    UIScrollView *scrollerObject = nil;
    
    switch (type) {
        case YCEditObjTypeView:{
            viewObject = (UIView *)object;
            [textView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(viewObject.mas_bottom).offset(TextToImageSpace);
                make.height.mas_equalTo(height);
                make.centerX.equalTo(self.textScrollView);
                make.width.mas_equalTo(kScreenWidth-self.edgeMargin.left-self.edgeMargin.right);
            }];
        }
            break;
        case YCEditObjTypeScrollerView:{
            scrollerObject = (UIScrollView *)object;
            [textView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(scrollerObject.mas_top).offset(TextToImageSpace);
                make.height.mas_equalTo(height);
                make.centerX.equalTo(scrollerObject);
                make.width.mas_equalTo(kScreenWidth-self.edgeMargin.left-self.edgeMargin.right);
            }];
        }
            break;
        case YCEditObjTypeTextView:{
            textViewObject = (UITextView *)object;
            [textView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(textViewObject.mas_bottom).offset(TextToImageSpace);
                make.height.mas_equalTo(height);
                make.centerX.equalTo(self.textScrollView);
                make.width.mas_equalTo(kScreenWidth-self.edgeMargin.left-self.edgeMargin.right);
            }];
        }
            break;
        default:
            break;
    }
    
    NSString *str = [NSString stringWithFormat:@"%ld", index];
    NSDictionary *dic = @{@"index":str};
    [self performSelector:@selector(gettingFrame:) withObject:dic afterDelay:0.5];
    return textView;
    
}

/**
 创建其它控件
 
 @param object 参照对象
 @param model 模型
 @param image 图片
 @param type 类型
 @return GAEditPhoto
 */
- (YCAttachmentView *)
creatPhotoViewWithObject:(id)object
                                         index:(NSInteger)index
                                         model:(id)model
                                         image:(UIImage *)image
                                          type:(YCEditObjType)type
{
    YCAttachmentView *attachView = [[YCAttachmentView alloc]init];
    attachView.delegate = self;
    
    [self.insertObjecArray insertObject:attachView atIndex:index];
    [self.textScrollView addSubview:attachView];
    CGFloat height = EditePothoDefHeight;
    UIView *viewObject = nil;
    UITextView *textViewObject = nil;
    UIScrollView *scrollerObject = nil;
    @weakify(self);
    switch (type) {
        case YCEditObjTypeView:{
            viewObject = (UIView *)object;
            [attachView mas_makeConstraints:^(MASConstraintMaker *make) {
                @strongify(self);
                make.top.equalTo(viewObject.mas_bottom).offset(TextToImageSpace);
                make.height.mas_equalTo(height);
                make.centerX.equalTo(self.textScrollView);
                make.width.mas_equalTo(kScreenWidth);
            }];
        }
            break;
        case YCEditObjTypeScrollerView:{
            scrollerObject = (UIScrollView *)object;
            [attachView mas_makeConstraints:^(MASConstraintMaker *make) {
                @strongify(self);
                make.top.equalTo(scrollerObject.mas_top).offset(TextToImageSpace);
                make.height.mas_equalTo(height);
                make.centerX.equalTo(self.textScrollView);
                make.width.mas_equalTo(kScreenWidth);
            }];
            
        }
            break;
        case YCEditObjTypeTextView:{
            textViewObject = (UITextView *)object;
            [attachView mas_makeConstraints:^(MASConstraintMaker *make) {
                @strongify(self);
                make.top.equalTo(textViewObject.mas_bottom).offset(TextToImageSpace);
                make.height.mas_equalTo(height);
                make.centerX.equalTo(self.textScrollView);
                make.width.mas_equalTo(kScreenWidth);
            }];
            
        }
            break;
        default:
            break;
    }
    
//    [attachView.deleButton addTarget:self action:@selector(deletePhoto:) forControlEvents:UIControlEventTouchUpInside];
    if (image) {
        [attachView YCAttachmentContentWithImage:image imagePath:nil placeHoldImage:nil attachmentType:YCAttachmentTypeImage];
        [self.insertImageArray addObject:image];
//        [showPhoto addingDeleButton];
//        showPhoto.deleButton.tag = _deleTag;
//        _deleTag++;
    }
    
    return attachView;
}

- (void)gettingFrame:(id)data{
    [self _updateScrollerViewContentSize];
    CGFloat height = 0;
    
    NSInteger index = 0;
    if ([data isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = data;
        index = [dic[@"index"] integerValue];
    }
    
    if (index < self.insertObjecArray.count) {
        id obj = self.insertObjecArray[index];
        if ([obj isKindOfClass:[YCTextView class]]) {
            YCTextView *textView = obj;
            height = textView.frame.origin.y + textView.frame.size.height;
            [self _changeRectToVisibleWithHeight:height];
        }
        else if ([obj isKindOfClass:[YCAttachmentView class]]) {
            YCAttachmentView *attachView = obj;
            height = attachView.frame.origin.y + attachView.frame.size.height;
            [self _changeRectToVisibleWithHeight:height];
        }
        
    }
    
}

//更新整体布局
- (void)_updateScrollerViewContentSize
{
    CGFloat nowHeight = MoreHeight;
    
    if (self.insertObjecArray.count > 0) {
        id obj = [self.insertObjecArray lastObject];
        if ([obj isKindOfClass:[YCAttachmentView class]]) {
            YCAttachmentView *attachView = obj;
            nowHeight += CGRectGetMaxY(attachView.frame);
        }
        else if ([obj isKindOfClass:[YCTextView class]])
        {
            YCTextView *textView = obj;
            nowHeight += CGRectGetMaxY(textView.frame);
        }
        
        //是否显示默认文字提示
        id firstObj = [self.insertObjecArray firstObject];
        if ([firstObj isKindOfClass:[YCTextView class]]) {
            YCTextView *textView = firstObj;
            if (self.insertObjecArray.count == 1) {
                
                textView.placeHolder = kPlaceHoldText;
            }
            else
            {
                textView.placeHolder = @"";
            }
        }
        
    }
    
    self.textScrollView.contentSize = CGSizeMake(kScreenWidth, nowHeight);
}

- (void)_changeRectToVisibleWithHeight:(CGFloat)height
{
    if (height > self.currentScrHeight) {
        _currentScrHeight = height;
        [self.textScrollView scrollRectToVisible:CGRectMake(0, 0, kScreenWidth, height) animated:YES];
    }
}

- (void)changeFrameAnimation:(CGFloat)duration
                    newFrame:(CGRect)newFrame
                    oldFrame:(CGRect)oldFrame
{
    @weakify(self);
    CGRect frame = self.centerImageView.frame;
    frame.size.height = newFrame.origin.y;
    [UIView animateWithDuration:duration animations:^{
        @strongify(self);
        self.inputView.frame = newFrame;
        [self.centerImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
//            make.bottom.equalTo(self.bottomImageView.mas_top);
//            make.top.left.right.mas_equalTo(0);
            make.height.mas_equalTo(CGRectGetHeight(frame));
        }];
        self.centerImageView.frame = frame;
    }];
}

/**
 插入图片

 @param image 图片
 @param model 模型
 */
- (void)insertNewImageWithImage:(UIImage *)image model:(id)model
{
    //  插入图片
    YCTextView *textView = nil;
    if (self.insertObjecArray.count > 0) {
        if (self.selectionTextView) {
            
            for (NSInteger i = 0; i < self.insertObjecArray.count; i++)
            {
                id obj = self.insertObjecArray[i];
                if ([obj isKindOfClass:[YCTextView class]]) {
                    textView = (YCTextView *)obj;
                    if (self.selectionTextView == textView) {
                        NSRange range = self.selectionTextView.selectedRange;
                        NSString *text = [self.selectionTextView.text substringWithRange:NSMakeRange(0, range.location)];
                        NSString *nextText = [self.selectionTextView.text substringWithRange:NSMakeRange(range.location, self.selectionTextView.text.length-range.location)];
                        
                        YCAttachmentView *newPhoto = [self creatPhotoViewWithObject:textView index:i+1 model:model image:image type:YCEditObjTypeTextView];
                        YCTextView *nextTextView = [self creatTextViewWithObject:newPhoto index:i+2 text:nextText type:YCEditObjTypeView];
                        
                        [self _remakeObjectOfIndex:i+3 type:YCEditObjTypeTextView];
                        
                        self.selectionTextView.text = text;
                        self.selectionTextView = nextTextView;
                        self.selectionTextView.selectedRange = NSMakeRange(0, 0);
                        break;
                    }
                }
            }
        }
        else
        {
            NSInteger currentIndex = self.insertObjecArray.count-1;
            textView =(YCTextView *)[self.insertObjecArray lastObject];
            YCAttachmentView *newPhoto = [self creatPhotoViewWithObject:textView index:currentIndex+1 model:model image:image type:YCEditObjTypeTextView];
            YCTextView *nextTextView = [self creatTextViewWithObject:newPhoto index:currentIndex+2 text:@"" type:YCEditObjTypeView];
            self.selectionTextView = nextTextView;
            self.selectionTextView.selectedRange = NSMakeRange(0, 0);
        }
    }
    else
    {
        textView = [self creatTextViewWithObject:self.textScrollView index:0 text:@"" type:YCEditObjTypeScrollerView];
        YCAttachmentView *newPhoto = [self creatPhotoViewWithObject:textView index:1 model:model image:image type:YCEditObjTypeTextView];
        YCTextView *nextTextView = [self creatTextViewWithObject:newPhoto index:2 text:@"" type:YCEditObjTypeView];
        self.selectionTextView = nextTextView;
        self.selectionTextView.selectedRange = NSMakeRange(0, 0);
    }
    
    //转换内容、保存数据
    [self _getTextViewData];
}

/************
 >>> 删除控件 （连同下面的textview）:
 1、获取当前控件，位置
 2、根据当前控件位置，判断上个控件是否为Textview，
     a、如果为textview，则判断控件链接的textview带的文本，赋值给这个textview
     b、如果为控件，则不删除链接的textview
 3、布局删除掉的相关控件下一个控件，自由度顶部设为这个textview的底部
*********/
- (void)_deleteAttachViewWithObject:(YCAttachmentView *)object
{
    if (self.insertObjecArray.count > 0) {
        NSInteger index = [self.insertObjecArray indexOfObject:object];
        
        if (index - 1 < 0) {//没有上一层视图
            
        }
        else
        {
            id obj = [self.insertObjecArray objectAtIndex:index-1];
            
            if ([obj isKindOfClass:[YCTextView class]]) {
                YCTextView *topTextView = obj;
                if (index+1 < self.insertObjecArray.count) {
                    id deletObj = [self.insertObjecArray objectAtIndex:index+1];
                    if ([deletObj isKindOfClass:[YCTextView class]]) {
                        YCTextView *deleteTextView = deletObj;
                        NSString *firstStr = topTextView.text;
                        NSString *deleteStr = deleteTextView.text;
                        
                        NSString *text = @"";
                        
                        if (firstStr.length > 0) {
                            if (![firstStr hasSuffix:@"\n"])
                            {
                                firstStr = [firstStr stringByAppendingString:@"\n"];
                            }
                            text = [firstStr stringByAppendingString:deleteStr];
                        }
                        else
                        {
                            text = deleteStr;
                        }
                        
                        topTextView.text = text;
                        [self _updateTextViewContentSize:topTextView];
                        
                        //数据处理
                        [self.insertObjecArray removeObject:object];
                        [self.insertImageArray removeObject:object.image];
                        [self.insertObjecArray removeObject:deletObj];
                        
                        [self _remakeObjectOfIndex:index type:YCEditObjTypeTextView];
                        //移除控件
                        [deletObj removeFromSuperview];
                        [object removeFromSuperview];
                        
                        //更新布局
                        [self _updateScrollerViewContentSize];
                    }
                }
            }
        }
    }
}

//更新textView 布局
- (void)_updateTextViewContentSize:(UITextView *)textView
{
    CGFloat height = [textView sizeThatFits:CGSizeMake(kScreenWidth-self.edgeMargin.left-self.edgeMargin.right, CGFLOAT_MAX)].height;
    //更新当前textview的高
    [textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
}

//重新布局指定控件
- (void)_remakeObjectOfIndex:(NSInteger)index type:(YCEditObjType)type
{
    if (index < self.insertObjecArray.count) {
        id obj = [self.insertObjecArray objectAtIndex:index];
        
        id forwardObj = nil;
        if (index < 1) {
            type = YCEditObjTypeScrollerView;
            forwardObj = self.textScrollView;
        }
        else
        {
            forwardObj = [self.insertObjecArray objectAtIndex:index-1];
        }
        
        UIView *viewObj = nil;
        UIScrollView *scrObj = nil;
        UITextView *textViewObj = nil;
        if ([obj isKindOfClass:[YCAttachmentView class]]) {
            YCAttachmentView *attachView = obj;
            CGFloat height = CGRectGetHeight(attachView.frame);
            @weakify(self);
            switch (type) {
                case YCEditObjTypeView:
                {
                    viewObj = (UIView *)forwardObj;
                    [attachView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        @strongify(self);
                        make.top.equalTo(viewObj.mas_bottom).offset(TextToImageSpace);
                        make.height.mas_equalTo(height);
                        make.centerX.equalTo(self.textScrollView);
                        make.width.mas_equalTo(kScreenWidth);
                    }];
                }
                    break;
                   
                case YCEditObjTypeScrollerView:{
                    scrObj = (UIScrollView *)forwardObj;
                    [attachView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(scrObj.mas_top).offset(TextToImageSpace);
                        make.height.mas_equalTo(height);
                        make.centerX.equalTo(scrObj);
                        make.width.mas_equalTo(kScreenWidth);
                    }];
                }
                    break;
                case YCEditObjTypeTextView:{
                    textViewObj = (UITextView *)forwardObj;
                    [attachView mas_remakeConstraints:^(MASConstraintMaker *make) {
                       @strongify(self);
                        make.top.equalTo(textViewObj.mas_bottom).offset(TextToImageSpace);
                        make.height.mas_equalTo(height);
                        make.centerX.equalTo(self.textScrollView);
                        make.width.mas_equalTo(kScreenWidth);
                    }];
                }
                    break;
                    
                default:
                    break;
            }
        }
        else if ([obj isKindOfClass:[YCTextView class]]) {
            YCTextView *textView = obj;
            CGFloat height = CGRectGetHeight(textView.frame);
            @weakify(self);
            switch (type) {
                case YCEditObjTypeView:
                {
                    viewObj = (UIView *)forwardObj;
                    [textView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        @strongify(self);
                        make.top.equalTo(viewObj.mas_bottom).offset(TextToImageSpace);
                        make.height.mas_equalTo(height);
                        make.centerX.equalTo(self.textScrollView);
                        make.width.mas_equalTo(kScreenWidth-self.edgeMargin.left-self.edgeMargin.right);
                    }];
                }
                    break;
                    
                case YCEditObjTypeScrollerView:{
                    scrObj = (UIScrollView *)forwardObj;
                    [textView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(scrObj.mas_top).offset(TextToImageSpace);
                        make.height.mas_equalTo(height);
                        make.centerX.equalTo(scrObj);
                        make.width.mas_equalTo(kScreenWidth-self.edgeMargin.left-self.edgeMargin.right);
                    }];
                }
                    break;
                case YCEditObjTypeTextView:{
                    textViewObj = (UITextView *)forwardObj;
                    [textView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        @strongify(self);
                        make.top.equalTo(textViewObj.mas_bottom).offset(TextToImageSpace);
                        make.height.mas_equalTo(height);
                        make.centerX.equalTo(self.textScrollView);
                        make.width.mas_equalTo(kScreenWidth-self.edgeMargin.left-self.edgeMargin.right);
                    }];
                }
                    break;
                    
                default:
                    break;
            }
            
            [self _updateScrollerViewContentSize];
        }
    }
}

- (void)_getTextViewData
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_changOrSaveContent) object:nil];
    [self performSelector:@selector(_changOrSaveContent) withObject:nil afterDelay:2];
}

- (void)_changOrSaveContent
{
    self.messageContent = [YCEditConvertManager _convertObjToContent:self.insertObjecArray];
}

/**
 将内容解析，转化为视图

 @param content 解析内容
 */
- (void)_convertContentToObject:(NSString *)content
{
    [self.insertObjecArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    [self.insertObjecArray removeAllObjects];
    
    //获取内容数组
    NSArray *contentArr = [YCEditConvertManager convertWithNNRegular:content];
    
    id obj = self.textScrollView;
    YCEditObjType type = YCEditObjTypeScrollerView;
    for (NSInteger i = 0; i < contentArr.count; i++) {
        NSString *text = contentArr[i];
        
        if (content.length > 0) {
            if ([YCEditConvertManager predicateContentOfImage:text]) {
                UIImage *image = [UIImage imageNamed:@"images_01.jpg"];
                YCAttachmentView *newPhoto = [self creatPhotoViewWithObject:obj index:i model:nil image:image type:type];
                obj = newPhoto;
                type = YCEditObjTypeView;
            }
            else
            {
                YCTextView *nextTextView = [self creatTextViewWithObject:obj index:i text:text type:type];
                obj = nextTextView;
                type = YCEditObjTypeTextView;
            }
        }
        else
        {
            YCTextView *nextTextView = [self creatTextViewWithObject:obj index:i text:text type:type];
            obj = nextTextView;
            type = YCEditObjTypeTextView;
        }
    }
}

/**
 * 是否自动旋转
 */
- (BOOL)shouldAutorotate {
    return NO; //暂时只支持默认的竖屏
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - YCAttachmentViewDelegate
- (void)updateAttachmentViewConstraints:(YCAttachmentView *)attachView size:(CGSize)size{
    CGFloat height = kScreenWidth*size.height/size.width-15;
    if (height < EditePothoDefHeight) {
        height = EditePothoDefHeight;
    }
    [attachView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
}

- (void)_deleteAttachmentWithObj:(YCAttachmentView *)obj{
    [self _deleteAttachViewWithObject:obj];
}

#pragma mark---UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    self.selectionTextView = (YCTextView *)textView;
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    //处理删除事件,判断是否有图片，对删除图片做处理
    if ([text isEqualToString:@""] && range.location == 0 && range.length == 0) {
        NSInteger index = [self.insertObjecArray indexOfObject:(YCTextView *)textView];
        if (index - 1 >= 0) {
            id obj = [self.insertObjecArray objectAtIndex:index-1];
            if ([obj isKindOfClass:[YCAttachmentView class]]) {
                [self _deleteAttachViewWithObject:obj];
            }
        }
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    //改变textview的height
    [self _updateTextViewContentSize:textView];
    //更新整体Scrollview布局
    [self _updateScrollerViewContentSize];
    
    //转换内容、保存数据
    [self _getTextViewData];
}

//获取光标位置
- (void)textViewDidChangeSelection:(UITextView *)textView{
    self.selectionTextView = (YCTextView *)textView;
}

#pragma mark--UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    //适配屏幕宽度
//    NSInteger width = kScreenWidth - 20;
//    UIImage *image1 = [image scaleToSize:CGSizeMake(width, image.size.height*width/image.size.width)];
    [self insertNewImageWithImage:image model:nil];
    [self dismissViewControllerAnimated:picker completion:nil];
}

#pragma mark - UIScrollerViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    [scrollView endEditing:YES];
}

@end
