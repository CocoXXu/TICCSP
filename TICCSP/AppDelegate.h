//
//  AppDelegate.h
//  TICCSP
//
//  Created by apple on 17/10/24.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>



- (IBAction)setLogSIze5K:(id)sender ;
- (IBAction)setLogSize10K:(id)sender;
- (IBAction)setLogSize100K:(id)sender;
- (IBAction)setLogSize1M:(id)sender;
- (IBAction)setLogSize5M:(id)sender;
- (IBAction)importConfigFile:(id)sender;
- (IBAction)saveConfigFile:(id)sender;

@property (weak) IBOutlet NSMenu *menu_logsize;

@end

