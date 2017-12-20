//
//  YModemManager.m
//  TestORSSerialPort
//
//  Created by apple on 17/10/10.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "YModemManager.h"
#import "YModem.h"

static YModemManager *shareInstance = NULL;

@implementation YModemManager

+(id)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance=[[YModemManager alloc] init];
    });
    return shareInstance;
}

#pragma mark - first
- (NSData *)prepareFirstPacketWithFileName:(NSString *)filename {
    // 文件名
    
    NSString *room_name = [filename lastPathComponent];
    NSData* bytes = [room_name dataUsingEncoding:NSUTF8StringEncoding];
    Byte * myByte = (Byte *)[bytes bytes];
    UInt8 buff_name[bytes.length+1];
    memcpy(buff_name, [room_name UTF8String],[room_name lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1);
    //|UTF8String|返回是包含\0的  |lengthOfBytesUsingEncoding|计算不包括\0 所以这里加上一
    
    // 文件大小
    NSMutableData *file = [[NSMutableData alloc]init];
    
    //    NSString *path=  [[NSBundle mainBundle]pathForResource:@"w3.bin" ofType:nil];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString* path = [documentsDirectory stringByAppendingPathComponent:room_name];
//    path = [[NSBundle mainBundle] pathForResource:room_name ofType:nil];
    
    file = [NSMutableData  dataWithContentsOfFile:filename];
    uint32_t length = (uint32_t)file.length;
    
    // 发送SOH数据包
    // 生成包
    UInt8 *buff_data;
    buff_data = (uint8_t *)malloc(sizeof(uint8_t)*133);
    
    UInt8 *crc_data;
    crc_data = (uint8_t *)malloc(sizeof(uint8_t)*128);
    
    PrepareIntialPacket(buff_data, myByte, length);
    
    NSData *data_first = [NSData dataWithBytes:buff_data length:sizeof(uint8_t)*133];
    
    return data_first;
}

#pragma mark - 发送数据包
- (NSArray *)preparePacketWithFileName:(NSString *)filename {
//    NSString *room_name = [filename lastPathComponent];
    NSString *path = filename ;//[[NSBundle mainBundle] pathForResource:room_name ofType:nil];
    NSMutableData *file = [[NSMutableData alloc]init];
    file = [NSMutableData  dataWithContentsOfFile:path];
    
    uint32_t size = file.length>=PACKET_1K_SIZE?(PACKET_1K_SIZE):(PACKET_SIZE);
    
    // 拆包
    int index = 0;
    NSMutableArray *dataArray = [NSMutableArray array];
    for (int i = 0; i<file.length; i++) {
        if (i%size == 0) {
            index++;
            uint32_t len = size;
            if ((file.length-i)<size) {
                len = (uint32_t)file.length - i;
            }
            // 截取1024 或 128 长度数据
            NSData *sub_file_data = [file subdataWithRange:NSMakeRange(i, len)];
            
            uint32_t sub_size = PACKET_1K_SIZE;
            
            Byte *sub_file_byte = (Byte *)[sub_file_data bytes];
            uint8_t *p_packet;
            p_packet = (uint8_t *)malloc(sub_size+5);
            PreparePacket(sub_file_byte, p_packet, index, (uint32_t)sub_file_data.length);
            
            NSData *data_ = [NSData dataWithBytes:p_packet length:sizeof(uint8_t)*(sub_size+5)];
            [dataArray addObject:data_];
        }
    }
    
    return dataArray;
    
}
@end
