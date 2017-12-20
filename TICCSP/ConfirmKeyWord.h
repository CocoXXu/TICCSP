//
//  ConfirmKeyWord.h
//  TICCSP
//
//  Created by apple on 17/12/12.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ConfirmKeyWord : NSViewController
- (IBAction)ActCancel:(id)sender;
- (IBAction)ActOK:(id)sender;

@property (weak) IBOutlet NSSecureTextField *tKeyWord;

@end
