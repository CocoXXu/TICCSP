//
//  YModemManager.h
//  TestORSSerialPort
//
//  Created by apple on 17/10/10.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YModemManager : NSObject

/**
 单例模式，bin/hex文件解析以及数据的校验，head设置
 */
+(id)shareInstance;

/**
 第一帧数据的读取与设置
 @param-->filename 需发送的文件包含路径
 @result -->nadata,包含文件名的第一帧数据 such as "SOH 00 FF Foo.c NUL[123] CRC CRC （Foo.c为文件名，NUL[123]补0）"
 */
- (NSData *)prepareFirstPacketWithFileName:(NSString *)filename ;
/**
 文件内容读取解析，校验，head等转换
 @param-->filename 需发送的文件包含路径
 @result -->NSArray,文件内容多次发送，每个数据包涵（SOH/STX）（01序号）（FE反码）（128/1024位数据）（CRC校验）
 */
- (NSArray *)preparePacketWithFileName:(NSString *)filename;

@end
