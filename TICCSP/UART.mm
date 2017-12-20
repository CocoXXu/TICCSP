#include <termios.h>
#include <sys/ioctl.h>
#import "UART.h"

@implementation UART

@synthesize uart_handle;
@synthesize uart_path;
@synthesize uart_nl;
@synthesize uart_filePath;


-(id) initWithPath:(NSString *)path andBaudRate:(unsigned)baud_rate andParity:(NSString *)parity
{
	self = [super init];
        
	int handle = 0;
	struct termios  options;
    
	if (self) {
        handle = open([path UTF8String], O_RDWR | O_NONBLOCK| O_NOCTTY | O_NDELAY );        
		
		if (handle < 0) {
			NSLog(@"Error opening serial port %@ - %s(%d) at thread %@.", path, strerror(errno), errno,[NSThread currentThread]);
			goto error;
		}
	}
	
	if (self) {
		
		if (fcntl(handle, F_SETFL, FNDELAY) == -1) {        
			NSLog(@"Error clearing O_NONBLOCK %@ - %s(%d).\n", path, strerror(errno), errno);
			goto error;
		}
		
		
		if (tcgetattr(handle, &options) == -1) {
			NSLog(@"Error getting tty attributes %@ - %s(%d).\n", path, strerror(errno), errno);
			goto error;
		}
		
        cfsetspeed(&options, baud_rate);
		options.c_cflag |=  (CLOCAL  |  CREAD);
        if ([parity isEqualToString:@"NONE"]) {
            options.c_cflag &= ~(PARENB);
        }else if ([parity isEqualToString:@"ODD"]){
            options.c_cflag |= PARENB;
            options.c_cflag |= PARODD;
            options.c_iflag |= (INPCK|ISTRIP);
        }else if ([parity isEqualToString:@"EVEN"]){
            options.c_iflag |= (INPCK|ISTRIP);
            options.c_cflag |= PARENB;
            options.c_cflag &=~(PARODD);
        }
		
		options.c_cflag &= ~(CSTOPB);
		//		options.c_cflag &= ~(CSIZE);
		options.c_lflag &= ~(ICANON  |   ECHO   |   ECHOE   |   ISIG);
		options.c_oflag &= ~(OPOST);
		
        options.c_iflag &= ~ICRNL;              //from nanokdp
        options.c_oflag &= ~ONLCR;              //from nanokdp
        // Set flow control.
        
        options.c_cflag &= ~CRTSCTS;            //from nanokdp
        options.c_iflag &= ~( IXON | IXOFF | IXANY );   //from nanokdp
        
        
		
		
		if (tcsetattr(handle, TCSANOW, &options) == -1) {
			NSLog(@"Error setting tty attributes %@ - %s(%d).\n", path, strerror(errno), errno);
			goto error;
		}
		
		self->uart_handle = handle;
		self->uart_path   = [[NSString alloc] initWithString:path];
		//self->uart_nl     = @"\r\n";
		self->uart_nl     = @"\r";

	}
    
    [NSThread sleepForTimeInterval:0.01];
    
	return self;
    
error:
	if (handle >= 0) {
		close(handle);
	}
    
	self = nil;
    
	return self;
}

- (void) closePort
{

    if (uart_handle>0) {
        close(uart_handle);
        uart_handle=-1;
    }

}

-(void) dealloc
{

    if (uart_handle>0) {
        close(uart_handle);
        uart_handle=-1;
    }
}


-(int) writeBuffer:(unsigned char*)buffer length:(unsigned)len
{

	int count=0;
	
	char const *buf = (const char *)buffer;
	
	for (unsigned i = 0; i < len; i++) {
		
		
		int success=(int)write(self->uart_handle, buf+i, 1);

		if(success==1)
		{
			count++;
		} else {
			NSLog(@"Failed to write character no %d",i);
			break;
		}
	}
	return count;
}

-(int) write:(NSString *)str
{

	char const *buf = [str UTF8String];
	unsigned    len =(unsigned) [str length];
	for (unsigned i= 0; i< len; i++) {
		/*
		 * pace ourselves, dock uarts do not have flow control
		 */
		
		int success=(int)write(self->uart_handle, buf+i, 1);

        if(success!=1){
            NSLog(@"UART:%@ Failed to write character no %d in %@\nerrorcode=%d",self.uart_path,i,str,errno);
            break;
        }
        
		[NSThread sleepForTimeInterval:0.0005];
	}
    
	return len;
}



-(int)  writeLineData:(NSData *)str
{
	char buffer[4096];
	int count=0;
	int count_nl=0;
	
	while (read(self->uart_handle, buffer, sizeof(buffer)) > 0) {
	}
	count=(unsigned int)[self writeBuffer:(unsigned char*)[str bytes] length:(int)[str length]];
	
	count_nl=[self write:self.uart_nl];
	if (count_nl>0) {
		count=count+count_nl;
	}
    
	return count;
}

-(int)  writeData:(NSData *)dataSend
{
    char buffer[4096];
    int count=0;
//    int count_nl=0;
    
    while (read(self->uart_handle, buffer, sizeof(buffer)) > 0) {
    }
    count=(unsigned int)[self writeBuffer:(unsigned char*)[dataSend bytes] length:(int)[dataSend length]];
    
//    count_nl=[self write:self.uart_nl];
//    if (count_nl>0) {
//        count=count+count_nl;
//    }
    
    return count;
}
-(int) writeLine:(NSString *)str
{    
	char buffer[4096];
	
	/* flush input */
	while (read(self->uart_handle, buffer, sizeof(buffer)) > 0) {
	}
	
	return [self write:[str stringByAppendingString:self.uart_nl]];
}

-(NSData *)read
{
	char      buffer[8192];
	ssize_t   numBytes;
	//NSLog(@"Trying to read");
	numBytes = read(self->uart_handle, buffer, sizeof(buffer) - 1);
//	 uart_errorCode = errno;
	if (numBytes > 0) {
		int valid;
		
		//[self logData:[NSData dataWithBytes:buffer length:numBytes]];
		
		/*
		 * XXX : mpetit : iBoot produces \0 after its line endings
		 */
        valid = 0;
        for (unsigned i= 0; i< numBytes; i++) {
            if (buffer[i]) {
                buffer[valid] = buffer[i];
                valid += 1;
                //printf("0x%02X\n",buffer[i]);
            }
        }
		buffer[valid] = '\0';
        
        return [NSData  dataWithBytes:buffer length: valid];
    }
	
	NSString *myString = @"";
	const char *utfString = [myString UTF8String];
	NSData	  *returnData = [NSData dataWithBytes:utfString length:strlen(utfString)];
	return returnData;
	
}

-(BOOL)clearBuffer {
    [self writeLine:@""];
    [NSThread sleepForTimeInterval:0.1];
    if(tcflush(self.uart_handle, TCIOFLUSH)==0){
        return true;
    } else {
        return false;
    }
}

@end
