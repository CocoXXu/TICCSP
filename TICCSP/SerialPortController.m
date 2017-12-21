//
//  SerialPortController.m
//  TICCSP
//
//  Created by apple on 17/11/2.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "SerialPortController.h"
#import "PublicSerialPort.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "InputBox.h"
#import "FileManager.h"
#import "CycleRunProcess.h"

@interface SerialPortController ()

@end

@implementation SerialPortController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [_pop_serialPort removeAllItems];
    [_pop_parity removeAllItems];
    [_comboBoxBandRate removeAllItems];
    [_myTableView setDelegate:self];
    [_myTableView setDataSource:self];
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
    
    devecePath = [[PublicSerialPort shareInstance] getdevecePath];
    
    _array_command = [[NSMutableArray alloc] initWithArray:[FileManager GetCommandArrayFromCommandJson]];
    for (int i = 0; i < _array_command.count; i++) {
        if ([[_array_command[i] valueForKey:@"checkState"] intValue] == 1) {
            [_button_chooseNone setState:0];
        }else{
            [_button_chooseAll setState:0];
        }
        
        if ([[_array_command[i] valueForKey:@"isHex"] boolValue]) {
            [_button_hex setState:1];
        }
    }
    NSDictionary *dConfig = [FileManager getConfigFromConfigJson];
    fileSize = [[dConfig valueForKey:@"filesize"] intValue];

    if (fileSize == 0) {
        fileSize = 10*1024;
    }
    [_myTableView reloadData];
    [_myTableView setDoubleAction:@selector(doubleClick:)];
    [_button_cell setEnabled:NO];
    [_button_send setEnabled:NO];
    [_button_cycleSend setEnabled:NO];
    [_comboBoxBandRate setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDebugMessage:) name:@"debugMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuMessage:) name:@"menuMessage" object:nil];
    

}
-(void)menuMessage:(NSNotification *)info{
    NSDictionary *dict = [info userInfo];
    if ([[dict valueForKey:@"user"] isEqualToString:@"size"]) {
        fileSize = [[dict valueForKey:@"message"] intValue];
        NSDictionary *dConfig= [FileManager getConfigFromConfigJson];
        [dConfig setValue:[NSNumber numberWithInt:fileSize] forKey:@"filesize"];
        [FileManager saveConfigFromConfigJson:dConfig];
        
    }else if ([[dict valueForKey:@"user"] isEqualToString:@"getnewCommand"]){
        _array_command = [NSMutableArray arrayWithArray:[dict valueForKey:@"message"]];
        [_myTableView reloadData];
    }else if ([[dict valueForKey:@"user"] isEqualToString:@"setnewCommand"]){
        [FileManager SaveCommandToCommandJson:_array_command];
    }
    
}
-(void)textViewDebugMessage:(NSNotification *)userInfo{
    NSDictionary *dict = [userInfo userInfo];
    
    if ([[dict valueForKey:@"status"] isNotEqualTo:@"update ui"]) {
        [array_message insertObject:dict atIndex:0];
    }
    
    NSMutableString *showMsg = [[NSMutableString alloc] initWithCapacity:0];
    NSMutableArray *mutable_array = [NSMutableArray arrayWithCapacity:0];
    if ([[dict valueForKey:@"status"] isEqualToString:@"clear ui"]){
        array_message = mutable_array;
    }
    for (NSDictionary *adict in array_message) {
        NSString *onemsg;
        if ([_button_logHex state] == 0) { //show string
            if ([[adict valueForKey:@"message"] isKindOfClass:[NSData class]]) {//message class is data
                onemsg= [NSString stringWithFormat:@"%@ : %@ %@",[adict valueForKey:@"time"],[adict valueForKey:@"status"],[[NSString alloc] initWithData:[adict valueForKey:@"message"] encoding:NSMacOSRomanStringEncoding]];
            }else{//message class is string
                onemsg = [NSString stringWithFormat:@"%@ : %@ %@",[adict valueForKey:@"time"],[adict valueForKey:@"status"],[adict valueForKey:@"message"]];
            }
        }
        else{ //show hex
            if ([[adict valueForKey:@"message"] isKindOfClass:[NSData class]]) { //data class
                onemsg= [NSString stringWithFormat:@"%@ : %@ %@",[adict valueForKey:@"time"],[adict valueForKey:@"status"],[adict valueForKey:@"message"]];
            }else{ //string class
                onemsg = [NSString stringWithFormat:@"%@ : %@ %@",[adict valueForKey:@"time"],[adict valueForKey:@"status"],[[adict valueForKey:@"message"] dataUsingEncoding:NSUTF8StringEncoding]];
            }//end class
        }//end show string
        
        if ([_button_timeStamp state] == 0) {
            NSRange range =[onemsg rangeOfString:@" : "];
            if (range.location != NSNotFound) {
                onemsg = [onemsg substringFromIndex:range.location + range.length];
            }
        }
        
        if ([showMsg length] < fileSize){
            [mutable_array addObject:adict];
            [showMsg appendString:onemsg];
            [showMsg appendString:@"\n"];
        }
    }
    array_message = mutable_array;
    if ([[NSThread currentThread] isMainThread]) {
        [_textView_debug setString:showMsg];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_textView_debug setString:showMsg];
        });
    }
    _array_command = [[NSMutableArray alloc] initWithArray:[FileManager GetCommandArrayFromCommandJson]];
    
}

