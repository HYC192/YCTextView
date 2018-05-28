//
//  YCAttachmentView.m
//  YCTextView
//
//  Created by mac on 2018/5/28.
//  Copyright © 2018年 YC. All rights reserved.
//

#import "YCAttachmentView.h"
#import <Masonry.h>

@interface YCAttachmentView ()
@property (nonatomic, strong) UIImageView *contentImageView;
@end
@implementation YCAttachmentView
#pragma mark - Lifecycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _settingUpSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _settingUpSubviews];
    }
    return self;
}

#pragma mark ------------------- Privacy ----------------------
- (void)_settingUpSubviews
{
    
}

@end
