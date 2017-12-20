//
//  YModelController.m
//  TICCSP
//
//  Created by apple on 17/11/2.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "YModelController.h"
#import "ORSSerialPortInstance.h"
#import "ORSSerialPortManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PublicSerialPort.h"
#import "NSObject+RACKVOWrapper.h"
#import "YModemProcess.h"
#import "testD2XXX.h"
#import "YModemManager.h"
#import "UartDevice.h"

@interface YModelController ()

@end

@implementation YModelController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_pop_serialPort removeAllItems];
    [_pop_parity removeAllItems];
    [_ComboBox_BandRate removeAllItems];
    NSArray *array =[[PublicSerialPort shareInstance] getserialPortPath];
    NSArray *array_serialport = [[array.rac_sequence map:^id(ORSSerialPort* aport){
        return aport.path;
    }] array];
    if (array_serialport.count > 0) {
         [_pop_serialPort addItemsWithTitles:array_serialport];
    }
    [_pop_serialPort setTitle:[[PublicSerialPort shareInstance] getcurrentSerialPort]];
    [_ComboBox_BandRate addItemsWithObjectValues:[[PublicSerialPort shareInstance] getarray_bandRate]];
    [_ComboBox_BandRate selectItemWithObjectValue:[[PublicSerialPort shareInstance] getcurrentBandRate]];
    [_pop_parity addItemsWithTitles:[[PublicSerialPort shareInstance] getarray_parity]];
    [_pop_parity setTitle:[[PublicSerialPort shareInstance] getcurrentParity]];
    devecePath = [[PublicSerialPort shareInstance] getdevecePath];
    ResetFlag = NO;
    _readUartCondition= 0;
    [_button_burnin setEnabled:NO];
    [_textField_filePath.rac_textSignal subscribeNext:^(id x) {//KVO文件，如文件存在则开始自动读取条件满足1个
        if([[NSFileManager defaultManager] fileExistsAtPath:[_textField_filePath stringValue]]){
            NSError *error;
            NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:[_textField_filePath stringValue] error:&error];
            if (error == nil) {
                _label_name.stringValue = [NSString stringWithFormat:@"文件名称：%@",[[_textField_filePath stringValue] lastPathComponent]];
                _label_size.stringValue = [NSString stringWithFormat:@"文件大小：%@字节(%.2lfK)",[dict valueForKey:@"NSFileSize"],[[dict valueForKey:@"NSFileSize"] intValue]/1024.0];
            }
            self.readUartCondition++;
        }
    }];
    [[RACObserve(self, readUartCondition) skip:1] subscribeNext:^(id x) {//监控开始自动读取c
        if (self.readUartCondition == 2) {//串口打开且有发送文件
            [_button_burnin setEnabled:YES];
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readUartToGetStart:) name:@"debugMessage" object:nil];
    // Do view setup here.
}


- (IBAction)act_search:(id)sender {
    NSArray *array_port = [[ORSSerialPortManager sharedSerialPortManager] availablePorts];
    NSArray *array = [[array_port.rac_sequence map:^id(ORSSerialPort *value){
        return value.path;
    }] array];
    [_pop_serialPort removeAllItems];
    [_pop_serialPort addItemsWithTitles:array];

}