-(void)doubleClick:(id)sender{
    InputBox *input = [[InputBox alloc] initWithMessage:@"请输入需要修改的名称" andTitle:[_array_command[_myTableView.selectedRow] valueForKey:@"key"] Window:self.view.window];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (input.flag == [NSNumber numberWithBool:YES]) {
            [NSThread sleepForTimeInterval:0.005];
        }
        [_array_command[_myTableView.selectedRow] setValue:input.strResult forKey:@"key"];
    });
    
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
        NSArray *select_files = [panel URLs] ;
        for (int i=0; i<select_files.count; i++)
        {
            path_all= [select_files objectAtIndex:i];
        }
    }
    return path_all;
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



-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return _array_command.count;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSDictionary *dict = _array_command[row];
    if ([[tableColumn identifier] isEqualToString:@"value"]) {
        return [dict valueForKey:@"command"];
    }else if([[tableColumn identifier] isEqualToString:@"key"]){
        NSButtonCell *cell = (NSButtonCell *)([tableColumn dataCellForRow:row]);
        [cell setTitle:[dict valueForKey:tableColumn.identifier]];
        return cell;
    }else if([[tableColumn identifier] isEqualToString:@"check"]){
        NSButtonCell *cell = (NSButtonCell *)([tableColumn dataCellForRow:row]);
        [cell setState:[[dict valueForKey:@"checkState"] integerValue]];
        return cell;
    }else{
        return [dict valueForKey:tableColumn.identifier];
    }
}

- (IBAction)sendMsg:(id)sender {
    NSString *command = [_array_command[_myTableView.selectedRow] valueForKey:@"command"];
    NSData *sendData ;
    NSData *dataEnd;
    if ([[_array_command[_myTableView.selectedRow] valueForKey:@"isHex"] boolValue])
    {
        sendData = [FileManager hexToBytes:command];
        
    }else{
        sendData = [command dataUsingEncoding:NSUTF8StringEncoding];
        
    }
    if (_button_hex.state) {
        dataEnd = [FileManager hexToBytes:[_label_endSymbol stringValue]];
    }else{
        dataEnd = [[_label_endSymbol stringValue] dataUsingEncoding:NSUTF8StringEncoding];
    }
    [aDevice writeEndSybmolData:sendData withEndSymbol:dataEnd andCrc:_button_crc.state andIsEndSymol:_button_endSymbol.state];
}

