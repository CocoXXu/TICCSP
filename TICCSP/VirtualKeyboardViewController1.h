//
//  D2XXXViewController.h
//  TICCSP
//
//  Created by apple on 17/11/29.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ftd2xx.h"

@interface VirtualKeyboardViewController : NSViewController{
    FT_HANDLE handle;
}
@property (weak) IBOutlet NSPopUpButton *pop_serialPort;
@property (weak) IBOutlet NSPopUpButton *pop_parity;
@property (weak) IBOutlet NSTextField *textField_filePath;
@property (weak) IBOutlet NSButton *button_search;
@property (weak) IBOutlet NSButton *button_open;
- (IBAction)act_search:(id)sender;
- (IBAction)act_open:(id)sender;
- (IBAction)act_burnin:(id)sender;
- (IBAction)act_serialPort:(id)sender;
- (IBAction)act_bandRate:(id)sender;
- (IBAction)act_parity:(id)sender;
@property (weak) IBOutlet NSTextField *Label_Info;
@property (weak) IBOutlet NSButton *button_burnin;
@property (weak) IBOutlet NSTextField *label_filepath;
@property (weak) IBOutlet NSLevelIndicator *level_progress;
@property (weak) IBOutlet NSComboBox *ComboBox_bandRate;

@property (weak) IBOutlet NSTextField *label_percentage;
@property (weak) IBOutlet NSTextField *label_name;
@property (weak) IBOutlet NSTextField *label_size;


@end
