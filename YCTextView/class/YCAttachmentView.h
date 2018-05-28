//
//  YCAttachmentView.h
//  YCTextView
//
//  Created by mac on 2018/5/28.
//  Copyright © 2018年 YC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YCAttachmentView : UIView
/**
 传入图片（NSData,Path,Image）
 */
@property (nonatomic, strong) id image;
/**
 链接路径
 */
@property (nonatomic, strong) NSString *url;
@end
