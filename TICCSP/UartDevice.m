//
//  UartDevice.m
//  Shark
//
//  Created by apple on 17/9/4.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "UartDevice.h"

@implementation UartDevice


-(instancetype)initWithDevice:(NSString *)device andBandRate:(NSString *)bandRate andParity:(NSString *)parity{
    self = [super init];
    if (self) {
        auart = [[UART alloc] initWithPath:device andBaudRate:[bandRate intValue] andParity:parity];
        if (auart == nil) {
            return nil;
        }
    }
    return self;
}

-(BOOL)close{
    [auart closePort];
    return YES;
}


-(int)write:(NSString *)str{
    str = [NSString stringWithFormat:@"%@\r\n",str];
    NSLog(@"send:%@",str);
    int buffer = [auart write:str];
    return buffer;
}
-(int)writeData:(NSData *)dataSend{
    int buffer = [auart writeData:dataSend];
    return buffer;
}

-(int)writeEndSybmolData:(NSData *)dataSend withEndSymbol:(NSData *)endData andCrc:(BOOL)isCRC andIsEndSymol:(BOOL)isES{
    NSMutableData *sendData = [[NSMutableData alloc] initWithData:dataSend];
    if (isES) {
        [sendData appendData:endData];
    }
    if (isCRC ) {
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
    
    int buffer = [auart writeData:sendData];
    return buffer;
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

-(NSData *)readDataWithEndSymbol:(NSString *)endSymbol andTimeOut:(int)timeout{
    
    NSDate *beginTime = [NSDate date];
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:0];
    while ([[NSDate date] timeIntervalSinceDate:beginTime] < timeout) {
        NSData *currentReadData = [auart read];
        [data appendData:currentReadData];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([str rangeOfString:endSymbol].location != NSNotFound) {
            return data;
        }
    }
    NSString *str_timeOut = @"time out";
    return [[NSData alloc] initWithBytes:[str_timeOut UTF8String] length:[str_timeOut length]];
}
-(NSData *)readData{
    NSData *currentReadData = [auart read];
    return  currentReadData;
}


-(NSData *)write:(NSString *)str andReadWithEndSymbol:(NSString *)endSymbol andTimeOut:(int)timeout{
    @synchronized (auart) {
        NSLog(@"start work");
        [self write:str];
        NSData *data = [self readDataWithEndSymbol:endSymbol andTimeOut:timeout];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showDebugMessage" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@\r\n",str],@"send",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding],@"receive", nil]];
        NSLog(@"end work");
        return data;
    }
    
}
@end
