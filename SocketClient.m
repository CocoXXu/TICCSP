//
//  SocketClient.m
//  TICCSP
//
//  Created by apple on 17/12/21.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "SocketClient.h"

@implementation SocketClient

@synthesize uart_handle;
@synthesize uart_path;
@synthesize uart_nl;
@synthesize uart_filePath;

-(id) initWithPath:(NSString *)path andBaudRate:(unsigned)baud_rate andParity:(NSString *)parity{
    self = [super init];
    if (self) {
        NSError *error;
        sockt = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [sockt connectToHost:path onPort:baud_rate error:&error];
        dataReceive = [[NSMutableData alloc] initWithCapacity:0];
        self.uart_nl = @"/r";
        if (error != nil) {
            return nil;
        }
    }
    return [super init];
}

-(int) write:(NSString *)str{
    [sockt writeData:[str dataUsingEncoding:NSUTF8StringEncoding] withTimeout:1 tag:[str length]];
    return 1;
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    [dataReceive appendData:data];
}
-(NSData *)read{
    NSData *dataReturn = [NSData dataWithData:dataReceive];
    [dataReceive resetBytesInRange:NSMakeRange(0, dataReceive.length)];
    [dataReceive setLength:0];
    return dataReturn;
}

-(int)  writeLineData:(NSData *)str{
    [sockt writeData:str withTimeout:1 tag:str.length];
    [sockt writeData:[uart_nl dataUsingEncoding:NSUTF8StringEncoding] withTimeout:1 tag:uart_nl.length];
    return 1;
}

-(int)  writeData:(NSData *)dataSend{
    [sockt writeData:dataSend withTimeout:1 tag:dataSend.length];
    return 1;
}

-(void)closePort{
    [sockt disconnect];
    
}
@end
