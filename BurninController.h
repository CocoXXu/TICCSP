//
//  BurninController.h
//  TICCSP
//
//  Created by apple on 17/11/2.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BurninController : NSViewController<NSWindowDelegate>
@property (weak) IBOutlet NSPopUpButton *PopUp_FTDI;

@property (weak) IBOutlet NSTextField *label_description;
@property (weak) IBOutlet NSTextField *label_serialnum;
@property (weak) IBOutlet NSTextField *label_PID;
@property (weak) IBOutlet NSTextField *label_VID;
@property (weak) IBOutlet NSTextField *label_MI;
- (IBAction)fixDesc:(id)sender;
- (IBAction)fixSerialNum:(id)sender;
- (IBAction)getInfo:(id)sender;
- (IBAction)select_serial:(id)sender;
@end
