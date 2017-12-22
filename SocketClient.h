//
//  SocketClient.h
//  TICCSP
//
//  Created by apple on 17/12/21.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "UART&UUT.h"
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>

@interface SocketClient : UART_UUT<GCDAsyncSocketDelegate>{
@private
    int      uart_handle;
    NSString *uart_path;
    NSString *uart_nl;
    NSString *uart_filePath;
    
    NSFileHandle         *uart_log;
    NSMutableData *dataReceive;
    GCDAsyncSocket *sockt;
}

@property (readonly) int                    uart_handle;
@property NSString *uart_path;
@property (copy)		NSString           *uart_filePath;
@property (copy)     NSString              *uart_nl;

@end
