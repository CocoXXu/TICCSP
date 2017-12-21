//
//  AppDelegate.m
//  TICCSP
//
//  Created by apple on 17/10/24.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "AppDelegate.h"
#import "SerialPortController.h"
#import "FileManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSDictionary *dConfig = [FileManager getConfigFromConfigJson];
    int fileSize = [[dConfig valueForKey:@"filesize"] intValue];
    for (NSMenuItem *aitem in [_menu_logsize itemArray]) {
        [aitem setState:0];
    }
    switch (fileSize) {
        case 5*1024:
            [[_menu_logsize itemArray][0] setState:1];
            break;
        case 10*1024:
            [[_menu_logsize itemArray][1] setState:1];
            break;
            
        case 100*1024:
            [[_menu_logsize itemArray][2] setState:1];
            break;
            
        case 1024*1024:
            [[_menu_logsize itemArray][3] setState:1];
            break;
        case 5*1024*1024:
            [[_menu_logsize itemArray][4] setState:1];
            break;
            
        default:
            break;
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
    // Insert code here to tear down your application
}
- (IBAction)setLogSIze5K:(id)sender {
    for (NSMenuItem *aitem in [_menu_logsize itemArray]) {
        [aitem setState:0];
    }
    NSMenuItem *item = (NSMenuItem *)sender;
    [item setState:1];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"menuMessage" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"size",@"user",[NSNumber numberWithInt:5*1024],@"message", nil]];
}

- (IBAction)setLogSize10K:(id)sender {
    for (NSMenuItem *aitem in [_menu_logsize itemArray]) {
        [aitem setState:0];
    }
    NSMenuItem *item = (NSMenuItem *)sender;
    [item setState:1];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"menuMessage" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"size",@"user",[NSNumber numberWithInt:10*1024],@"message", nil]];
//    fileSize = 10*1024;
}

- (IBAction)setLogSize100K:(id)sender {
    for (NSMenuItem *aitem in [_menu_logsize itemArray]) {
        [aitem setState:0];
    }
    NSMenuItem *item = (NSMenuItem *)sender;
    [item setState:1];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"menuMessage" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"size",@"user",[NSNumber numberWithInt:100*1024],@"message", nil]];
//    fileSize = 100*1024;
}

- (IBAction)setLogSize1M:(id)sender {
    for (NSMenuItem *aitem in [_menu_logsize itemArray]) {
        [aitem setState:0];
    }
    NSMenuItem *item = (NSMenuItem *)sender;
    [item setState:1];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"menuMessage" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"size",@"user",[NSNumber numberWithInt:1024*1024],@"message", nil]];
//    fileSize = 1024*1024;
}

- (IBAction)setLogSize5M:(id)sender {
    for (NSMenuItem *aitem in [_menu_logsize itemArray]) {
        [aitem setState:0];
    }
    NSMenuItem *item = (NSMenuItem *)sender;
    [item setState:1];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"menuMessage" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"size",@"user",[NSNumber numberWithInt:5*1024*1024],@"message", nil]];
//    fileSize = 5*1024*1024;
}
-(NSString *)get_fullpath
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    NSArray* fileTypes = [[NSArray alloc] initWithObjects:@"txt",@"doc",@"json", nil];
    [panel setMessage:@"Select a config file"];
    [panel setPrompt:@"OK"];
    [panel setCanChooseDirectories:NO];
    [panel setCanCreateDirectories:YES];
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:YES];
    
    [panel setAllowedFileTypes:fileTypes];
    NSString *path_all=@"";
    NSInteger result = [panel runModal];
    if (result ==NSFileHandlingPanelOKButton)
    {
        NSArray *select_files = [panel filenames] ;
        for (int i=0; i<select_files.count; i++)
        {
            path_all= [select_files objectAtIndex:i];
        }
    }
    return path_all;
}

- (IBAction)importConfigFile:(id)sender {
    NSString *file = [self get_fullpath];
    NSArray *array = [FileManager GetCommandArrayFromCommandJsonWithPath:file];
    if (array != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"menuMessage" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"getnewCommand",@"user",array,@"message", nil]];

    }
}

- (IBAction)saveConfigFile:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"menuMessage" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"setnewCommand",@"user",@"",@"message", nil]];

}



@end
