//
//  SocketServer.m
//  TICCSP
//
//  Created by apple on 17/11/8.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "SocketServer.h"

@implementation SocketServer
-(id) initWithPath:(NSString *)path andBaudRate:(unsigned)baud_rate andParity:(NSString *)parity{
    self= [super init];
    if (self) {
        NSError *error;
        serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        arrayclientSocket = [[NSMutableArray alloc] initWithCapacity:0];
        dataReceive = [[NSMutableData alloc] initWithCapacity:0];
        dictClientSocket = [[NSMutableDictionary alloc] initWithCapacity:0];
        BOOL result = [serverSocket acceptOnPort:baud_rate error:&error];
        if (result == NO) {
            return nil;
        }
    }
    return self;
}

-(int) write:(NSString *)str{
    return 0;
}

-(NSData *)read{
    return nil;
}

-(int)  writeLineData:(NSData *)str{
    return 0;
}

-(int)  writeData:(NSData *)dataSend{
    return 0;
}

-(void)closePort{
    
}

- (void)socket:(GCDAsyncSocket*)sock didAcceptNewSocket:(GCDAsyncSocket*)newSocket{
    
    //保存客户端的socket
    if (![[dictClientSocket allKeys] containsObject:newSocket]) {
//        [dictClientSocket setObject:<#(nonnull id)#> forKey:<#(nonnull id<NSCopying>)#>]
    }
    
    [newSocket readDataWithTimeout:-1 tag:0];
    
}
- (void)socket:(GCDAsyncSocket*)sock didReadData:(NSData*)data withTag:(long)tag{
    

    
    [sock readDataWithTimeout:-1 tag:0];
    
}

@end
