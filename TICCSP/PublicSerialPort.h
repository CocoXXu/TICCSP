//
//  PublicSerialPort.h
//  TICCSP
//
//  Created by apple on 17/11/2.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicSerialPort : NSObject{
    NSArray *serialPortPath;
    NSString *currentSerialPort;
    NSArray *array_bandRate;
    NSString *currentBandRate;
    NSArray *array_parity;
    NSString *currentParity;
    NSString *buttonName;
    NSString *devecePath;
}
/**
 单例模式实现YModelController & SerialPortController数据共用，
 如当YModelController打开串口时serialportcontroller需显示当前打开的串口名称及打开状态
 */
+(id)shareInstance;
/**
 设置当前可用串口名称列表
 @para-->theserialPortPath 当前可用串口名称列表
 */
-(void)setSerialPort:(NSArray *)theserialPortPath;
/**
 设置当前选择的串口名称
 @para-->thecurrentSerialPort 当前选择的串口名称
 */
-(void)setCurrentSerialPort:(NSString *)thecurrentSerialPort;
/**
 设置当前选择的串口状态，打开or关闭
 @para-->thebuttonName 当前选择的串口状态，打开or关闭
 */
-(void)setbuttonName:(NSString *)thebuttonName;

/**
返回当前可用串口名称列表
@result-->serialPortPath 当前可用串口名称列表
*/
-(NSArray *)getserialPortPath;
/**
返回当前选择的串口名称
 @result-->currentSerialPort 当前选择的串口名称
 */
-(NSString *)getcurrentSerialPort;
/**
 返回当前选择的串口状态，打开or关闭
 @para-->buttonName 当前选择的串口状态，打开or关闭
 */
-(NSString *)getbuttonName;

/**
 返回当前可用波特率列表
 @result-->array_bandRate 当前可用波特率列表
 */
-(NSArray *)getarray_bandRate;
/**
 返回当前可用校验方式列表
 @result-->array_parity 当前可用校验方式列表
 */
-(NSArray *)getarray_parity;
/**
 返回当前波特率
 @para-->currentBandRate 当前波特率
 */
-(NSString *)getcurrentBandRate;
/**
 设置当前波特率
 @result-->currentBandRate 当前波特率
 */
-(void)setcurrentBandRate:(NSString *)thecurrentBandRate;
/**
 返回当前校验方式
 @result-->currentParity 当前校验方式
 */
-(NSString *)getcurrentParity;
/**
 设置当前校验方式
 @para-->thecurrentParity 当前校验方式
 */
-(void)setcurrentParity:(NSString *)thecurrentParity;

/**
返回当前串口路径
  @result-->devecePath 当前串口路径
 */
-(NSString *)getdevecePath;
/**
 设置当前串口路径
 @para-->thedevecePath 当前串口路径
 */
-(void)setdevecePath:(NSString *)thedevecePath;


@end
