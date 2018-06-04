//
//  YCEditConvertManager.m
//  YCTextView
//
//  Created by mac on 2018/6/1.
//  Copyright © 2018年 YC. All rights reserved.
//

#import "YCEditConvertManager.h"
#import "YCTextView.h"
#import "YCAttachmentView.h"

#define kRegexImage @"\\[img\\][^\\[]*\\[\\/img\\]"  //图片正则
#define kRegexVoice @"\\[voice\\][^\\[]*\\[\\/voice\\]"  //语音正则
#define kRegexVideo @"\\[video\\][^\\[]*\\[\\/video\\]"  //视频正则
@implementation YCEditConvertManager
/**
 转换内容，内容拼接
 */
+ (NSString *)_convertObjToContent:(NSArray *)objArr
{
    __block NSMutableArray *textArr = [[NSMutableArray alloc] init];
    [objArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //解析内容
        NSString *content = @"";
        if ([obj isKindOfClass:[YCTextView class]]) {
            YCTextView *textView = obj;
            content = textView.text;
        }
        
        if ([obj isKindOfClass:[YCAttachmentView class]]) {
            YCAttachmentView *attachView = obj;
            //            content = attachView.content;
            content = @"[img]sefo.jpg[/img]";
        }
        
        [textArr addObject:content];
    }];
    
    NSString *content = @"";
    if (textArr.count > 0) {
        content = [textArr componentsJoinedByString:@""];
    }
    
    return content;
}

+ (BOOL)predicateContentOfImage:(NSString *)content{
    NSString *regex = kRegexImage;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [predicate evaluateWithObject:content];
}

+ (NSArray *)convertWithNNRegular:(NSString *)aInputText{
    NSString *urlPattern = kRegexImage;
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlPattern options:NSRegularExpressionCaseInsensitive error:&error ];
    
    NSArray *matches = [regex matchesInString:aInputText options:NSMatchingReportCompletion range:NSMakeRange(0, [aInputText length])];
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    if (matches.count <= 0) {
        [arr addObject:aInputText];
        return arr;
    }
    
    NSRange getRange = NSMakeRange(0, 0);
    for (NSTextCheckingResult *match in [matches objectEnumerator]) {
        NSRange matchRange = [match range];
        
        NSString *subStr = [aInputText substringWithRange:NSMakeRange(getRange.location+getRange.length, matchRange.location-getRange.location-getRange.length)];
        NSString *attachStr = [aInputText substringWithRange:matchRange];
        
        [arr addObject:subStr];
        [arr addObject:attachStr];
        getRange = matchRange;
    }
    
    if (getRange.location+getRange.length == aInputText.length) {
        [arr addObject:@""];
    }
    
    return arr;
}
@end
