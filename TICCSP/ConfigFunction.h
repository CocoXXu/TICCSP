//
//  ConfigFunction.h
//  TICCSP
//
//  Created by apple on 17/12/12.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ConfigFunction : NSViewController
- (IBAction)actSetConfig:(id)sender;
@property (weak) IBOutlet NSButton *buttonSerialPort;
@property (weak) IBOutlet NSButton *buttonUpdateBoard;
@property (weak) IBOutlet NSButton *buttonBurninLine;
@property (weak) IBOutlet NSButtonCell *buttonSocketServer;
@property (weak) IBOutlet NSButton *buttonSocketClient;
@property (weak) IBOutlet NSButton *buttonD2XXX;

@end
