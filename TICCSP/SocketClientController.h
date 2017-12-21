//
//  SocketClientController.h
//  TICCSP
//
//  Created by apple on 17/11/3.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CocoaAsyncSocket.framework/Headers/GCDAsyncSocket.h"

@interface SocketClientController : NSViewController<GCDAsyncSocketDelegate>{
    GCDAsyncSocket *socket;
}
@property (weak) IBOutlet NSTextField *tfHostIP;
@property (weak) IBOutlet NSTextField *tfPort;
@property (weak) IBOutlet NSButton *buttonOpen;
- (IBAction)actOpen:(id)sender;

@end
