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

#define kDevice_iPhoneX CGSizeEqualToSize(CGSizeMake(375, 812), [[UIScreen mainScreen] bounds].size)
#define NavHeight (kDevice_iPhoneX?84:64)
#define kIPhoneXNoneHeight (kDevice_iPhoneX?34:0)
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define TexViewDefaultHeight 10
#define TextToImageSpace 6
#define MoreHeight 80
#define InputViewBarHeight 50
#define EditePothoDefHeight 100
@interface YCEditController ()<UITextViewDelegate,NSTextStorageDelegate,UIScrollViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate, YCAttachmentViewDelegate>
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
 是否在编辑器文字
 */
@property (nonatomic, getter=isEditTextView) BOOL editeTextView;
/**
 当前scorller高度
 */
@property (nonatomic,assign) CGFloat currentScrHeight;
@end

@implementation YCEditController
#pragma mark - Lifecycle
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
- (UIScrollView *)textScrollView{
    if (!_textScrollView) {
        _textScrollView = [[UIScrollView alloc]init];
        _textScrollView.backgroundColor = [UIColor whiteColor];
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
    
    height = height > InputViewBarHeight ? height : InputViewBarHeight;
    
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
    _editeTextView = NO;
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
    [self.view addSubview:self.textScrollView];
    if (@available(iOS 11.0, *)) {
        self.textScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.textScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(kScreenHeight-NavHeight-kIPhoneXNoneHeight);
    }];
    
    YCTextView *defaultTextView = [self creatTxetViewWithObject:self.textScrollView text:nil type:YCEditObjTypeScrollerView];
    defaultTextView.placeHolder = @"请输入文字";
    [self.view addSubview:self.inputView];
}

/**
 创建文本控件
 
 @param object 参照对象
 @param text 文本
 @param type 类型
 @return GADetialTextView
 */
