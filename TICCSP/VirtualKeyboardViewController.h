//
//  VirtualKeyboardViewController.h
//  TICCSP
//
//  Created by apple on 18/1/16.
//  Copyright © 2018年 coco. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UartDevice.h"

@interface VirtualKeyboardViewController : NSViewController<NSTableViewDelegate,NSTableViewDataSource>{
    NSStatusItem *statusItem;
    id globalmouseEvent;
    id loacalmouseEvent;
    NSMutableArray *maVirsualConfig;
    UartDevice *aDevice;
    NSString *devecePath;
}
@property (weak) IBOutlet NSButton *buttonMeasureLocation;
- (IBAction)ActMeasure:(id)sender;

@property (weak) IBOutlet NSTableView *mytableView;
@property (weak) IBOutlet NSPopUpButton *pop_serialPort;
@property (weak) IBOutlet NSPopUpButton *pop_parity;
@property (weak) IBOutlet NSComboBox *comboBoxBandRate;
@property (weak) IBOutlet NSButton *button_search;
@property (weak) IBOutlet NSButton *button_open;
- (IBAction)act_search:(id)sender;
- (IBAction)act_open:(id)sender;
- (IBAction)act_add:(id)sender;
- (IBAction)act_remove:(id)sender;
- (IBAction)act_save:(id)sender;

@end
