//
//  InputBox.m
//  YModel
//
//  Created by apple on 17/10/12.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "InputBox.h"

@implementation InputBox

-(id)initWithMessage:(NSString*)message andTitle:(NSString *)title Window:(NSWindow*)awindown{
    self=[super init];
    if (self) {
        self.strResult=@"NO";
        self.flag=[NSNumber numberWithBool:YES];
        NSAlert* alert;
        alert= [[NSAlert alloc] init];
        [alert setMessageText:message];
        NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
        [input setEditable:YES];
        [input setStringValue:title];
        [alert setAccessoryView:input];
        [[alert window]setInitialFirstResponder:input];
        
        if (![[NSThread currentThread] isMainThread]) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [alert beginSheetModalForWindow:awindown completionHandler:^(NSInteger result) {
                    [input validateEditing];
                    self.strResult=[input stringValue];
                    self.flag=[NSNumber numberWithBool:NO];
                }];
            });
        } else{
            [alert beginSheetModalForWindow:awindown completionHandler:^(NSInteger result) {
                [input validateEditing];
                self.strResult=[input stringValue];
                self.flag=[NSNumber numberWithBool:NO];
            }];
        }
    }
    return self;
}
@end
