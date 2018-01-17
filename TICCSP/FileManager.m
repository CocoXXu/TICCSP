//
//  FileManager.m
//  rhac_coco
//
//  Created by apple on 17/9/1.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "FileManager.h"

@implementation FileManager

+(BOOL)appendLogWithPath:(NSString *)filePath andLog:(NSString *)content{
    
    NSFileManager *manage = [NSFileManager defaultManager];
    BOOL iDirectory = NO;
    BOOL creatFlag = YES;
    if (![manage fileExistsAtPath:filePath isDirectory:&iDirectory]) {
        creatFlag =[manage createFileAtPath:filePath contents:nil attributes:nil];
        if (!creatFlag) {
            return creatFlag;
        }
    }
        NSFileHandle *filehandle =[NSFileHandle fileHandleForWritingAtPath:filePath];
        @try {
            [filehandle seekToEndOfFile];
            [filehandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        } @catch (NSException *exception) {
            creatFlag = NO;
        } @finally {
            [filehandle closeFile];
        }

    return creatFlag;
}

+(NSString *)TimeStamp{
    NSDate *now=[NSDate date];
    NSString*datestr=[now descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S" timeZone:nil locale:nil];
    float ss=([now timeIntervalSince1970]-(long)[now timeIntervalSince1970])*1000;
    return [NSString stringWithFormat:@"%@.%03d",datestr,(int)ss];
}

+(NSData*) hexToBytes :(NSString *)hexString{
    NSMutableString *mulstr=[NSMutableString stringWithString:hexString];
    [mulstr replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, mulstr.length)];
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= [mulstr length]; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [mulstr substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

+(NSString *)stringToData:(NSString *)str{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    Byte *byte = (Byte *)[data bytes];
    NSMutableString *mutableStr = [[NSMutableString alloc] initWithCapacity:0];
    for (int j = 0; j < [data length]; j++) {
        if (j == 0) {
            [mutableStr appendString:[NSString stringWithFormat:@"%x",byte[j]]];
        }else{
            [mutableStr appendString:[NSString stringWithFormat:@" %x",byte[j]]];
        }
    }
    return [NSString stringWithString:mutableStr];
}

+(NSArray*)GetCommandArrayFromCommandJson{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"command" ofType:@"json"];
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict_config = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSMutableArray *commandArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSString *akey in [dict_config allKeys]) {
        NSMutableDictionary *adict = [[NSMutableDictionary alloc] init];
        [adict setValue:akey forKey:@"key"];
        [adict addEntriesFromDictionary:[dict_config valueForKey:akey]];
        [commandArray addObject:adict];
    }
    return commandArray;
}
+(NSDictionary *)getConfigFromConfigJson{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"json"];
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict_config = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return dict_config;
}

+(void)saveConfigFromConfigJson:(NSDictionary *)dict{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"json"];
    NSOutputStream *outStream = [[NSOutputStream alloc] initToFileAtPath:filePath append:NO];
    [outStream open];
    [NSJSONSerialization writeJSONObject:dict toStream:outStream options:NSJSONWritingPrettyPrinted error:nil];
    [outStream close];
    
}
+(NSArray*)GetCommandArrayFromCommandJsonWithPath:(NSString *)filePath{
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict_config = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSMutableArray *commandArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSString *akey in [dict_config allKeys]) {
        NSMutableDictionary *adict = [[NSMutableDictionary alloc] init];
        [adict setValue:akey forKey:@"key"];
        [adict addEntriesFromDictionary:[dict_config valueForKey:akey]];
        [commandArray addObject:adict];
    }
    return commandArray;
}

+(void)SaveCommandToCommandJson:(NSArray *)commandArray{
   
    NSMutableDictionary *config_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    for (int i = 0; i < commandArray.count; i++) {
        NSString *akey = [commandArray[i] valueForKey:@"key"];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:commandArray[i]];
        [dict removeObjectForKey:akey];
        [config_dict setValue:dict forKey:akey];
    }
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"command" ofType:@"json"];
    NSOutputStream *outStream = [[NSOutputStream alloc] initToFileAtPath:filePath append:NO];
    [outStream open];
    [NSJSONSerialization writeJSONObject:config_dict toStream:outStream options:NSJSONWritingPrettyPrinted error:nil];
    [outStream close];

}

+(void)SaveCommandToJsonFile:(NSArray *)commandArray andFileName:(NSString *)file{
    
    NSMutableDictionary *config_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    for (int i = 0; i < commandArray.count; i++) {
        NSString *akey = [commandArray[i] valueForKey:@"key"];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:commandArray[i]];
        [dict removeObjectForKey:akey];
        [config_dict setValue:dict forKey:akey];
    }
    NSString *filePath = [[NSBundle mainBundle] pathForResource:file ofType:@"json"];
    NSOutputStream *outStream = [[NSOutputStream alloc] initToFileAtPath:filePath append:NO];
    [outStream open];
    [NSJSONSerialization writeJSONObject:config_dict toStream:outStream options:NSJSONWritingPrettyPrinted error:nil];
    [outStream close];
    
}

+(NSData *)GetParityData:(NSString *)parity andOriginData:(NSData *)originData{
    NSData *data = [[NSData alloc] init];
    return data;
}

+(NSString *)YmodelScript:(NSString *)scpt{//@"YModel.scpt"
    NSString * strScript = [[NSBundle mainBundle] pathForResource:scpt ofType:nil];
    
    NSAppleScript * appScript = [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:strScript] error:nil];
    NSDictionary *error;
    [appScript executeAndReturnError:&error];
    if (error == nil) {
        return @"ok";
    }else{
        return [error valueForKey:@"NSAppleScriptErrorMessage"];
    }

}

@end
