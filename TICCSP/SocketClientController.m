//
//  SocketClientController.m
//  TICCSP
//
//  Created by apple on 17/11/3.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "SocketClientController.h"
#import "FileManager.h"
#import "InputBox.h"

@interface SocketClientController ()

@end

@implementation SocketClientController

- (void)viewDidLoad {
    [super viewDidLoad];
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
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
    [_myTableView setDelegate:self];
    [_myTableView setDataSource:self];
    [_myTableView reloadData];
    [_myTableView setDoubleAction:@selector(doubleClick:)];
    [_button_cell setEnabled:NO];
    [_button_send setEnabled:NO];
    [_button_cycleSend setEnabled:NO];
    array_message = [[NSMutableArray alloc] initWithCapacity:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDebugMessage:) name:@"debugMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuMessage:) name:@"menuMessage" object:nil];

    // Do view setup here.
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
-(NSData *)getDataWithCrc:(NSData *)dataSend{
    NSMutableData *mData = [[NSMutableData alloc] initWithData:dataSend];
    NSData *dataEnd;
    if (_button_hex.state) {
        dataEnd = [FileManager hexToBytes:[_label_endSymbol stringValue]];
    }else{
        dataEnd = [[_label_endSymbol stringValue] dataUsingEncoding:NSUTF8StringEncoding];
    }
    [mData appendData:dataEnd];
    if (_button_crc.state ) {
        uint8_t *parityData;
        parityData = (uint8_t *)malloc(2);
        uint16 crc = [FileManager ym_crc16:(Byte *)[mData bytes] andLen:sizeof(mData)];
        uint16_t resultL=crc & 0xFF;
        // 高位
        uint16_t resultH=crc >> 8;
        
        parityData[0] = resultH;
        parityData[1] = resultL;
        [mData appendBytes:parityData length:2];
    }
    return mData;
    
}

- (IBAction)sendMsg:(id)sender {
    NSString *command = [_array_command[_myTableView.selectedRow] valueForKey:@"command"];
    NSData *sendData ;
    
    if ([[_array_command[_myTableView.selectedRow] valueForKey:@"isHex"] boolValue])
    {
        sendData = [FileManager hexToBytes:command];
        
    }else{
        sendData = [command dataUsingEncoding:NSUTF8StringEncoding];
        
    }
    NSData *dataCrc = [self getDataWithCrc:sendData];
    [socket writeData:dataCrc withTimeout:1 tag:1];
//    [socket readDataWithTimeout:- 1 tag:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"debugMessage" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[FileManager TimeStamp],@"time",[NSString stringWithFormat:@"Send %@:%hu",socket.localHost,socket.localPort],@"status",dataCrc,@"message", nil]];
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
    if ([_button_hex state] == 1) {
        sendData = [FileManager hexToBytes:[_label_command stringValue]];
    }else{
        sendData = [[_label_command stringValue] dataUsingEncoding:NSUTF8StringEncoding];
    }
    NSData *dataCrc = [self getDataWithCrc:sendData];
//    GCDAsyncSocket *client = [self.dClientSockets valueForKey:[_POP_Clients titleOfSelectedItem]];
    [socket writeData:dataCrc withTimeout:1 tag:1];
//    [socket readDataWithTimeout:- 1 tag:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"debugMessage" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[FileManager TimeStamp],@"time",[NSString stringWithFormat:@"Send %@:%hu",socket.localHost,socket.localPort],@"status",dataCrc,@"message", nil]];
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
    NSButton *button = (NSButton *)sender;
    if ([[button title] isEqualToString:@"循环发送"]) {
        bRun = YES;
        button.title = @"终止发送";
        [self cycleRun];
        
    }else{
        button.title = @"循环发送";
        bRun = NO;
    }
}

-(void)cycleRun{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *dataEnd;
        if (_button_hex.state) {
            dataEnd = [FileManager hexToBytes:[_label_endSymbol stringValue]];
        }else{
            dataEnd = [[_label_endSymbol stringValue] dataUsingEncoding:NSUTF8StringEncoding];
        }
        NSMutableArray *commandArrayNeedSend = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i = 0; i < [_array_command count]; i++) {
            if([[_array_command[i] valueForKey:@"cyclenum"] intValue] != 0){
                
                [commandArrayNeedSend insertObject:_array_command[i] atIndex:[[_array_command[i] valueForKey:@"cyclenum"] intValue]-1];
            }
        }
        int time = [[_lable_cycletime stringValue] intValue];
        while (time) {
            for (int i = 0 ; i < commandArrayNeedSend.count; i++) {
                if (bRun == NO) {
                    break;
                }
                NSString *str = [commandArrayNeedSend[i] valueForKey:@"sleeptime"];
                [NSThread sleepForTimeInterval:[str doubleValue]/1000];
                NSData *sendData;
                if ([[commandArrayNeedSend[i] valueForKey:@"isHex"] intValue]) {
                    sendData = [FileManager hexToBytes:[commandArrayNeedSend[i] valueForKey:@"command"]];
                }else{
                    sendData = [[commandArrayNeedSend[i] valueForKey:@"command"] dataUsingEncoding:NSUTF8StringEncoding];
                }
                NSData *dataCrc = [self getDataWithCrc:sendData];
                [socket writeData:dataCrc withTimeout:-1 tag:1];
//                [socket readDataWithTimeout:- 1 tag:0];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"debugMessage" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[FileManager TimeStamp],@"time",[NSString stringWithFormat:@"Send %@:%hu",socket.localHost,socket.localPort],@"status",dataCrc,@"message", nil]];
            }
            time--;
            if (bRun == NO) {
                time = 0;
            }
            
        }
        [_button_cycleSend setTitle:@"循环发送"];
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

- (IBAction)actOpen:(id)sender {
    if ([[_buttonOpen title] isEqualToString:@"连接"]) {
        _buttonOpen.title = @"断开";
        NSError *error;
        [socket connectToHost:[_tfHostIP stringValue] onPort:[[_tfPort stringValue] intValue] error:&error];
        [socket readDataWithTimeout:-1 tag:0];
        [_button_cell setEnabled:YES];
        [_button_send setEnabled:YES];
        [_button_cycleSend setEnabled:YES];
    }else{
        _buttonOpen.title = @"连接";
        [socket disconnect];
        [_button_cell setEnabled:NO];
        [_button_send setEnabled:NO];
        [_button_cycleSend setEnabled:NO];
    }
    [_myTableView reloadData];
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    [_buttonOpen setTitle:@"断开"];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    [_buttonOpen setTitle:@"打开"];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    [sock readDataWithTimeout:- 1 tag:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"debugMessage" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[FileManager TimeStamp],@"time",[NSString stringWithFormat:@"Receive %@:%hu",sock.localHost,sock.localPort],@"status",data,@"message", nil]];
    
}

@end
