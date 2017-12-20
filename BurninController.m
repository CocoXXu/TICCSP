//
//  BurninController.m
//  TICCSP
//
//  Created by apple on 17/11/2.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "BurninController.h"
#import "ResetUserAndPwdController.h"
#import "FileManager.h"
#import "eeprom.h"
#import "testD2XXX.h"

@interface BurninController ()

@end

@implementation BurninController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    // Do view setup here.
}
-(void)showFTDIMessage:(NSNotification *)info{
    char allFiture[50][64];
    int deviceNum;
    int num = mainGet(allFiture,deviceNum);
    [_PopUp_FTDI removeAllItems];
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < num; i++) {
        if ([NSString stringWithUTF8String:allFiture[i]] == nil) {
            continue;
        }
        [items addObject:[NSString stringWithUTF8String:allFiture[i]]];
    }
    [_PopUp_FTDI addItemsWithTitles:items];
    if ([items count] > 0) {
        [_PopUp_FTDI setTitle:items[0]];
        [self select_serial:nil];
    }else{
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"请检查串口线连接ok后重试。"];
        [alert runModal];
    }
}
- (IBAction)getInfo:(id)sender {
    testWrite();
    return;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showFTDIMessage" object:self userInfo:nil];
}

- (IBAction)fixDesc:(id)sender {
    
    mainWriteDesciption([[_PopUp_FTDI titleOfSelectedItem] UTF8String] , [[_label_description stringValue] UTF8String]);
}

- (IBAction)fixSerialNum:(id)sender {
    
    mainWriteName([[_PopUp_FTDI titleOfSelectedItem] UTF8String] , [[_label_serialnum stringValue] UTF8String]);
}

-(void)viewWillDisappear{
    NSString *result = [FileManager YmodelScript:@"YModelLoad.scpt"];
//    ResetUserAndPwdController * resetPwdController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"ResetUserAndPwdController"];
    [self performSegueWithIdentifier:@"resetUserAndPwd" sender:self];
    if ([result isEqualToString:@"The administrator user name or password was incorrect."]) {
        [self performSegueWithIdentifier:@"resetUserAndPwd" sender:self];
    }else if ([result isNotEqualTo:@"ok"]){
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:result];
        [alert runModal];
    }
}

-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier compare:@"resetUserAndPwd"]==NO)
    {
        id page2=segue.destinationController;
        [page2 setValue:@"close" forKey:@"flagValue"];
    }
}

- (IBAction)select_serial:(id)sender {
    char *oldsn = [[_PopUp_FTDI titleOfSelectedItem] UTF8String];
    char newsn[128] ;
    char Manufacturer[128];
    char ProductId[128];
    char VendorId[128];
    char Description[128];
    mainReadWithName(oldsn,Description,ProductId,VendorId,Manufacturer,newsn);
    //    mainReadWithName(oldsn,Data);
    [_label_MI setStringValue:[NSString stringWithFormat:@"%s",Manufacturer]];
    [_label_PID setStringValue:[NSString stringWithFormat:@"0x%s",ProductId]];
    [_label_VID setStringValue:[NSString stringWithFormat:@"0x%s",VendorId]];
    [_label_serialnum setStringValue:[NSString stringWithFormat:@"%s",newsn]];
    [_label_description setStringValue:[NSString stringWithFormat:@"%s",Description]];
}

@end
