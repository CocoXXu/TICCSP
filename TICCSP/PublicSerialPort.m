//
//  PublicSerialPort.m
//  TICCSP
//
//  Created by apple on 17/11/2.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "PublicSerialPort.h"
#import "ORSSerialPortManager.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
static PublicSerialPort *shareInstance = NULL;
@implementation PublicSerialPort
+(id)shareInstance{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shareInstance = [[PublicSerialPort alloc] init];
    });
    return shareInstance;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        serialPortPath = [[NSArray alloc] initWithArray:[[ORSSerialPortManager sharedSerialPortManager] availablePorts]];
        currentSerialPort = @"";
        array_bandRate = [NSArray arrayWithObjects:@"115200",@"9600",@"14400",@"19200",@"38400",@"300",@"600",@"1200",@"2400",@"4800",@"230400",@"460800",@"921600", nil];
        currentBandRate = @"115200";
        
        array_parity = [NSArray arrayWithObjects:@"NONE",@"ODD",@"EVEN", nil];
        currentParity = @"NONE";
        buttonName = @"打开";
    }
    return self;
}


-(void)setSerialPort:(NSArray *)theserialPortPath{
    serialPortPath = theserialPortPath;
}

-(void)setCurrentSerialPort:(NSString *)thecurrentSerialPort{
    currentSerialPort = thecurrentSerialPort;
}

-(void)setbuttonName:(NSString *)thebuttonName{
    buttonName = thebuttonName;
}


-(NSArray *)getserialPortPath{
    return serialPortPath;
}

-(NSString *)getcurrentSerialPort{
    return currentSerialPort;
}


-(NSString *)getbuttonName{
    return buttonName;
}


-(NSArray *)getarray_bandRate{
    return array_bandRate;
}

-(NSArray *)getarray_parity{
    return array_parity;
}

-(NSString *)getcurrentBandRate{
    return currentBandRate;
}

-(void)setcurrentBandRate:(NSString *)thecurrentBandRate{
    currentBandRate = thecurrentBandRate;
}

-(NSString *)getcurrentParity{
    return currentParity;
}

-(void)setcurrentParity:(NSString *)thecurrentParity{
    currentParity = thecurrentParity;
}

-(NSString *)getdevecePath{
    return devecePath;
}
-(void)setdevecePath:(NSString *)thedevecePath{
    devecePath = thedevecePath;
}
@end
