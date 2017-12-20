//
//  ViewController.h
//  TICCSP
//
//  Created by apple on 17/10/24.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <AppKit/AppKit.h>

@interface ViewController : NSViewController{
    NSRect rectbuttonSerialPort;
    NSRect rectbuttonUpdateBoard;
    NSRect rectbuttonBurninLine;
    NSRect rectbuttonSocketServer;
    NSRect rectbuttonSocketClient;
    NSRect rectbuttonD2XXX;
}

@property (weak) IBOutlet NSButton *buttonSerialPort;
@property (weak) IBOutlet NSButton *buttonUpdateBoard;
@property (weak) IBOutlet NSButton *buttonBurninLine;
@property (weak) IBOutlet NSButton *buttonSocketServer;
@property (weak) IBOutlet NSButton *buttonSocketClient;
@property (weak) IBOutlet NSButton *buttonD2XXX;
@end