- (YCTextView *)creatTxetViewWithObject:(id)object
                                   text:(NSString *)text
                                   type:(YCEditObjType)type
{
    YCTextView *textView = [[YCTextView alloc] init];
    [self.insertObjecArray addObject:textView];
    
    textView.text = text;
    textView.font = [UIFont systemFontOfSize:17.0];
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
                make.width.mas_equalTo(kScreenWidth);
            }];
        }
            break;
        case YCEditObjTypeScrollerView:{
            scrollerObject = (UIScrollView *)object;
            [textView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(scrollerObject.mas_top).offset(TextToImageSpace);
                make.height.mas_equalTo(height);
                make.centerX.equalTo(scrollerObject);
                make.width.mas_equalTo(kScreenWidth);
            }];
        }
            break;
        case YCEditObjTypeTextView:{
            textViewObject = (UITextView *)object;
            [textView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    [self performSelector:@selector(gettingFrame) withObject:nil afterDelay:0.5];
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
- (YCAttachmentView *)creatPhotoViewWithObject:(id)object
                                    model:(id)model
                                    image:(UIImage *)image
                                     type:(YCEditObjType)type
{
//    NSString *url = model.src;
    YCAttachmentView *attachView = [[YCAttachmentView alloc]init];
    attachView.delegate = self;
    [self.insertObjecArray addObject:attachView];
//    self.objectType =  ObjectofUIview;
    [self.textScrollView addSubview:attachView];
//    CGFloat imageMinHeight = 50;
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

//更新某个对象下面的所有布局
- (void)upadteSubViewLayoutWithObject:(id)object{
    if (self.insertObjecArray.count > 0) {
        CGFloat indext = [self.insertObjecArray indexOfObject:object];
        NSInteger leftCount = self.insertObjecArray.count - indext -1;
        if (leftCount > 0) {
            for (NSInteger i = 0; i < leftCount; i++) {
                if ([[self.insertObjecArray objectAtIndex:i] isKindOfClass:[YCAttachmentView class]]) {
                    YCAttachmentView *attachView =(YCAttachmentView *)[self.insertObjecArray objectAtIndex:i];
                    [attachView mas_updateConstraints:^(MASConstraintMaker *make) {
                        
                    }];
                }
                else
                {
                    YCTextView *textView =(YCTextView *)[self.insertObjecArray objectAtIndex:i];
                    
                    [textView mas_updateConstraints:^(MASConstraintMaker *make) {
                    }];
                }
            }
        }
        //设置scrollercontensize
        [self getInserObjectLastObjectToChangeContensize];
    }
}

- (void)getInserObjectLastObjectToChangeContensize{
    //得到容器中最后一个视图
    if ([[self.insertObjecArray lastObject] isKindOfClass:[YCAttachmentView class]]) {
        YCAttachmentView *attachView =(YCAttachmentView *)[self.insertObjecArray lastObject];
        CGFloat height = attachView.frame.origin.y + attachView.frame.size.height;
        [self changeTextStrollerContentSizeWithHeight:height];
    }
    else
    {
        YCTextView *textView =(YCTextView *)[self.insertObjecArray lastObject];
        if (textView) {
            CGFloat height = textView.frame.origin.y + textView.frame.size.height;
            [self changeTextStrollerContentSizeWithHeight:height];
        }
        
    }
    
}

- (void)gettingFrame{
    CGFloat height = 0;
    _editeTextView = NO;
    for ( int i  = 0 ; i < self.insertObjecArray.count; i++) {
        if ([[self.insertObjecArray objectAtIndex:i] isKindOfClass:[YCAttachmentView class]]) {
            YCAttachmentView *attachmentView =(YCAttachmentView *)[self.insertObjecArray objectAtIndex:i];
            height = attachmentView.frame.origin.y + attachmentView.frame.size.height;
            [self changeTextStrollerContentSizeWithHeight:height];
        }
        else
        {
            YCTextView *textView =(YCTextView *)[self.insertObjecArray objectAtIndex:i];
            height = textView.frame.origin.y + textView.frame.size.height;
            [self changeTextStrollerContentSizeWithHeight:height];
        }
    }
    
}

//动态改变srollerconsize
- (void)changeTextStrollerContentSizeWithHeight:(CGFloat)height{
    CGFloat nowHeight = height+MoreHeight;
    self.textScrollView.contentSize = CGSizeMake(kScreenWidth, nowHeight);
    if ((nowHeight > self.currentScrHeight)) {
        if (!self.isEditTextView) {
            _currentScrHeight = nowHeight;
            [self.textScrollView scrollRectToVisible:CGRectMake(0, 0, kScreenWidth, nowHeight) animated:YES];
            _editeTextView = NO;
        }
    }
    
    
}

- (void)changeFrameAnimation:(CGFloat)duration
                    newFrame:(CGRect)newFrame
                    oldFrame:(CGRect)oldFrame
{
    @weakify(self);
    CGRect frame = self.textScrollView.frame;
    frame.size.height = newFrame.origin.y;
    [UIView animateWithDuration:duration animations:^{
        @strongify(self);
        self.inputView.frame = newFrame;
        [self.textScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.height.mas_equalTo(CGRectGetHeight(frame));
        }];
        self.textScrollView.frame = frame;
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
        textView =(YCTextView *)[self.insertObjecArray lastObject];
        YCAttachmentView *newPhoto = [self creatPhotoViewWithObject:textView model:nil image:image type:YCEditObjTypeView];
        [self creatTxetViewWithObject:newPhoto text:@"" type:YCEditObjTypeView];
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

#pragma mark---UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    YCTextView *lastTextView = (YCTextView *)[self.insertObjecArray lastObject];
    if (lastTextView == textView) {
        _editeTextView = NO;
    }else{
        _editeTextView = YES;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    //改变textview的height
    CGFloat height = [textView sizeThatFits:CGSizeMake(kScreenWidth, CGFLOAT_MAX)].height;
    //更新当前textview的高
    [textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    if (self.insertObjecArray.count > 0) {
        if (textView.text.length > 0) {
            [self upadteSubViewLayoutWithObject:textView];
        }
        //设置scrollercontensize
        [self getInserObjectLastObjectToChangeContensize];
    }
    
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
