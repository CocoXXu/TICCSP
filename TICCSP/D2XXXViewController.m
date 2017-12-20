//
//  D2XXXViewController.m
//  TICCSP
//
//  Created by apple on 17/11/29.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "D2XXXViewController.h"
#import "ResetUserAndPwdController.h"
#import "FileManager.h"
#import "testD2XXX.h"
#import "eeprom.h"
#import "D2XXXWriteAndRead.h"
#import "ftd2xx.h"
#import "YModemProcess.h"
#import "YModemManager.h"

@interface D2XXXViewController ()

@end

@implementation D2XXXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFTDIMessage:) name:@"showFTDIMessage" object:nil];
    ResetUserAndPwdController * resetPwdController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"ResetUserAndPwdController"];
    
    NSString *result = [FileManager YmodelScript:@"YModel.scpt"];
    if ([result isEqualToString:@"The administrator user name or password was incorrect."]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{//解决Xcode线程问题
            [self presentViewControllerAsSheet:resetPwdController];
        });
    }else if ([result isNotEqualTo:@"ok"]){
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:result];
        [alert runModal];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showFTDIMessage" object:self userInfo:nil];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showFTDIMessage" object:self userInfo:nil];
    }
    NSArray *array_bandRate = [NSArray arrayWithObjects:@"115200",@"9600",@"14400",@"19200",@"38400",@"300",@"600",@"1200",@"2400",@"4800",@"230400",@"460800",@"921600", nil];
    [_ComboBox_bandRate removeAllItems];
    [_ComboBox_bandRate addItemsWithObjectValues:array_bandRate];
    [_ComboBox_bandRate selectItemAtIndex:0];
    [_pop_parity removeAllItems];
    [_pop_parity addItemsWithTitles:[NSArray arrayWithObjects:@"NONE",@"ODD",@"EVEN", nil]];

    // Do view setup here.
}
-(void)showFTDIMessage:(NSNotification *)info{
    char allFiture[50][64];
    int deviceNum;
    int num = mainGet(allFiture,deviceNum);
    [_pop_serialPort removeAllItems];
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < num; i++) {
        if ([NSString stringWithUTF8String:allFiture[i]] == nil) {
            continue;
        }
        [items addObject:[NSString stringWithUTF8String:allFiture[i]]];
    }
    [_pop_serialPort addItemsWithTitles:items];
    if ([items count] > 0) {
        [_pop_serialPort setTitle:items[0]];
    }else{
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"请检查串口线连接ok后重试。"];
        [alert runModal];
    }
}
- (IBAction)act_search:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showFTDIMessage" object:self userInfo:nil];
}

- (IBAction)act_open:(id)sender{
    [_button_open setTitle:@"断开"];
    D2XXXWriteAndRead *aWriteAndRead =[[D2XXXWriteAndRead alloc] initWithPortNameAndBaudRate:[_pop_serialPort titleOfSelectedItem] and:[_ComboBox_bandRate objectValueOfSelectedItem] andShowResult:^(NSString * message){
        [_button_open setTitle:@"打开"];
        _Label_Info.stringValue = message;
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *date_source_array = [[YModemManager shareInstance] preparePacketWithFileName:@"/Users/apple/Documents/project/TestORSSerialPort/YModel Document/STM32F103.hex"];
        NSDate *beginTime = [NSDate date];
        [aWriteAndRead writeData:[@"start,@" dataUsingEncoding:NSUTF8StringEncoding]];
//        [NSThread sleepForTimeInterval:1];
        for (int i = 0; i < date_source_array.count; i++) {
            BOOL status = [aWriteAndRead writeData:date_source_array[i]];
//            [NSThread sleepForTimeInterval:0.5];
            NSLog(@"%d == %@",status,date_source_array[i]);
//            break;
        }
        [aWriteAndRead writeData:[@"end,@" dataUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"totol time %f",[[NSDate date] timeIntervalSinceDate:beginTime]);
    });
}
- (IBAction)act_burnin:(id)sender{
//    NSString *reset = @"RESET";
//    [_button_burnin setEnabled:NO];
//    YModemProcess *mainProcess = [[YModemProcess alloc] initWithFileName:[_label_filepath stringValue] andPort:devecePath];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [mainProcess mainTest:^(NSString *message){
//            [_Label_Info setStringValue:message];
//            if ([[_Label_Info stringValue] isEqualToString:@"文件传输中，请等待......"]) {
//                _Label_Info.textColor = [NSColor blueColor];
//            }else if ([[_Label_Info stringValue] isEqualToString:@"文件传输成功！！!"]){
//                [_button_burnin setEnabled:YES];
//                ResetFlag = NO;
//                _Label_Info.textColor = [NSColor greenColor];
//            }
//        }andLevelBlock:^(double max,double current){
//            if ((max > 0)) {
//                [_level_progress setMaxValue:max];
//                [_level_progress setDoubleValue:current];
//                [_label_percentage setStringValue:[NSString stringWithFormat:@"烧录进度: %d/100",(int)(100*current/max)]];
//            }
//        } andTimeOutBlock:^{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [_Label_Info setStringValue:@"等待超时，请重试!!!"];
//                [_button_burnin setEnabled:YES];
//                ResetFlag = NO;
//                [_Label_Info setTextColor:[NSColor redColor]];
//            });
//            
//        }];
//        
//    });
//    if (ResetFlag == NO) {
//        [[ORSSerialPortInstance shareInstance] sendData:[reset dataUsingEncoding:NSUTF8StringEncoding] toPort:devecePath];
//    }
}
@end