-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([[tableColumn identifier] isEqualToString:@"value"]) {
        NSMutableAttributedString *ob =(NSMutableAttributedString *)object;
        [_array_command[_myTableView.selectedRow] setValue:ob.string forKey:@"command"];
    }else if ([[tableColumn identifier] isEqualToString:@"check"]){
        [_array_command[_myTableView.selectedRow] setValue:[NSNumber numberWithInteger:[object intValue]] forKey:@"checkState"];
        if ([object intValue] == 1) {
            [_button_chooseNone setState:0];
        }else{
            [_button_chooseAll setState:0];
        }
    }else if ([[tableColumn identifier] isEqualToString:@"cyclenum"]) {
        [_array_command[_myTableView.selectedRow] setValue:[NSNumber numberWithInt:[object intValue]] forKey:@"cyclenum"];
    }else if ([[tableColumn identifier] isEqualToString:@"sleeptime"]) {
        [_array_command[_myTableView.selectedRow] setValue:object forKey:@"sleeptime"];
    }
}

- (IBAction)add:(id)sender {
    for (int i = 0; i < 999; i++) {
        NSString *key = [NSString stringWithFormat:@"test%d",i];
        int j;
        for (j = 0; j < _array_command.count; j++) {
            if ([[_array_command[j] valueForKey:@"key"] isEqualToString:key]) {
                break;
            }
        }
        if (j == _array_command.count) {
            NSMutableDictionary *commandDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:key,@"key",key,@"command",[NSNumber numberWithBool:1],@"checkState",[NSNumber numberWithBool:0],@"isHex",[NSNumber numberWithInt:0],@"cyclenum",@"1000ms",@"sleeptime", nil];
            [_array_command addObject:commandDict];
            [_myTableView reloadData];
            break;
        }
    }
}

- (IBAction)remove:(id)sender {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < _array_command.count; i++) {
        if ([[_array_command[i] valueForKey:@"checkState"] intValue] == 0) {
            [array addObject:_array_command[i]];
        }
    }
    _array_command = array;
    [_myTableView reloadData];
}

- (IBAction)sendCommand:(id)sender {
    NSData *sendData ;
    NSData *dataEnd;
    if ([_button_hex state] == 1) {
        sendData = [FileManager hexToBytes:[_label_command stringValue]];
    }else{
        sendData = [[_label_command stringValue] dataUsingEncoding:NSUTF8StringEncoding];
    }
    if (_button_hex.state) {
        dataEnd = [FileManager hexToBytes:[_label_endSymbol stringValue]];
    }else{
        dataEnd = [[_label_endSymbol stringValue] dataUsingEncoding:NSUTF8StringEncoding];
    }
//    [[ORSSerialPortInstance shareInstance] sendData:sendData toPort:devecePath];
    [aDevice writeEndSybmolData:sendData withEndSymbol:dataEnd andCrc:_button_crc.state andIsEndSymol:_button_endSymbol.state];
}

- (IBAction)isHex:(id)sender {
    for (int i = 0; i < _array_command.count; i++) {
        if ([[_array_command[i] valueForKey:@"checkState"] intValue] == 0) {
            continue;
        }
        NSString *str = [_array_command[i] valueForKey:@"command"];
        if ([_button_hex state] == 1 && ([[_array_command[i] valueForKey:@"isHex"] intValue] == 0)){
            NSString *mutableStr = [FileManager stringToData:str];
            [_array_command[i] setValue:mutableStr forKey:@"command"];
            [_array_command[i] setValue:[NSNumber numberWithInt:1] forKey:@"isHex"];
        }else if ([_button_hex state] == 0 && ([[_array_command[i] valueForKey:@"isHex"] intValue] == 1)){
            NSData *data = [FileManager hexToBytes:str];
            NSString *mutableStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [_array_command[i] setValue:mutableStr forKey:@"command"];
            [_array_command[i] setValue:[NSNumber numberWithInt:0] forKey:@"isHex"];
        }
    }
    NSString *str_command=@"";
    NSString *str_ends =@"";
    if ([_button_hex state] == 1){
        str_command= [FileManager stringToData:[_label_command stringValue]];
        if ([[_label_endSymbol stringValue] isEqualToString:@"/r/n"]) {
            str_ends = @"0d0a";
        }else{
            str_ends = [FileManager stringToData:[_label_endSymbol stringValue]];
        }
        
    }else{
        NSData *data_str = [FileManager hexToBytes:[_label_command stringValue]];
        str_command = [[NSString alloc] initWithData:data_str encoding:NSUTF8StringEncoding];
        NSData *data_end;
        if ([[_label_endSymbol stringValue] isEqualToString:@"0d0a"]) {
            str_ends = @"/r/n";
            data_end = [FileManager hexToBytes:@"0d0a"];
        }else{
            data_end = [FileManager hexToBytes:[_label_endSymbol stringValue]];
            str_ends = [[NSString alloc] initWithData:data_end encoding:NSUTF8StringEncoding];
        }
    }
    
    [_label_command setStringValue:str_command];
    [_label_endSymbol setStringValue:str_ends];
    [_myTableView reloadData];
}

