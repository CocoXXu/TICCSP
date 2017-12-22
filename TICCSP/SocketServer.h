//
//  SocketServer.h
//  TICCSP
//
//  Created by apple on 17/11/8.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "ORSSerialPort.h"
#import "UART&UUT.h"
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>

@interface SocketServer : UART_UUT<GCDAsyncSocketDelegate>{
    GCDAsyncSocket *serverSocket;
    NSMutableArray *arrayclientSocket;
    NSMutableDictionary *dictClientSocket;
    NSMutableData *dataReceive;
}

@end
