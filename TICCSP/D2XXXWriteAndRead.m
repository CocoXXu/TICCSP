//
//  D2XXXWriteAndRead.m
//  TICCSP
//
//  Created by apple on 17/11/29.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "D2XXXWriteAndRead.h"

@implementation D2XXXWriteAndRead
-(id)initWithPortNameAndBaudRate:(NSString *)portName and:(NSString *)bandRate andShowResult:(showResultBlock)block{
    self = [super init];
    if (self) {
        FT_STATUS ftStatus = FT_OpenEx([portName UTF8String], FT_OPEN_BY_SERIAL_NUMBER, &ftHandle);
        if (ftStatus != FT_OK)
        {
            block([NSString stringWithFormat:@"Failed . FT_OpenEx returned %d",ftStatus]);
            goto exit;
        }
        
        
        ftStatus = FT_ResetDevice(ftHandle);
        if (ftStatus != FT_OK)
        {
            block([NSString stringWithFormat:@"Failure.  FT_ResetDevice returned %d.\n", (int)ftStatus]);
            goto exit;
        }
        
        ftStatus = FT_SetBaudRate(ftHandle, [bandRate intValue]);
        if (ftStatus != FT_OK)
        {
            block([NSString stringWithFormat:@"Failure.  FT_SetBaudRate(%d) returned %d.\n",
                                       [bandRate intValue],
                                       (int)ftStatus]);
            goto exit;
        }
        
        ftStatus = FT_SetDataCharacteristics(ftHandle,
                                             FT_BITS_8,
                                             FT_STOP_BITS_1,
                                             FT_PARITY_NONE);
        if (ftStatus != FT_OK)
        {
            block([NSString stringWithFormat:@"Failure.  FT_SetDataCharacteristics returned %d.\n", (int)ftStatus]);
            goto exit;
        }
        FT_SetUSBParameters(ftHandle, 1024, 512);
        FT_Purge(ftHandle, FT_PURGE_RX);
        // 清除输出缓存
        FT_Purge(ftHandle, FT_PURGE_TX);
        // Indicate our presence to remote computer
        ftStatus = FT_SetDtr(ftHandle);
        if (ftStatus != FT_OK)
        {
            block([NSString stringWithFormat:@"Failure.  FT_SetDtr returned %d.\n", (int)ftStatus]);
            goto exit;
        }
        
        // Flow control is needed for higher baud rates
        ftStatus = FT_SetFlowControl(ftHandle, FT_FLOW_RTS_CTS, 0, 0);
        if (ftStatus != FT_OK)
        {
            block([NSString stringWithFormat:@"Failure.  FT_SetFlowControl returned %d.\n", (int)ftStatus]);
            goto exit;
        }
        
        // Assert Request-To-Send to prepare remote computer
        ftStatus = FT_SetRts(ftHandle);
        if (ftStatus != FT_OK)
        {
            block([NSString stringWithFormat:@"Failure.  FT_SetRts returned %d.\n", (int)ftStatus]);
            goto exit;
        }
        
        ftStatus = FT_SetTimeouts(ftHandle, 0, 0);	// 3 seconds
        if (ftStatus != FT_OK)
        {
            block([NSString stringWithFormat:@"Failure.  FT_SetTimeouts returned %d\n", (int)ftStatus]);
            goto exit;;
        }
    exit:
        NSLog(@"end");
    }
    return self;
}
-(void)readDataForBlock:(showReceiveDataBlock)block1 withTimeout:(int)timeout{
    DWORD TxBytes;
    DWORD EventDWord;
    DWORD RxBytes;
    char * pcBufRead;
    DWORD dwBytesRead;
    NSDate *begintime = [NSDate date];
    while ([[NSDate date] timeIntervalSinceDate:begintime] <= timeout) {
        FT_GetStatus(ftHandle, &RxBytes, &TxBytes, &EventDWord);
        if (RxBytes){
            FT_Read(ftHandle, pcBufRead, RxBytes, &dwBytesRead);
            block1(pcBufRead);
            break;
        }
    }
}


-(BOOL)writeData:(NSData *)data{
    DWORD      bytesToWrite = 0;
    DWORD      bytesWritten = 0;
    bytesToWrite = (DWORD)(data.length); // Don't write string terminator
    FT_STATUS ftStatus = FT_Write(ftHandle,
                        [data bytes],
                        bytesToWrite,
                        &bytesWritten);
    return ftStatus;
}
@end
