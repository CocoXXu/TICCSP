//
//  ResetUserAndPwd.m
//  TICCSP
//
//  Created by apple on 17/11/3.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "ResetUserAndPwdController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "FileManager.h"

@interface ResetUserAndPwdController ()

@end

@implementation ResetUserAndPwdController

- (void)viewDidLoad {
    [super viewDidLoad];
//    flagValue = @"ok";
    NSString *userName = NSUserName() ;
    [_TF_userName setStringValue:userName];
    [_TF_passWord setDelegate:self];
    [_TF_userName setDelegate:self];
    // Do view setup here.
}

- (IBAction)Act_commit:(id)sender {
    
    NSString *loadScript = [NSString stringWithFormat:@"-- Set user name and password\nset UserName to \"%@\"\nset MyPASSWORD to \"%@\"\n-- load FTDIUSBSerialDriver\ndo shell script \"sudo kextload -b com.apple.driver.AppleUSBFTDI\" user name UserName password MyPASSWORD with administrator privileges",[_TF_userName stringValue],[_TF_passWord stringValue]];
    NSString *loadscriptpath = [[NSBundle mainBundle] pathForResource:@"YModelLoad.scpt" ofType:nil];
    [loadScript writeToFile:loadscriptpath atomically:YES]; //load

    NSString *unloadScript = [NSString stringWithFormat:@"--Set user name and password\nset UserName to \"%@\"\nset MyPASSWORD to \"%@\"\n-- unload FTDIUSBSerialDriver\ndo shell script \"sudo kextunload -b com.apple.driver.AppleUSBFTDI\" user name UserName password MyPASSWORD with administrator privileges\ndo shell script \"sudo rm -rf System/Library/Extensions/FTDIUSBSerialDriver.kext\" user name UserName password MyPASSWORD with administrator privileges",[_TF_userName stringValue],[_TF_passWord stringValue]];
    NSString *scriptpath = [[NSBundle mainBundle] pathForResource:@"YModel.scpt" ofType:nil];
    [unloadScript writeToFile:scriptpath atomically:YES];//unload
    NSString *sciptpath = @"YModel.scpt";
    NSString *failMessage = @"Failed to unload com.apple.driver.AppleUSBFTDI";
    if ([flagValue isEqualToString:@"close"]) {
        sciptpath =@"YModelLoad.scpt";
        failMessage=@"Failed to load com.apple.driver.AppleUSBFTDI";
    }
    NSString *result = [FileManager YmodelScript:sciptpath];
    if ([result isEqualToString:@"ok"] || [result rangeOfString:failMessage].location != NSNotFound) {//unload执行成功
        if (flagValue==nil ) {
            [self dismissViewController:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showFTDIMessage" object:self userInfo:nil];
        }else{
            [self.view.window performClose:nil];
        }
    }else{
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:result];
        [alert runModal];
    }
}



-(void)controlTextDidEndEditing:(NSNotification *)obj{
    NSTextField *field = (NSTextField *)[obj object];
    if ([[field identifier] isEqualToString:@"name"]) {
        [_TF_userName setRefusesFirstResponder:YES];
        [_TF_passWord setRefusesFirstResponder:NO];
    }else{
        [_TF_userName setRefusesFirstResponder:NO];
        [_TF_passWord setRefusesFirstResponder:YES];
        [self Act_commit:nil];
    }
}
@end
