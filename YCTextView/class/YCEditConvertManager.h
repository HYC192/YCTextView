//
//  YCEditConvertManager.h
//  YCTextView
//
//  Created by mac on 2018/6/1.
//  Copyright © 2018年 YC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YCEditConvertManager : NSObject
/**
 转换内容，内容拼接

 @param objArr 传入数据
 @return 返回内容
 */
+ (NSString *)_convertObjToContent:(NSArray *)objArr;
/**
 判断是否符合规则，查询对应数据

 @param content 判断文字
 @return 返回结果
 */
+ (BOOL)predicateContentOfImage:(NSString *)content;
/**
 根据规则，转化为对应数组

 @param aInputText 传入内容
 @return 返回数据
 */
+ (NSArray *)convertWithNNRegular:(NSString *)aInputText;
@end
