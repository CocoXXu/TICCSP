#import <Cocoa/Cocoa.h>
#import "UART&UUT.h"


@interface UART : UART_UUT
{
@private
	int      uart_handle;
	NSString *uart_path;
	NSString *uart_nl;
	NSString *uart_filePath;
	
	NSFileHandle         *uart_log;
    NSMutableData *dataReceive;

}

@property (readonly) int                    uart_handle;
@property NSString *uart_path;
@property (copy)		NSString           *uart_filePath;
@property (copy)     NSString              *uart_nl;
//
//
//-(id) initWithPath:(NSString *)path andBaudRate:(unsigned)baud_rate andParity:(NSString *)parity;
//
//-(int) write:(NSString *)str;
//
//-(NSData *)read;
//
//-(int)  writeLineData:(NSData *)str;
//
//-(int)  writeData:(NSData *)dataSend;
//
//-(void)closePort;
@end
