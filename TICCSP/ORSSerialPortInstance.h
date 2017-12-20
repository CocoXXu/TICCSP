//
//  ORSSerialPortInstance.h
//  TestORSSerialPort
//
//  Created by apple on 17/9/8.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORSSerialPort.h"
#import "CocoaAsyncSocket.framework/Headers/GCDAsyncSocket.h"

@interface ORSSerialPortInstance : NSObject<ORSSerialPortDelegate,GCDAsyncSocketDelegate>{
    NSMutableDictionary *dict_SerialPort;
    NSDictionary *dict_config;
    NSData *sendEndSymbol;
    ORSSerialPortParity parity;
    NSString *strCRC;
   
}
/**
 single mode,the class must be create only one time.if class is not exsit ,create it ,else return;
 @result BOOL --> return self
 */
+(id)shareInstance;

/**
 read data from serial port with serial port name , if it read endsymbol within timeout ,it will return read data else will continue read until time out then return timeout
 @param port --> serial port name ,such as "/dev/cu.XXXX"
 @param endSymol -->  read data contain endsymbol , end read
 @param timeout --> rcurrenttime - begintime >= timeout , end read
 @result NSData --> return read data from uart , if fail ,data will contain "timeout"
 */
-(NSData *)receiveDataFromPort:(NSString *)port withEndSymbol:(NSString *)endSymol andTimeOut:(int)timeout;

/**
 write data to serialport with serial port name
 @param data --> the data need send to serial port
 @param port --> serial port name ,such as "/dev/cu.XXXX"
 @result BOOL --> return write result , if fail return o , otherwise return 1
 */
-(BOOL)sendData:(NSData *)data toPort:(NSString *)port;
/**
 open serial port with port path and bandRate
 @param bandRate --> serial port serial band rate , such as 115200
 @param path --> serial port name ,such as "/dev/cu.XXXX"
 @result BOOL --> return open result , if fail return o , otherwise return 1
 */
-(BOOL)openSerialPortWithPath:(NSString *)path andBandRate:(NSNumber *)bandRate;
/**
 set uart send end symbol
 @param endSymbol --> send end symbol
 */
-(void)setSendEndSymbol:(NSData *)endSymbol;

/**
 set uart send end symbol
 @param parity --> uart parity and if not NONE , the uart will send parity
 */
-(void)setPority:(NSString *)theparity;

/**
 close serial port with port path and bandRate
 @param path --> serial port name ,such as "/dev/cu.XXXX"
 @result BOOL --> return close result , if fail return o , otherwise return 1
 */
-(BOOL)closeSerialPortWithPath:(NSString *)path;
/**
set data thecrc ,the default is no
@param thecrc --> if thecrc == CRC ,then the data will be calucation with crc and add the crc to the data as the end
*/
-(void)setCRC:(NSString *)thecrc;
@end
