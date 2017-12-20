//
//  SerialPortController.h
//  TICCSP
//
//  Created by apple on 17/11/2.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UartDevice.h"

@interface SerialPortController : NSViewController<NSApplicationDelegate,NSTableViewDelegate,NSTableViewDataSource>{
    int fileSize;
    NSString *devecePath;
    NSMutableArray *array_message;
    UartDevice *aDevice;
}
@property NSMutableArray *array_command;
@property (weak) IBOutlet NSTextField *Label_Info;
@property (weak) IBOutlet NSPopUpButton *pop_serialPort;
@property (weak) IBOutlet NSPopUpButton *pop_parity;
@property (weak) IBOutlet NSButton *button_search;
@property (weak) IBOutlet NSButton *button_open;
- (IBAction)act_search:(id)sender;
- (IBAction)act_open:(id)sender;

- (IBAction)act_serialPort:(id)sender;
- (IBAction)act_parity:(id)sender;


- (IBAction)sendMsg:(id)sender;
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
- (IBAction)isCRC:(id)sender;
@property (weak) IBOutlet NSButton *button_logHex;
- (IBAction)logIsHex:(id)sender;
@property (weak) IBOutlet NSButton *button_timeStamp;
- (IBAction)timeStamp:(id)sender;
- (IBAction)clearUI:(id)sender;
- (IBAction)saveLog:(id)sender;
@property (weak) IBOutlet NSButton *button_endSymbol;
//- (IBAction)endSymbol:(id)sender;
@property (weak) IBOutlet NSTextField *label_BR;
@property (weak) IBOutlet NSTextField *label_PY;


@property (weak) IBOutlet NSButton *button_crc;
@property (weak) IBOutlet NSComboBox *comboBoxBandRate;

@end
