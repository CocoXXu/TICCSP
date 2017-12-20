//
//  ConfigFunction.m
//  TICCSP
//
//  Created by apple on 17/12/12.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "ConfigFunction.h"
#import "InputBox.h"
@interface ConfigFunction ()

@end

@implementation ConfigFunction

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *file = [NSString stringWithFormat:@"%@/config.txt",[[NSBundle mainBundle] resourcePath] ];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        NSData *base64Data = [NSData dataWithContentsOfFile:file];
        
        // 解密 base64 数据
        NSData *baseData = [[NSData alloc] initWithBase64EncodedData:base64Data options:0];
        int iConfig = [[[NSString alloc] initWithData:baseData encoding:NSUTF8StringEncoding] intValue];
        _buttonSerialPort.state = iConfig/100000;
        iConfig = iConfig%100000;
        _buttonUpdateBoard.state = iConfig/10000;
        iConfig = iConfig%10000;
        _buttonBurninLine.state = iConfig/1000;
        iConfig = iConfig%1000;
        _buttonSocketServer.state = iConfig/100;
        iConfig = iConfig%100;
        _buttonSocketClient.state = iConfig/10;
        _buttonD2XXX.state = iConfig%10;
    }
    // Do view setup here.
}
-(BOOL)showMessageBoxToGetAcess:(NSString *)message{
    NSAlert* alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:message];
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setEditable:YES];
    [input setStringValue:message];
    [alert setAccessoryView:input];
    [[alert window]setInitialFirstResponder:input];
    NSModalResponse responce = [alert runModal];
    BOOL result = NO;
    if (responce) {
        if ([[input stringValue] isEqualToString:@"rhac888"]) {
            result = YES;
        }
    }
    return result;
}
- (IBAction)actSetConfig:(id)sender {
    NSString *file = [NSString stringWithFormat:@"%@/config.txt",[[NSBundle mainBundle] resourcePath] ];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] == NO) {
        [[NSFileManager defaultManager] createFileAtPath:file contents:nil attributes:nil];
    }
    NSString *strCongig = [NSString stringWithFormat:@"%ld%ld%ld%ld%ld%ld",(long)_buttonSerialPort.state,(long)_buttonUpdateBoard.state,(long)_buttonBurninLine.state,(long)_buttonSocketServer.state,(long)_buttonSocketClient.state,_buttonD2XXX.state];
    NSData *data = [strCongig dataUsingEncoding:NSUTF8StringEncoding];
    NSData *base64Data = [data base64EncodedDataWithOptions:0];;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getNotification" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:strCongig,@"message", nil]];
    
    
    
    // 写入文件
    [base64Data writeToFile:file atomically:YES];
}

@end
