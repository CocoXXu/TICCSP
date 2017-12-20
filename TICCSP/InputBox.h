//
//  InputBox.h
//  YModel
//
//  Created by apple on 17/10/12.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface InputBox : NSObject

@property NSNumber* flag;
@property NSString* strResult;
/**
 输入框，用于弹出问题并输入结果
 @param -->message describe the question
 @param -->title the title of alert
 @param -->awindown show alert in awindown
 */
-(id)initWithMessage:(NSString*)message andTitle:(NSString *)title Window:(NSWindow*)awindown;

@end
