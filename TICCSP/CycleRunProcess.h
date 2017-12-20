//
//  CycleRunProcess.h
//  YModel
//
//  Created by apple on 17/10/13.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UartDevice.h"

@interface CycleRunProcess : NSObject{
    NSArray *commandArray;
    NSString *runTime;
    UartDevice *device;
    BOOL stopFlag;
    BOOL bCRC;
    BOOL bES;
    NSData *dES;
}
/**
 单例模式，用于循环发送
 */
+(id)shareInstance;

/**
 设置循环发送数据
 @para-->thecommandArray 需要发送的命令
 @para-->therunTime 发送次数
 @para-->thedevicePath 发送的串口名称
 */
-(void)setArrayCommand:(NSArray *)thecommandArray andRunTime:(NSString *)therunTime andPortName:(UartDevice *)thedevice andCrc:(BOOL)isCRC andES:(BOOL)isES andEndSymbol:(NSData *)endSymbolh;

/**
 开启线程，循环发送
 */
-(void)mainRun;

/**
 停止发送
 */
-(void)setStop;

@end
