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
//    NSLog(@"%@",maVirsualConfig);
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
    @synchronized (maVirsualConfig) {
        return maVirsualConfig.count;
    }
    
}
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    @synchronized (maVirsualConfig) {
         return [maVirsualConfig[row] valueForKey:tableColumn.identifier];
    }
   
    
}

-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if ([[tableColumn identifier] isEqualToString:@"clickMode"]) {
        NSPopUpButtonCell *cell = [tableColumn dataCellForRow:row];
        NSArray *array = cell.itemArray;
        NSMenuItem *item = [array objectAtIndex:[object intValue]];
        @synchronized (maVirsualConfig) {
            [maVirsualConfig[row] setValue:item.title forKey:@"clickMode"];
        }
        
    }else{
        @synchronized (maVirsualConfig) {
            [maVirsualConfig[row] setValue:object forKey:tableColumn.identifier];
        }
        
    }

}


- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if ([[aTableColumn identifier] isEqualToString:@"clickMode"])
    {
        @synchronized (maVirsualConfig) {
            [aCell setTitle:[maVirsualConfig[rowIndex] valueForKey:aTableColumn.identifier]];
        }
        
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
            [self readDataFromUart];
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
            aDevice = nil;
        }//end if close success
    }//end open serial port
}

- (IBAction)act_add:(id)sender {
    for(int i = 0;i <9999;i++){
        NSString *key = [NSString stringWithFormat:@"test%d",i];
        bool bName = NO;
        @synchronized (maVirsualConfig) {
            for (NSDictionary *dict in maVirsualConfig) {
                if( [[dict valueForKey:@"key"] isEqualToString:key]){
                    bName = YES;
                    break;
                }
            }

        }
        if (bName == NO) {
            NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:key,@"key",key,@"keyin",@"NONE",@"clickMode",@"0.0",@"LocationX",@"0.0",@"LocationY", nil];
            @synchronized (maVirsualConfig){
                [maVirsualConfig addObject:newDict];
            }
            
            [_mytableView reloadData];
            break;
        }
    }
}

- (IBAction)act_remove:(id)sender {
    NSInteger index = [_mytableView selectedRow];
    @synchronized (maVirsualConfig) {
        [maVirsualConfig removeObjectAtIndex:index];
    }
    
    [_mytableView reloadData];
}

- (IBAction)act_save:(id)sender {
    [FileManager SaveCommandToJsonFile:maVirsualConfig andFileName:@"virsualKeyConfig"];
}

-(void)readDataFromUart{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableData *mData = [[NSMutableData alloc] initWithCapacity:0];
        while (aDevice) {
            NSData *data = [aDevice readData];
            [mData appendData:data];
            NSString *str = [[NSString alloc] initWithData:mData encoding:NSUTF8StringEncoding];
            @synchronized (maVirsualConfig) {
                for (NSDictionary *dict in maVirsualConfig) {
                    if ([[dict valueForKey:@"key"] isEqualToString:str]) {
                        [self doVirsualWithKey:dict];
                        [mData resetBytesInRange:NSMakeRange(0, [mData length])];
                        [mData setLength:0];
                        break;
                    }
                }
            }
            
        }
    });
}

-(void)doVirsualWithKey:(NSDictionary *)dict{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:2];
        float locationX = [[dict valueForKey:@"LocationX"] floatValue];
        float locationY = [[dict valueForKey:@"LocationY"] floatValue];
        NSString *sWrite = [dict valueForKey:@"keyin"];
        [self writeString:sWrite withFlags:0];
        
        CGPoint pt = CGPointMake(locationX, locationY);
        if ([[dict valueForKey:@"clickMode"] isEqualToString:@"LeftMouseClick"]) {
            PostMouseEvent(kCGMouseButtonLeft, kCGEventLeftMouseDown, pt);
            PostMouseEvent(kCGMouseButtonLeft, kCGEventLeftMouseUp, pt);
        }else if ([[dict valueForKey:@"clickMode"] isEqualToString:@"RightMouseClick"]){
            PostMouseEvent(kCGMouseButtonRight, kCGEventRightMouseDown, pt);
            PostMouseEvent(kCGMouseButtonRight, kCGEventRightMouseUp, pt);
        }else if ([[dict valueForKey:@"clickMode"] isEqualToString:@"RightMouseDoubleClick"]){
//            PostMouseEvent(kCGMouseButtonLeft, kCGEventLeftMouseDown, pt);
//            PostMouseEvent(kCGMouseButtonLeft, kCGEventLeftMouseUp, pt);
////            [NSThread sleepForTimeInterval:0.2];
//            PostMouseEvent(kCGMouseButtonLeft, kCGEventLeftMouseDown, pt);
//            PostMouseEvent(kCGMouseButtonLeft, kCGEventLeftMouseUp, pt);
            [self doubleClick:2 andPoint:pt];
        }
    });
}

-(void) doubleClick:(int)clickCount andPoint:(CGPoint) point {
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, point, kCGMouseButtonLeft);
    CGEventSetIntegerValueField(theEvent, kCGMouseEventClickState, clickCount);
    CGEventPost(kCGHIDEventTap, theEvent);
    CGEventSetType(theEvent, kCGEventLeftMouseUp);
    CGEventPost(kCGHIDEventTap, theEvent);
    CGEventSetType(theEvent, kCGEventLeftMouseDown);
    CGEventPost(kCGHIDEventTap, theEvent);
    CGEventSetType(theEvent, kCGEventLeftMouseUp);
    CGEventPost(kCGHIDEventTap, theEvent);
    CFRelease(theEvent);
}

void PostMouseEvent(CGMouseButton button, CGEventType type, const CGPoint point)
{
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, type, point, button);
    CGEventSetType(theEvent, type);
    CGEventPost(kCGHIDEventTap, theEvent);
    CFRelease(theEvent);
}

-(void)writeString:(NSString *)valueToSet withFlags:(int)flags
{
    UniChar buffer;
    CGEventRef keyEventDown = CGEventCreateKeyboardEvent(NULL, 1, true);
    CGEventRef keyEventUp = CGEventCreateKeyboardEvent(NULL, 1, false);
    CGEventSetFlags(keyEventDown,0);
    CGEventSetFlags(keyEventUp,0);
    for (int i = 0; i < [valueToSet length]; i++) {
        [valueToSet getCharacters:&buffer range:NSMakeRange(i, 1)];
        CGEventKeyboardSetUnicodeString(keyEventDown, 1, &buffer);
        CGEventSetFlags(keyEventDown,flags);
        CGEventPost(kCGSessionEventTap, keyEventDown);
        CGEventKeyboardSetUnicodeString(keyEventUp, 1, &buffer);
        CGEventSetFlags(keyEventUp,flags);
        CGEventPost(kCGSessionEventTap, keyEventUp);
        
    }
    CFRelease(keyEventUp);
    CFRelease(keyEventDown);
}

@end