- (IBAction)chooseAll:(id)sender {
    for (int i = 0; i < [_array_command count]; i++) {
        [_array_command[i] setValue:[NSNumber numberWithInt:1] forKey:@"checkState"];
    }
    [_myTableView reloadData];
    [_button_chooseNone setState:0];
}

- (IBAction)chooseNone:(id)sender {
    for (int i = 0; i < [_array_command count]; i++) {
        [_array_command[i] setValue:[NSNumber numberWithInt:0] forKey:@"checkState"];
    }
    [_myTableView reloadData];
    [_button_chooseAll setState:0];
}
- (IBAction)cycleSend:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *dataEnd;
        if (_button_hex.state) {
            dataEnd = [FileManager hexToBytes:[_label_endSymbol stringValue]];
        }else{
            dataEnd = [[_label_endSymbol stringValue] dataUsingEncoding:NSUTF8StringEncoding];
        }
        [[CycleRunProcess shareInstance] setArrayCommand:_array_command andRunTime:[_lable_cycletime stringValue] andPortName:aDevice andCrc:_button_crc.state andES:_button_endSymbol.state andEndSymbol:dataEnd];
        if ([[_button_cycleSend title] isEqualToString:@"循环发送"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_button_cycleSend setTitle:@"终止发送"];
            });
            [[CycleRunProcess shareInstance] mainRun];
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [_button_cycleSend setTitle:@"循环发送"];
            });
            [[CycleRunProcess shareInstance] setStop];
        }
        
    });
}

- (IBAction)logIsHex:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"debugMessage" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[FileManager TimeStamp],@"time",@"update ui",@"status",@"",@"message", nil]];
}
- (IBAction)timeStamp:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"debugMessage" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[FileManager TimeStamp],@"time",@"update ui",@"status",@"",@"message", nil]];
}

- (IBAction)clearUI:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"debugMessage" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[FileManager TimeStamp],@"time",@"clear ui",@"status",@"",@"message", nil]];
}

- (IBAction)saveLog:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSSavePanel*    panel = [NSSavePanel savePanel];
        [panel setNameFieldStringValue:@"log.txt"];
        [panel setMessage:@"Choose the path to save the document"];
        [panel setAllowsOtherFileTypes:YES];
        [panel setAllowedFileTypes:@[@"txt"]];
        [panel setExtensionHidden:YES];
        [panel setCanCreateDirectories:YES];
        [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result){
            if (result == NSFileHandlingPanelOKButton)
            {
                NSString *path = [[panel URL] path];
                [[_textView_debug string] writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
        }];
    });
    
}


