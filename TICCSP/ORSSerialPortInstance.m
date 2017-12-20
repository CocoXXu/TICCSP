//
//  ORSSerialPortInstance.m
//  TestORSSerialPort
//
//  Created by apple on 17/9/8.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "ORSSerialPortInstance.h"
#import <Cocoa/Cocoa.h>
#import "FileManager.h"

static ORSSerialPortInstance *shareInstance = NULL;

@implementation ORSSerialPortInstance

+(id)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance=[[ORSSerialPortInstance alloc] init];
    });
    return shareInstance;
}

-(BOOL)openSerialPortWithPath:(NSString *)path andBandRate:(NSNumber *)bandRate{
    ORSSerialPort *aport = [ORSSerialPort serialPortWithPath:path];;
    aport.baudRate = bandRate;
    aport.parity = parity;
    aport.delegate = self;
    [aport open];
    if (aport.isOpen) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:aport,@"port",@"\r\n",@"es", nil];
        [dict_SerialPort setObject:dict forKey:aport.path];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"debugMessage" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[FileManager TimeStamp],@"time",@"open success",@"status",path,@"message", nil]];
        return YES;
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"debugMessage" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[FileManager TimeStamp],@"time",@"open fail",@"status",path,@"message", nil]];
        return NO;
    }

}

-(BOOL)closeSerialPortWithPath:(NSString *)path{
    
    ORSSerialPort *aport = [[dict_SerialPort valueForKey:path] valueForKey:@"port"];
    BOOL closeFlag = NO;
    if (aport.isOpen) {
         closeFlag = [aport close];
    }
   
    if ([path isNotEqualTo:@""]) {
        [dict_SerialPort removeObjectForKey:path];
    }
    return closeFlag;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        dict_SerialPort = [[NSMutableDictionary alloc] initWithCapacity:0];
        sendEndSymbol = [@"" dataUsingEncoding:NSUTF8StringEncoding];
        parity = ORSSerialPortParityNone;
        strCRC = @"";
    }
    return self;
}
-(void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data{
    @synchronized (dict_SerialPort) {
        NSString *portName = serialPort.path;
        for (NSString *akey in [dict_SerialPort allKeys]) {
            if ([[akey lowercaseString] isEqualToString:[portName lowercaseString]]) {
                NSMutableDictionary *dict = [dict_SerialPort valueForKey:akey];
                if ([dict valueForKey:@"data"] == nil) {
                    NSMutableData *muta_data = [NSMutableData dataWithData:data];
                    [dict setObject:muta_data forKey:@"data"];
                }else{
                    NSMutableData *muta_data = [dict valueForKey:@"data"];
                    [muta_data appendData:data];
                }
                
            }
        }
        if ((data != NULL) && ([data length] > 0)) {
            NSString *aa =@"";
            NSData *datatest = [aa dataUsingEncoding:NSUTF8StringEncoding];
            if ([datatest isEqualToData:data]) {
                NSLog(@"%@",data);
            }
            
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"debugMessage" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[FileManager TimeStamp],@"time",@"Receive",@"status",data,@"message", nil]];
        }
    }
   
}

-(void)serialPort:(ORSSerialPort *)serialPort requestDidTimeout:(ORSSerialRequest *)request{
    NSLog(@"%@",request);
}

-(void)serialPort:(ORSSerialPort *)serialPort didEncounterError:(NSError *)error{
    NSLog(@"%@",error);
}

-(void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:[NSString stringWithFormat:@"Attention : %@ disconnected",serialPort.name]];
    [alert runModal];
}

-(BOOL)sendData:(NSData *)data toPort:(NSString *)port{
    NSMutableData *sendData = [[NSMutableData alloc] initWithData:data];
    [sendData appendData:sendEndSymbol];
    
    ORSSerialPort *aport = [[dict_SerialPort valueForKey:port] valueForKey:@"port"];
    aport.parity = parity;
    if ([strCRC isEqualToString:@"CRC"] ) {
        uint8_t *parityData;
        parityData = (uint8_t *)malloc(2);
        uint16 crc= ym_crc16((Byte *)[sendData bytes],sizeof(sendData));
        uint16_t resultL=crc & 0xFF;
        // 高位
        uint16_t resultH=crc >> 8;
        
        parityData[0] = resultH;
        parityData[1] = resultL;
        [sendData appendBytes:parityData length:2];
    }
    return [aport sendData:sendData];
}

