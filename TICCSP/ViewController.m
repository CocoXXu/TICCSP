//
//  ViewController.m
//  TICCSP
//
//  Created by apple on 17/10/24.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "ViewController.h"
#import <AppKit/AppKitDefines.h>


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    rectbuttonSerialPort =_buttonSerialPort.frame;
    rectbuttonUpdateBoard = _buttonUpdateBoard.frame;
    rectbuttonBurninLine = _buttonBurninLine.frame;
    rectbuttonSocketServer = _buttonSocketServer.frame;
    rectbuttonSocketClient = _buttonSocketClient.frame;
    rectbuttonD2XXX = _buttonD2XXX.frame;
    NSString *file = [NSString stringWithFormat:@"%@/config.txt",[[NSBundle mainBundle] resourcePath] ];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        NSData *base64Data = [NSData dataWithContentsOfFile:file];
        // 解密 base64 数据
        NSData *baseData = [[NSData alloc] initWithBase64EncodedData:base64Data options:0];
        int iConfig = [[[NSString alloc] initWithData:baseData encoding:NSUTF8StringEncoding] intValue];
        [self updateWithConfig:iConfig];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNotification:) name:@"getNotification" object:nil];
    // Do any additional setup after loading the view.
}

-(void)getNotification:(NSNotification *)noti{
    NSDictionary *dict = [noti userInfo];
    int iconfig = [[dict valueForKey:@"message"] intValue];
    [self updateWithConfig:iconfig];
}

-(void)updateWithConfig:(int)iConfig{
    NSMutableArray *arrayButton = [[NSMutableArray alloc] initWithCapacity:0];
    _buttonSerialPort.hidden = !(iConfig/100000);
    if (_buttonSerialPort.hidden == NO) {
        [arrayButton addObject:_buttonSerialPort];
    }
    iConfig = iConfig%100000;
    _buttonUpdateBoard.hidden = !(iConfig/10000);
    if (_buttonUpdateBoard.hidden == NO) {
        [arrayButton addObject:_buttonUpdateBoard];
    }

    iConfig = iConfig%10000;
    _buttonBurninLine.hidden = !(iConfig/1000);
    if (_buttonBurninLine.hidden == NO) {
        [arrayButton addObject:_buttonBurninLine];
    }
    iConfig = iConfig%1000;
    _buttonSocketServer.hidden = !(iConfig/100);
    if (_buttonSocketServer.hidden == NO) {
        [arrayButton addObject:_buttonSocketServer];
    }
    iConfig = iConfig%100;
    _buttonSocketClient.hidden = !(iConfig/10);
    if (_buttonSocketClient.hidden == NO) {
        [arrayButton addObject:_buttonSocketClient];
    }
    _buttonD2XXX.hidden = !(iConfig%10);
    if (_buttonD2XXX.hidden == NO) {
        [arrayButton addObject:_buttonD2XXX];
    }
    
    
    for (int i = 0; i < arrayButton.count; i++) {
        NSLayoutConstraint *top;
        if (i==0) {
            [[arrayButton[i] superview] removeConstraints:[arrayButton[i] superview].constraints];
            top=  [NSLayoutConstraint constraintWithItem:arrayButton[i] attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[arrayButton[i] superview] attribute:NSLayoutAttributeTop multiplier:1 constant:20];
            
        }
        else{
            top = [NSLayoutConstraint constraintWithItem:arrayButton[i] attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:arrayButton[i-1] attribute:NSLayoutAttributeBottom multiplier:1 constant:20];
        }
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:arrayButton[i] attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:[arrayButton[i] superview] attribute:NSLayoutAttributeLeft multiplier:1 constant:80];
        left.active = YES;
        top.active = YES;
    }

    
}

@end
