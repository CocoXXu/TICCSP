//
//  YModemProcess.h
//  YModel
//
//  Created by apple on 17/10/12.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YModemProcess : NSObject{
    NSString *filePath;
    NSString *portName;
}
typedef void (^showLabelBolck)(NSString *message);
typedef void (^showLevelBlock)(double max , double current);
typedef void (^showTimeOutBlock)();


/**
 main process to burnin bin/hex file to mainboard
 @param thefilePath --> the file need to burnin to mainboard
 @param theportName -->  port such as "/dev/cu.XXXX"
 @result  --> retuen self ,fail will return nil
 */
-(instancetype)initWithFileName:(NSString *)thefilePath andPort:(NSString *)theportName;
/**
 发送文件流程
 1开启是由接收方开启传输，接收方发送一个字符'C'，然后进入等待（SOH）状态，如果没有回应，就会超时退出。
 2发送方开始时处于等待过程中，等待字符'C'。发送方收到'C'后，发送第一帧数据包，内容如下：
 SOH 00 FF Foo.c NUL[123] CRC CRC （Foo.c为文件名，NUL[123]补0）
 进入等待（ACK）状态。
 3接收方收到第一帧数据包后，CRC校验满足，则发送ACK。
 4发送方接收到ACK，又进入等待“文件传输开启”信号，即重新进入等待“C”的状态。
 上面接收方只是收到了一个文件名，现在正式开启文件传输，Ymodem支持128字节和1024字节一个数据包。128字节以（SOH）开始，1024字节以（STX）开始。
 5接收方又发出一个字符'C'，开始准备接收文件。进入等待“SOH”或者“STX”状态。
 6发送方收到字符'C'后，开始发送第二帧，第二帧中的数据存放的是第一包数据。内容如下：
 （SOH/STX）（01序号）（FE反码）（128/1024位数据）（CRC校验），等待接收方“ACK”。
 7接收方收到数据后，发送一个ACK，然后等待下一包数据传送完毕，继续ACK应答。直到所有数据传输完毕。…
 8数据传输完毕后，发送方发EOT，第一次接收方以NAK应答，进行二次确认。发送方收到NAK后，重发EOT，接收方第二次收到结束符，就以ACK应答。最后接收方再发送一个字符'C'开启另一次传输，发送方在没有第二个文件要传输的情况下，发送如下数据：SOH 00 FF 00~00(共128个) CRCH CRCL，接收方应答ACK后，正式结束数据传输。
 @param -->block1 mainwindow show infomation
 @param -->block2 mainwindow show rate of progress
 @param -->block3 mainwindow show time out 
 */
-(void)mainTest:(showLabelBolck)block1 andLevelBlock:(showLevelBlock)block2 andTimeOutBlock:(showTimeOutBlock) block3;

@end