static uint16_t ym_crc16(const uint8_t *buf, uint16_t len)
{
    uint16_t x;
    uint16_t crc = 0;
    while (len--)
    {
        x = (crc >> 8) ^ *buf++;
        x ^= x >> 4;
        crc = (crc << 8) ^ (x << 12) ^ (x << 5) ^ x;
    }
    return crc;
}

-(NSData *)receiveDataFromPort:(NSString *)port withEndSymbol:(NSString *)endSymol andTimeOut:(int)timeout{
    
    NSDate *begin = [NSDate date];
    if ([endSymol isEqualToString:@""]) {
        endSymol = [[dict_SerialPort valueForKey:port] valueForKey:@"es"];
    }
     BOOL timeoutFlag = YES;
    while ([[NSDate date] timeIntervalSinceDate:begin] <= timeout) {
        NSData *data;
        @synchronized (dict_SerialPort) {
            data = [[dict_SerialPort valueForKey:port] valueForKey:@"data"];
            [dict_SerialPort setValue:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"data", nil] forKey:port];
        }
        if ([[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] rangeOfString:endSymol].location != NSNotFound) {
            timeoutFlag = NO;
            break;
        }
        [NSThread sleepForTimeInterval:0.005];
    }
    NSMutableData *muta_data = [[NSMutableData alloc] initWithCapacity:0];
    if (timeoutFlag == YES) {
        NSString *str_timeout = @"time out";
        [muta_data appendData:[str_timeout dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    @synchronized (dict_SerialPort){
        [muta_data appendData:[[dict_SerialPort valueForKey:port] valueForKey:@"data"]];
        if ([[dict_SerialPort valueForKey:port] valueForKey:@"data"]) {
            NSMutableDictionary *dict = [dict_SerialPort valueForKey:port];
            NSString *str = @"";
            [dict setObject:[str dataUsingEncoding:NSUTF8StringEncoding] forKey:@"data"];
        }
    }
    return muta_data;
}

-(NSData *)receiveDataFromPort:(NSString *)port withlengh:(int)lengh andTimeOut:(int)timeout{
    
    NSDate *begin = [NSDate date];
    
    BOOL timeoutFlag = YES;
    while ([[NSDate date] timeIntervalSinceDate:begin] <= timeout) {
        NSData *data;
        @synchronized (dict_SerialPort) {
            data = [[dict_SerialPort valueForKey:port] valueForKey:@"data"];
            
            
        }
        if ((data) || ([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding].length >= lengh)) {
            timeoutFlag = NO;
            break;
        }
        [NSThread sleepForTimeInterval:0.005];
    }
    NSMutableData *muta_data = [[NSMutableData alloc] initWithCapacity:0];
    if (timeoutFlag == YES) {
        NSString *str_timeout = @"time out";
        [muta_data appendData:[str_timeout dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    @synchronized (dict_SerialPort){
        [muta_data appendData:[[dict_SerialPort valueForKey:port] valueForKey:@"data"]];
        if ([[dict_SerialPort valueForKey:port] valueForKey:@"data"]) {
            NSMutableDictionary *dict = [dict_SerialPort valueForKey:port];
            NSString *str = @"";
            [dict setObject:[str dataUsingEncoding:NSUTF8StringEncoding] forKey:@"data"];
        }
    }
    return muta_data;
}

-(void)setSendEndSymbol:(NSData *)endSymbol{
    sendEndSymbol = endSymbol;
}

//@"NONE",@"CRC",@"ODD",@"EVEN"
-(void)setPority:(NSString *)theparity{
    if ([theparity isEqualToString:@"ODD"]){
        parity = ORSSerialPortParityOdd;
    }else if ([theparity isEqualToString:@"EVEN"]){
        parity = ORSSerialPortParityEven;
    }else{
        parity  = ORSSerialPortParityNone;
    }
}

-(void)setCRC:(NSString *)thecrc{
    strCRC = thecrc;
}


@end
