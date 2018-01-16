//
//  VirtualKeyboardViewController.m
//  TICCSP
//
//  Created by apple on 18/1/16.
//  Copyright © 2018年 coco. All rights reserved.
//

#import "VirtualKeyboardViewController.h"
#import "FileManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PublicSerialPort.h"

@interface VirtualKeyboardViewController ()

@end

@implementation VirtualKeyboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    statusItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setTitle:@""];
    [statusItem setHighlightMode:YES];
    
    [_mytableView setDelegate:self];
    [_mytableView setDataSource:self];
    
    [_pop_serialPort removeAllItems];
    [_pop_parity removeAllItems];
    [_comboBoxBandRate removeAllItems];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[fileManage contentsOfDirectoryAtPath:@"/dev/" error:nil]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS 'cu.'"];
    [array filterUsingPredicate:predicate];
    NSArray *array_serialport = [[array.rac_sequence map:^id(NSString* aport){
        return [NSString stringWithFormat:@"/dev/%@",aport];
    }] array];
    if (array.count > 0) {
        [_pop_serialPort addItemsWithTitles:array_serialport];
        [_pop_serialPort setTitle:array_serialport[0]];
    }
    [_comboBoxBandRate addItemsWithObjectValues:[[PublicSerialPort shareInstance] getarray_bandRate]];
    [_comboBoxBandRate selectItemAtIndex:0];
    
    [_pop_parity addItemsWithTitles:[[PublicSerialPort shareInstance] getarray_parity]];
    [_pop_parity setTitle:@"NONE"];

    
    
    NSString *virsualJson = [[NSBundle mainBundle] pathForResource:@"virsualKeyConfig" ofType:@"json"];
    maVirsualConfig = [[NSMutableArray alloc] initWithArray:[FileManager GetCommandArrayFromCommandJsonWithPath:virsualJson]];
    NSLog(@"%@",maVirsualConfig);
    // Do view setup here.
}

- (IBAction)ActMeasure:(id)sender {
    
    if ([[_buttonMeasureLocation title] isEqualToString:@"开始量测坐标"]) {//start to locate
        [_buttonMeasureLocation setTitle:@"结束量测坐标"];
        globalmouseEvent = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask | NSRightMouseDownMask | NSMouseMovedMask | NSLeftMouseDraggedMask | NSRightMouseDraggedMask handler:^(NSEvent *event) {
            CGEventRef ourEvent = CGEventCreate(NULL);
            CGPoint point = CGEventGetLocation(ourEvent);
            //        switch (event.type) {
            //            case NSLeftMouseDown:
            //                NSLog(@"left mouse down x=%f,y=%f",)
            //                break;
            //            case NSRightMouseDown:
            //                text = [[NSString alloc] initWithFormat:@"%d", ++rightClicked];
            //                rightClickedText.stringValue = text;
            //                break;
            //            case NSMouseMoved:
            //            case NSLeftMouseDragged:
            //            case NSRightMouseDragged:
            //                delta = (NSInteger)sqrt(event.deltaX * event.deltaX + event.deltaY * event.deltaY);
            //                moved += delta;
            //                text = [[NSString alloc] initWithFormat:@"%d px", moved];
            //                movedText.stringValue = text;
            //                break;
            //            default:
            //                break;
            //        }
            [statusItem setTitle:[NSString stringWithFormat:@"x=%.2f,y=%.2f",point.x,point.y]];
            NSLog(@"%lu Location? x= %f, y = %f", (unsigned long)event.type,(float)point.x, (float)point.y);
        }];
        loacalmouseEvent = [NSEvent addLocalMonitorForEventsMatchingMask:NSLeftMouseDownMask | NSRightMouseDownMask | NSMouseMovedMask | NSLeftMouseDraggedMask | NSRightMouseDraggedMask handler:^(NSEvent *event){
            CGEventRef ourEvent = CGEventCreate(NULL);
            CGPoint point = CGEventGetLocation(ourEvent);
            [statusItem setTitle:[NSString stringWithFormat:@"x=%.2f,y=%.2f",point.x,point.y]];
            NSLog(@"%lu Location? x= %f, y = %f", (unsigned long)event.type,(float)point.x, (float)point.y);
            return event;
        }];
    }else{//end locate
        [_buttonMeasureLocation setTitle:@"开始量测坐标"];
        [NSEvent removeMonitor:globalmouseEvent];
        [NSEvent removeMonitor:loacalmouseEvent];
        [statusItem setTitle:@""];
    }
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return maVirsualConfig.count;
}
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return [maVirsualConfig[row] valueForKey:tableColumn.identifier];
    
}

-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if ([[tableColumn identifier] isEqualToString:@"clickMode"]) {
        NSPopUpButtonCell *cell = [tableColumn dataCellForRow:row];
        NSArray *array = cell.itemArray;
        NSMenuItem *item = [array objectAtIndex:[object intValue]];
        [maVirsualConfig[row] setValue:item.title forKey:@"clickMode"];
    }else{
        [maVirsualConfig[row] setValue:object forKey:tableColumn.identifier];
    }

}


- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if ([[aTableColumn identifier] isEqualToString:@"clickMode"])
    {
        [aCell setTitle:[maVirsualConfig[rowIndex] valueForKey:aTableColumn.identifier]];
    }
    
}

- (IBAction)act_search:(id)sender {
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[fileManage contentsOfDirectoryAtPath:@"/dev/" error:nil]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS 'cu.'"];
    [array filterUsingPredicate:predicate];
    NSArray *array_serialport = [[array.rac_sequence map:^id(NSString* aport){
        return [NSString stringWithFormat:@"/dev/%@",aport];
    }] array];
    [_pop_serialPort removeAllItems];
    if (array.count > 0) {
        [_pop_serialPort addItemsWithTitles:array_serialport];
        [_pop_serialPort setTitle:array_serialport[0]];
    }
}

- (IBAction)act_open:(id)sender {
    if ([[_button_open title] isEqualToString:@"打开"]) {//open serial port
        aDevice = [[UartDevice alloc] initWithDevice:[_pop_serialPort titleOfSelectedItem] andBandRate:[_comboBoxBandRate objectValueOfSelectedItem] andParity:[_pop_parity titleOfSelectedItem]];
        if(aDevice != nil)
        {//open success
            
            devecePath = [_pop_serialPort titleOfSelectedItem];
            [[PublicSerialPort shareInstance] setdevecePath:devecePath];
            
            //connect ok ,the pority and bandRate will not be change
            [_pop_parity setEnabled:NO];
            [_comboBoxBandRate setEnabled:NO];
            [_button_open setTitle:@"断开"];
        }else{//if open fail
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"open fail"];
            [alert runModal];
        }//end if open success
    }else{// disconnect serial port
        if([aDevice close]){//close success
            [_button_open setTitle:@"打开"];
            [_pop_parity setEnabled:YES];
            [_comboBoxBandRate setEnabled:YES];
        }//end if close success
    }//end open serial port
}
@end
