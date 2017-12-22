//
//  UART&UUT.h
//  TICCSP
//
//  Created by apple on 17/12/21.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UART_UUT : NSObject{
//@private
//    int      uart_handle;
//    NSString *uart_path;
//    NSString *uart_nl;
//    NSString *uart_filePath;
//    
//    NSFileHandle         *uart_log;
//    NSMutableData *dataReceive;
}
//@property (readonly) int                    uart_handle;
//@property NSString *uart_path;
//@property (copy)		NSString           *uart_filePath;
//@property (copy)     NSString              *uart_nl;


-(id) initWithPath:(NSString *)path andBaudRate:(unsigned)baud_rate andParity:(NSString *)parity;

-(int) write:(NSString *)str;

-(NSData *)read;

-(int)  writeLineData:(NSData *)str;

-(int)  writeData:(NSData *)dataSend;

-(void)closePort;
@end
