//
//  SocketClientController.m
//  TICCSP
//
//  Created by apple on 17/11/3.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "SocketClientController.h"

@interface SocketClientController ()

@end

@implementation SocketClientController

- (void)viewDidLoad {
    [super viewDidLoad];
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    // Do view setup here.
}

- (IBAction)actOpen:(id)sender {
    if ([[_buttonOpen title] isEqualToString:@"打开"]) {
        [socket connectToHost:[_tfHostIP stringValue] onPort:[[_tfPort stringValue] intValue] error:nil];
    }else{
        [socket disconnect];
    }
    
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    [_buttonOpen setTitle:@"断开"];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    [_buttonOpen setTitle:@"打开"];
}
@end