- (IBAction)act_open:(id)sender {
    if ([[_button_open title] isEqualToString:@"打开"]) {//open serial port
        aDevice = [[UartDevice alloc] initWithDevice:[_pop_serialPort titleOfSelectedItem] andBandRate:[_comboBoxBandRate objectValueOfSelectedItem] andParity:[_pop_parity titleOfSelectedItem]];
        if(aDevice != nil)
        {//open success
            [_Label_Info setStringValue:@"串口打开成功."];
            _Label_Info.textColor = [NSColor purpleColor];
            devecePath = [_pop_serialPort titleOfSelectedItem];
            [[PublicSerialPort shareInstance] setdevecePath:devecePath];
            [_button_cell setEnabled:YES];
            [_button_send setEnabled:YES];
            [_button_cycleSend setEnabled:YES];
            
            //connect ok ,the pority and bandRate will not be change
            [_pop_parity setEnabled:NO];
            [_comboBoxBandRate setEnabled:NO];
            [_myTableView reloadData];
            [_button_open setTitle:@"断开"];
        }else{//if open fail
            [_Label_Info setStringValue:@"串口打开失败，请检查后重试。"];
            _Label_Info.textColor = [NSColor redColor];
        }//end if open success
    }else{// disconnect serial port
        if([aDevice close]){//close success
            [_button_open setTitle:@"打开"];
            [_Label_Info setStringValue:@"串口关闭成功。"];
            [_button_cell setEnabled:NO];
            [_button_send setEnabled:NO];
            [_button_cycleSend setEnabled:NO];
            [_pop_parity setEnabled:YES];
            [_comboBoxBandRate setEnabled:YES];
            [_myTableView reloadData];
        }//end if close success
    }//end open serial port
}

- (IBAction)act_serialPort:(id)sender {
    if ([_pop_serialPort.titleOfSelectedItem isEqualToString:@"socketServer"]) {
        [_label_PY setStringValue:@"端口"];
        [_label_PY setHidden:YES];
    }else if ([_pop_serialPort.titleOfSelectedItem isEqualToString:@"socketClient"]){
        [_label_BR setStringValue:@"服务器"];
        [_comboBoxBandRate removeAllItems];
    }else{
        [_comboBoxBandRate addItemsWithObjectValues:[[PublicSerialPort shareInstance] getarray_bandRate]];
        [_comboBoxBandRate addItemWithObjectValue:[[PublicSerialPort shareInstance] getcurrentBandRate]];
        [_pop_parity addItemsWithTitles:[[PublicSerialPort shareInstance] getarray_parity]];
        [_pop_parity setTitle:[[PublicSerialPort shareInstance] getcurrentParity]];

    }
    [[PublicSerialPort shareInstance] setCurrentSerialPort:_pop_serialPort.titleOfSelectedItem];
}


- (IBAction)act_parity:(id)sender {
    [[PublicSerialPort shareInstance] setcurrentParity:_pop_parity.titleOfSelectedItem];
}

-(void)controlTextDidChange:(NSNotification*)notification
{
    id object = [notification object];
    [object setCompletes:YES];//这个函数可以实现自动匹配功能
    
}
-(NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox{
    NSArray *arrayOld = [[PublicSerialPort shareInstance] getarray_bandRate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS '%@'",aComboBox.objectValueOfSelectedItem];
    NSArray *arrayNew = [arrayOld filteredArrayUsingPredicate:predicate];
    if (arrayNew.count > 0) {
        return arrayNew.count;
    }else{
        return 0;
    }
}
- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index{
    
    NSString *content = nil;
    NSArray *arrayOld = [[PublicSerialPort shareInstance] getarray_bandRate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS '%@'",aComboBox.objectValueOfSelectedItem];
    NSArray *arrayNew = [arrayOld filteredArrayUsingPredicate:predicate];
    
    if (index == 0)
    {
        content = @"";
    }
    else
    {
        if (arrayNew.count >= index ) {
            content = arrayNew[index];
        }else{
            content = @"";

        }
    }
    return content;
    
}
- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)string{
    NSArray *arrayOld = [[PublicSerialPort shareInstance] getarray_bandRate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS '%@'",aComboBox.objectValueOfSelectedItem];
    NSArray *arrayNew = [arrayOld filteredArrayUsingPredicate:predicate];
    return [arrayNew indexOfObject:string];
    
}
- (IBAction)actComboBoxBandRate:(id)sender {
   
}
@end
