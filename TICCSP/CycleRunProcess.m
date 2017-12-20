//
//  CycleRunProcess.m
//  YModel
//
//  Created by apple on 17/10/13.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "CycleRunProcess.h"
//#import "ORSSerialPortInstance.h"
#import "FileManager.h"
#import "UartDevice.h"


static CycleRunProcess *shareInstance = NULL;
@implementation CycleRunProcess

+(id)shareInstance{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shareInstance = [[CycleRunProcess alloc] init];
    });
    return shareInstance;
}

-(instancetype)initWithArray:(NSArray *)thecommandArray andRunTime:(NSString *)therunTime andPortName:(UartDevice *)thedevice{
    if (self=[super init]) {
        commandArray = thecommandArray;
        runTime = therunTime;
        device = thedevice;
        stopFlag = NO;
    }
    return self;
}

-(void)setArrayCommand:(NSArray *)thecommandArray andRunTime:(NSString *)therunTime andPortName:(UartDevice *)thedevice andCrc:(BOOL)isCRC andES:(BOOL)isES andEndSymbol:(NSData *)endSymbol{
    commandArray = thecommandArray;
    runTime = therunTime;
    device = thedevice;
    stopFlag = NO;
    bCRC = isCRC;
    bES = isES;
    dES = endSymbol;
}

-(void)mainRun{
    BOOL flag = YES;
    NSMutableArray *commandArrayNeedSend = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < [commandArray count]; i++) {
        if([[commandArray[i] valueForKey:@"cyclenum"] intValue] != 0){
            
            [commandArrayNeedSend insertObject:commandArray[i] atIndex:[[commandArray[i] valueForKey:@"cyclenum"] intValue]-1];
        }
    }
    int time = [runTime intValue];
    if (time <= 0) {
        flag = NO;
        time = 1;
    }
    while (time) {
        if (flag == YES) {
            time--;
        }
        for (int i = 0 ; i < commandArrayNeedSend.count; i++) {
            if (stopFlag == YES) {
                break;
            }
            NSString *str = [commandArrayNeedSend[i] valueForKey:@"sleeptime"];
            [NSThread sleepForTimeInterval:[str doubleValue]/1000];
            NSData *sendData;
            if ([[commandArrayNeedSend[i] valueForKey:@"isHex"] intValue]) {
                sendData = [FileManager hexToBytes:[commandArrayNeedSend[i] valueForKey:@"command"]];
            }else{
                sendData = [[commandArrayNeedSend[i] valueForKey:@"command"] dataUsingEncoding:NSUTF8StringEncoding];
            }
//            [[ORSSerialPortInstance shareInstance] sendData:sendData toPort:devicePath];
            [device writeEndSybmolData:sendData withEndSymbol:dES andCrc:bCRC andIsEndSymol:bES];
        }
        if (stopFlag == YES) {
            time = 0;
        }
    }
}

-(void)setStop{
    stopFlag = YES;
}
@end
