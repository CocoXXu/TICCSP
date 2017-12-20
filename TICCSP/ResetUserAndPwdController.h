//
//  ResetUserAndPwd.h
//  TICCSP
//
//  Created by apple on 17/11/3.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ResetUserAndPwdController : NSViewController<NSTextFieldDelegate,NSWindowDelegate>{
    NSString *flagValue;
}
@property (weak) IBOutlet NSTextField *TF_userName;
@property (weak) IBOutlet NSTextField *TF_passWord;
- (IBAction)Act_commit:(id)sender;

@end
