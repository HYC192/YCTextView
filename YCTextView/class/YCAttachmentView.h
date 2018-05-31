//
//  YCAttachmentView.h
//  YCTextView
//
//  Created by mac on 2018/5/28.
//  Copyright © 2018年 YC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YCAttachmentType) {
    YCAttachmentTypeImage = 0,
    YCAttachmentTypeVoice,
    YCAttachmentTypeVideo,
};

@class YCAttachmentView;
@protocol YCAttachmentViewDelegate<NSObject>
@optional
/**
 更新布局

 @param attachView obj
 @param size 尺寸
 */
- (void)updateAttachmentViewConstraints:(YCAttachmentView *)attachView size:(CGSize)size;
/**
 删除控件

 @param obj 视图
 */
- (void)_deleteAttachmentWithObj:(YCAttachmentView *)obj;
@end

@interface YCAttachmentView : UIView
@property (nonatomic, weak) id<YCAttachmentViewDelegate> delegate;
/**
 创建控件

 @param imagePath 图片路径
 @param placeHoldImage 默认占位图
 @param type 创建类型
 */
- (void)YCAttachmentContentWithImage:(id)image
                           imagePath:(id)imagePath
                      placeHoldImage:(UIImage *)placeHoldImage
                      attachmentType:(YCAttachmentType)type;
/**
 传入图片（NSData,Path,Image）
 */
@property (nonatomic, readonly) id imagePath;

/**
 传入图片（Image）
 */
@property (nonatomic, readonly) id image;

/**
 传入内容
 */
@property (nonatomic, readonly) NSString *content;

/**
 类型
 */
@property (nonatomic, readonly) YCAttachmentType type;
@end
