//
//  UartDevice.h
//  Shark
//
//  Created by apple on 17/9/4.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UART.h"

@interface UartDevice : NSObject{
    UART *auart;
}

-(instancetype)initWithDevice:(NSString *)device andBandRate:(NSString *)bandRate andParity:(NSString *)parity;

-(int)write:(NSString *)str;

-(NSData *)readDataWithEndSymbol:(NSString *)endSymbol andTimeOut:(int)timeout;

-(NSData *)write:(NSString *)str andReadWithEndSymbol:(NSString *)endSymbol andTimeOut:(int)timeout;

-(int)writeEndSybmolData:(NSData *)dataSend withEndSymbol:(NSData *)endData andCrc:(BOOL)isCRC andIsEndSymol:(BOOL)isES;

-(BOOL)close;
@end
