//
//  SocketClientController.h
//  TICCSP
//
//  Created by apple on 17/11/3.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CocoaAsyncSocket.framework/Headers/GCDAsyncSocket.h"

@interface SocketClientController : NSViewController<NSTableViewDelegate,NSTableViewDataSource,GCDAsyncSocketDelegate>{
    int fileSize;
    NSMutableArray *array_message;
    BOOL bRun;
    GCDAsyncSocket *socket;
}

@property (weak) IBOutlet NSTextField *tfHostIP;
@property (weak) IBOutlet NSTextField *tfPort;
@property (weak) IBOutlet NSButton *buttonOpen;
- (IBAction)actOpen:(id)sender;

@property NSMutableArray *array_command;
@property (weak) IBOutlet NSTableView *myTableView;
@property (unsafe_unretained) IBOutlet NSTextView *textView_debug;
- (IBAction)add:(id)sender;
- (IBAction)remove:(id)sender;

@property (weak) IBOutlet NSTextField *label_command;
- (IBAction)sendCommand:(id)sender;

@property (weak) IBOutlet NSButtonCell *button_cell;
@property (weak) IBOutlet NSButtonCell *button_send;
@property (weak) IBOutlet NSButton *button_hex;
- (IBAction)isHex:(id)sender;
- (IBAction)chooseAll:(id)sender;
- (IBAction)chooseNone:(id)sender;
@property (weak) IBOutlet NSTextField *lable_cycletime;
- (IBAction)cycleSend:(id)sender;
@property (weak) IBOutlet NSButton *button_chooseAll;
@property (weak) IBOutlet NSButton *button_chooseNone;
@property (weak) IBOutlet NSTextField *label_endSymbol;

@property (weak) IBOutlet NSButton *button_cycleSend;
//- (IBAction)isCRC:(id)sender;
@property (weak) IBOutlet NSButton *button_logHex;
- (IBAction)logIsHex:(id)sender;
@property (weak) IBOutlet NSButton *button_timeStamp;
- (IBAction)timeStamp:(id)sender;
- (IBAction)clearUI:(id)sender;
- (IBAction)saveLog:(id)sender;
@property (weak) IBOutlet NSButton *button_endSymbol;
- (IBAction)sendMsg:(id)sender;

@property (weak) IBOutlet NSButton *button_crc;

@end
