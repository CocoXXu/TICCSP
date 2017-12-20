//
//  ConfirmKeyWord.m
//  TICCSP
//
//  Created by apple on 17/12/12.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "ConfirmKeyWord.h"
#import "ConfigFunction.h"

@interface ConfirmKeyWord ()

@end

@implementation ConfirmKeyWord

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)ActCancel:(id)sender {
    [self dismissViewController:self];
}

- (IBAction)ActOK:(id)sender {
    
    if ([_tKeyWord.stringValue isEqualToString:@"rhac888"]) {
        ConfigFunction * configFunction = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"ConfigFunction"];
        [self presentViewControllerAsModalWindow:configFunction];
        [self dismissViewController:self];
        
    }
}


@end
