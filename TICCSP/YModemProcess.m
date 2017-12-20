//
//  YModemProcess.m
//  YModel
//
//  Created by apple on 17/10/12.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "YModemProcess.h"
#import "YModemManager.h"
#import "ORSSerialPortInstance.h"

#define timeout 20
#define retryTimesMax 3
@implementation YModemProcess

-(instancetype)initWithFileName:(NSString *)thefilePath andPort:(NSString *)theportName{
    if (self = [super init]) {
        filePath = thefilePath;
        portName = theportName;
    }
    return self;
}


-(void)mainTest:(showLabelBolck)block1 andLevelBlock:(showLevelBlock)block2 andTimeOutBlock:(showTimeOutBlock) block3{

    int retryTimesCurrent = 0;
    
    NSData *data_head = [[YModemManager shareInstance] prepareFirstPacketWithFileName:filePath];
    NSArray *date_source_array = [[YModemManager shareInstance] preparePacketWithFileName:filePath];
    ORSSerialPortInstance *shareInstance =[ORSSerialPortInstance shareInstance];
    dispatch_async(dispatch_get_main_queue(), ^{
        block2(date_source_array.count,0);
    });
    int status = 0;
    int currentStage = 0;
    NSDate *beginDate= [NSDate date];
    while (1) {
        if (status == 8) {
            break;
        }
        switch (status) {
            case 0://wait for C and send SOH
            {
                NSData *data_uart = [shareInstance receiveDataFromPort:portName withlengh:1 andTimeOut:1];
                NSString *str_uart = [[NSString alloc] initWithData:data_uart encoding:NSUTF8StringEncoding];
                NSLog(@"%d:receive :%@",status,str_uart);
                if ([str_uart rangeOfString:@"C"].location != NSNotFound) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block1(@"文件传输中，请等待......");
                        
                    });
                    if ([shareInstance sendData:data_head toPort:portName]) {
                        NSLog(@"%d:send : %@",status,data_head);
                        status = 1;
                        retryTimesCurrent = 0;
                        beginDate = [NSDate date];
                    }
                }
                if ([[NSDate date] timeIntervalSinceDate:beginDate] > timeout) {//timeout
                    block3();
                    status = 8;
                }
            }
                break;
            case 1: //wait for ack
            {
                
                NSData *data_uart = [shareInstance receiveDataFromPort:portName withlengh:1 andTimeOut:1];
                NSString *str_uart = [[NSString alloc] initWithData:data_uart encoding:NSUTF8StringEncoding];
                if ([str_uart isNotEqualTo:@""]) {
                    NSLog(@"%d:receive :%@",status,str_uart);
                }
                Byte *data_byte=(Byte *)[data_uart bytes];
                for(int i=0;i<[data_uart length];i++){
                    if (data_byte[i] == 0x06) {
                        status = 2;
                        beginDate = [NSDate date];
                        break;
                    }else if (data_byte[i] == 0x15){
                        retryTimesCurrent++;
                        if (retryTimesCurrent < retryTimesMax) {
                            if ([shareInstance sendData:data_head toPort:portName]) {
                                NSLog(@"%d:retry%d:send : %@",status,retryTimesCurrent,data_head);
                                beginDate = [NSDate date];
                            }
                        }else{
                            block3();
                            status = 8;
                        }
                        break;
                        
                    }
                }
                if ([[NSDate date] timeIntervalSinceDate:beginDate] > timeout) {//timeout
                    block3();
                    status = 8;
                }
            }
                break;
                
            case 2: //wait for C and send SOH/STX NO1
            {
                
                NSData *data_uart = [shareInstance receiveDataFromPort:portName withlengh:1 andTimeOut:1];
                NSString *str_uart = [[NSString alloc] initWithData:data_uart encoding:NSUTF8StringEncoding];
                if ([str_uart isNotEqualTo:@""]) {
                    NSLog(@"%d:receive :%@",status,str_uart);
                }
                
                if ([str_uart rangeOfString:@"C"].location != NSNotFound) {
                    if ([shareInstance sendData:date_source_array[currentStage++] toPort:portName]) {
                        NSLog(@"%d:send : %@",status,date_source_array[currentStage-1]);
                        if (currentStage<date_source_array.count) {
                            status = 3;
                            retryTimesCurrent = 0;
                        }else{
                            status = 4;
                            retryTimesCurrent = 0;
                        }
                        beginDate = [NSDate date];
                    }
                }else if(str_uart.length >0){
                    Byte *data_byte=(Byte *)[data_uart bytes];
                    for(int i=0;i<[data_uart length];i++){
                        if (data_byte[i] == 0x15){
                            retryTimesCurrent++;
                            if (retryTimesCurrent < retryTimesMax) {
                                if ([shareInstance sendData:date_source_array[currentStage-1] toPort:portName]) {
                                    NSLog(@"%d:retry%d:send : %@",status,retryTimesCurrent,data_head);
                                    beginDate = [NSDate date];
                                }
                            }else{
                                block3();
                                status = 8;
                            }
                            break;
                            
                        }
                    }
                }
                
                
                if ([[NSDate date] timeIntervalSinceDate:beginDate] > timeout) {
//                    [self showTimeOut];
                    block3();
                    status = 8;
                }
            }
                break;
                
            case 3: //wait for ack and send NO2
            {
                
                NSData *data_uart = [shareInstance receiveDataFromPort:portName withlengh:1 andTimeOut:1];
                NSString *str_uart = [[NSString alloc] initWithData:data_uart encoding:NSUTF8StringEncoding];
                NSLog(@"%d:receive :%@",status,str_uart);
                Byte *data_byte=(Byte *)[data_uart bytes];
                for(int i=0;i<[data_uart length];i++){
                    if (data_byte[i] == 0x06) {
                        if ([shareInstance sendData:date_source_array[currentStage++] toPort:portName]) {
                            NSLog(@"%d:send : %@",status,date_source_array[currentStage-1]);
                            if (currentStage<date_source_array.count) {
                                status = 3;
                                retryTimesCurrent = 0;
                            }else{
                                status = 4;
                                retryTimesCurrent = 0;
                            }
                            beginDate = [NSDate date];
                        }
                        break;
                    }else if (data_byte[i] == 0x15){
                        retryTimesCurrent++;
                        if (retryTimesCurrent < retryTimesMax) {
                            if ([shareInstance sendData:date_source_array[currentStage-1] toPort:portName]) {
                                NSLog(@"%d:retry%d:send : %@",status,retryTimesCurrent,data_head);
                                beginDate = [NSDate date];
                            }
                        }else{
                            block3();
                            status = 8;
                        }
                        break;
                    }
                }
                if ([[NSDate date] timeIntervalSinceDate:beginDate] > timeout) {
//                    [self showTimeOut];
                    block3();
                    status = 8;
                }
                
            }
                break;
                
            case 4: //wait for ack and end send EOT
            {
                Byte byte4[] = {0x04};
                NSData *data23 = [NSData dataWithBytes:byte4 length:sizeof(byte4)];
                NSData *data_uart = [shareInstance receiveDataFromPort:portName withlengh:1 andTimeOut:1];
                NSString *str_uart = [[NSString alloc] initWithData:data_uart encoding:NSUTF8StringEncoding];
                if ([str_uart isNotEqualTo:@""]) {
                    NSLog(@"%d:receive :%@",status,str_uart);
                }
                Byte *data_byte=(Byte *)[data_uart bytes];
                for(int i=0;i<[data_uart length];i++){
                    if (data_byte[i] == 0x06)
                    {
                        if ([shareInstance sendData:data23 toPort:portName]) {
                            NSLog(@"%d:send : %@",status,data23);
                            status = 5;
                            retryTimesCurrent = 0;
                            beginDate = [NSDate date];
                            break;
                        }
                    }else if (data_byte[i] == 0x15){
                        retryTimesCurrent++;
                        if (retryTimesCurrent < retryTimesMax) {
                            if ([shareInstance sendData:date_source_array[currentStage-1] toPort:portName]) {
                                NSLog(@"%d:retry%d:send : %@",status,retryTimesCurrent,data_head);
                                beginDate = [NSDate date];
                            }
                        }else{
                            block3();
                            status = 8;
                        }
                    }
                }
                if ([[NSDate date] timeIntervalSinceDate:beginDate] > timeout) {
                    block3();
                    status = 8;
                }
            }
                break;
                
            case 5: //wait for Nack and end send EOT
            {
                Byte byte4[] = {0x04};
                NSData *data23 = [NSData dataWithBytes:byte4 length:sizeof(byte4)];
                NSData *data_uart = [shareInstance receiveDataFromPort:portName withlengh:1 andTimeOut:1];
                NSString *str_uart = [[NSString alloc] initWithData:data_uart encoding:NSUTF8StringEncoding];
                NSLog(@"%d:receive :%@",status,str_uart);
                Byte *data_byte=(Byte *)[data_uart bytes];
                for(int i=0;i<[data_uart length];i++){
                    if (data_byte[i] == 0x15) {
                        if ([shareInstance sendData:data23 toPort:portName]) {
                            NSLog(@"%d:send : %@",status,data23);
                            status = 6;
                            retryTimesCurrent = 0;
                            beginDate = [NSDate date];
                            break;
                        }
                    }
                }
                if ([[NSDate date] timeIntervalSinceDate:beginDate] > timeout) {
//                    [self showTimeOut];
                    block3();
                    status = 8;
                }
            }
                break;
                
            case 6: //wait for ack
            {
                
                NSData *data_uart = [shareInstance receiveDataFromPort:portName withlengh:1 andTimeOut:1];
                NSString *str_uart = [[NSString alloc] initWithData:data_uart encoding:NSUTF8StringEncoding];
                if ([str_uart isNotEqualTo:@""]) {
                    NSLog(@"%d:receive :%@",status,str_uart);
                }
                Byte *data_byte=(Byte *)[data_uart bytes];
                for(int i=0;i<[data_uart length];i++){
                    if (data_byte[i] == 0x06) {
                        status = 7;
                        retryTimesCurrent = 0;
                        beginDate = [NSDate date];
                        break;
                    }
                }
                if ([[NSDate date] timeIntervalSinceDate:beginDate] > timeout) {
                    block3();
                    status = 8;
                }
            }
                break;
                
            case 7: //wait for C and send end
            {
                NSData *data_uart = [shareInstance receiveDataFromPort:portName withlengh:1 andTimeOut:1];
                NSString *str_uart = [[NSString alloc] initWithData:data_uart encoding:NSUTF8StringEncoding];
                NSLog(@"%d:receive :%@",status,str_uart);
                if ([str_uart rangeOfString:@"C"].location != NSNotFound) {
                    UInt8 *buff_data;
                    buff_data = (uint8_t *)malloc(sizeof(uint8_t)*(128+5));
                    PrepareEndPacket(buff_data);
                    NSData *data_first = [NSData dataWithBytes:buff_data length:sizeof(uint8_t)*(128+5)];
                    [shareInstance sendData:data_first toPort:portName];
                    NSLog(@"%d:send : %@",status,data_first);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block1(@"文件传输成功！！!");
                    });
                    status = 8;
                    beginDate = [NSDate date];
                }
                if ([[NSDate date] timeIntervalSinceDate:beginDate] > timeout) {
                    block3();
                    status = 8;
                }
            }
                break;
                
                
            default:
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            block2(date_source_array.count,currentStage);
        });
    }
    
}
@end