- (IBAction)act_open:(id)sender {
    if ([[_button_open title] isEqualToString:@"打开"]) {//open serial port
        if([[ORSSerialPortInstance shareInstance] openSerialPortWithPath:[_pop_serialPort titleOfSelectedItem] andBandRate:[NSNumber numberWithInt:[[_ComboBox_BandRate objectValueOfSelectedItem] intValue]]]){//open success
            [_Label_Info setStringValue:@"串口打开成功."];
            _Label_Info.textColor = [NSColor purpleColor];
            devecePath = [_pop_serialPort titleOfSelectedItem];
            [[PublicSerialPort shareInstance] setdevecePath:devecePath];
//            [_button_burnin setEnabled:YES];
            self.readUartCondition++;
            //connect ok ,the pority and bandRate will not be change
            [_pop_parity setEnabled:NO];
            [_ComboBox_BandRate setEnabled:NO];
            [_button_open setTitle:@"断开"];
        }else{//if open fail
            [_Label_Info setStringValue:@"串口打开失败，请检查后重试。"];
            _Label_Info.textColor = [NSColor redColor];
        }//end if open success
    }else{// disconnect serial port
        if([[ORSSerialPortInstance shareInstance] closeSerialPortWithPath:devecePath]){//close success
            [_button_open setTitle:@"打开"];
            [_Label_Info setStringValue:@"串口关闭成功。"];
            [_pop_parity setEnabled:YES];
            [_ComboBox_BandRate setEnabled:YES];
            self.readUartCondition--;
        }//end if close success
    }//end open serial port
    
   
}

-(void)readUartToGetStart:(NSNotification *)notification{
    NSDictionary *dict = [notification userInfo];
    if ([[dict valueForKey:@"message"] isKindOfClass:[NSData class]]) {
        NSString *str_uart = [[NSString alloc] initWithData:[dict valueForKey:@"message"] encoding:NSUTF8StringEncoding];
        if ([str_uart isEqualToString:@"C"]) {
            if (self.readUartCondition == 2) {//read C and uart is open and file is ok
                if (_button_burnin.enabled == YES) {
                    ResetFlag = YES;
                    [self act_burnin:nil];
                }
                
            }else{//file is not ok
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:@"却少传送文件，不能开始。"];
                [alert runModal];
            }
            
        }
    }
    
}
- (IBAction)act_burnin:(id)sender {
    NSString *reset = @"RESET";
    [_button_burnin setEnabled:NO];
    continueRead = NO;
    YModemProcess *mainProcess = [[YModemProcess alloc] initWithFileName:[_textField_filePath stringValue] andPort:devecePath];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDate *begintime = [NSDate date];
        [mainProcess mainTest:^(NSString *message){
            [_Label_Info setStringValue:message];
            if ([[_Label_Info stringValue] isEqualToString:@"文件传输中，请等待......"]) {
                _Label_Info.textColor = [NSColor blueColor];
            }else if ([[_Label_Info stringValue] isEqualToString:@"文件传输成功！！!"]){
                [_button_burnin setEnabled:YES];
                ResetFlag = NO;
                _Label_Info.textColor = [NSColor greenColor];
            }
        }andLevelBlock:^(double max,double current){
            if ((max > 0)) {
                [_level_progress setMaxValue:max];
                [_level_progress setDoubleValue:current];
                [_label_percentage setStringValue:[NSString stringWithFormat:@"烧录进度: %d/100 用时:%.2lfs",(int)(100*current/max),[[NSDate date] timeIntervalSinceDate:begintime]]];
            }
        } andTimeOutBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [_Label_Info setStringValue:@"等待超时，请重试!!!"];
                [_button_burnin setEnabled:YES];
                ResetFlag = NO;
                [_Label_Info setTextColor:[NSColor redColor]];
            });
            
        }];
        
    });
    if (ResetFlag == NO) {
        [[ORSSerialPortInstance shareInstance] sendData:[reset dataUsingEncoding:NSUTF8StringEncoding] toPort:devecePath];
    }

}

- (IBAction)act_serialPort:(id)sender {
    [[PublicSerialPort shareInstance] setCurrentSerialPort:_pop_serialPort.titleOfSelectedItem];
}

- (IBAction)act_bandRate:(id)sender {
    [[PublicSerialPort shareInstance] setcurrentBandRate:_ComboBox_BandRate.objectValueOfSelectedItem];
}

- (IBAction)act_parity:(id)sender {
    [[PublicSerialPort shareInstance] setcurrentParity:_pop_parity.titleOfSelectedItem];
}

-(void)viewDidDisappear{
    [[ORSSerialPortInstance shareInstance] closeSerialPortWithPath:devecePath];
}

@end
