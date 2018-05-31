//
//  YCAttachmentView.m
//  YCTextView
//
//  Created by mac on 2018/5/28.
//  Copyright © 2018年 YC. All rights reserved.
//

#import "YCAttachmentView.h"
#import <Masonry.h>
#import <libextobjc/EXTScope.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface YCAttachmentView ()
/**
 图片
 */
@property (nonatomic, strong) UIImageView *contentImageView;
/**
 删除控件
 */
@property (nonatomic, strong) UIButton *deleteBtn;
@end
@implementation YCAttachmentView
#pragma mark - Lifecycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

#pragma mark - Custom Accessor
- (UIImageView *)contentImageView{
    if (_contentImageView == nil) {
        _contentImageView = [[UIImageView alloc] init];
        _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView.userInteractionEnabled = YES;
    }
    return _contentImageView;
}

- (UIButton *)deleteBtn{
    if (_deleteBtn == nil) {
        _deleteBtn = [[UIButton alloc] init];
        [_deleteBtn setImage:[UIImage imageNamed:@"icon_letter_edit_delete"] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

#pragma mark - Action
- (void)deleteAction:(id)sender
{
    if ([_delegate respondsToSelector:@selector(_deleteAttachmentWithObj:)]) {
        [_delegate _deleteAttachmentWithObj:self];
    }
}

#pragma mark ------------------- Privacy ----------------------
- (void)YCAttachmentContentWithImage:(id)image
                           imagePath:(id)imagePath
                      placeHoldImage:(UIImage *)placeHoldImage
                      attachmentType:(YCAttachmentType)type
{
    _type = type;
    switch (type) {
        case YCAttachmentTypeImage:
        {
            [self _contentWithImage:image imagePath:imagePath placeHoldImage:placeHoldImage];
        }
            break;
            
        case YCAttachmentTypeVoice:
        {
            
        }
            break;
            
        case YCAttachmentTypeVideo:
        {
            
        }
            break;
            
        default:
            break;
    }
}

- (void)_contentWithImage:(id)originimage imagePath:(id)imagePath placeHoldImage:(UIImage *)placeHoldImage
{
    [self addSubview:self.contentImageView];
    [self addSubview:self.deleteBtn];
    [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(15, 15, 0, 15));
    }];
    
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    if (originimage && [originimage isKindOfClass:[UIImage class]]) {
        switch (self.type) {
            case YCAttachmentTypeImage:
            {
                UIImage *img = originimage;
                _image = originimage;
                self.contentImageView.image = img;
                [self _updateConstraintsWithSize:img.size];
            }
                break;
                
            default:
                break;
        }
        return;
    }
    else
    {
        self.contentImageView.image = placeHoldImage;
        
        if (imagePath) {
            NSURL *imageURL = nil;
            if ([imagePath isKindOfClass:[NSString class]]) {
                imageURL = [NSURL URLWithString:imagePath];
            }
            else if ([imagePath isKindOfClass:[NSURL class]])
            {
                imageURL = imagePath;
            }
            
            switch (self.type) {
                case YCAttachmentTypeImage:
                {
                    @weakify(self);
                    [self.contentImageView sd_setImageWithURL:imageURL
                                             placeholderImage:placeHoldImage
                                                    completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                                        @strongify(self);
                                                        if (image) {
                                                            [self _updateConstraintsWithSize:image.size];
                                                        }
                                                    }];
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
}

//更新布局
- (void)_updateConstraintsWithSize:(CGSize)size
{
    if ([_delegate respondsToSelector:@selector(updateAttachmentViewConstraints:size:)]) {
        [_delegate updateAttachmentViewConstraints:self size:size];
    }
}

@end
