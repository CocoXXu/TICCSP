//
//  UART&UUT.m
//  TICCSP
//
//  Created by apple on 17/12/21.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "UART&UUT.h"

@implementation UART_UUT
-(id) initWithPath:(NSString *)path andBaudRate:(unsigned)baud_rate andParity:(NSString *)parity{
    return [super init];
}

-(int) write:(NSString *)str{
    return 0;
}

-(NSData *)read{
    return nil;
}

-(int)  writeLineData:(NSData *)str{
    return 0;
}

-(int)  writeData:(NSData *)dataSend{
    return 0;
}

-(void)closePort{
    
}

@end
