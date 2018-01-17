//
//  FileManager.h
//  rhac_coco
//
//  Created by apple on 17/9/1.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

/**
 write content to filePath . eturn 0 if create file fail or write fail.if file not esxit ,creat it .seek the end of file and append content.
 @param filePath --> contains path and file name ,such as /Users/apple/Documents/coco/1.txt
 @param content --> the log will write to filePath
 @result BOOL --> return write result , if fail return o , otherwise return 1
 */
+(BOOL)appendLogWithPath:(NSString *)filePath andLog:(NSString *)content;
/**
 change current time to string
 @result NSString --> return string such as:20170929141621.089
 */
+(NSString *)TimeStamp;
/**
 change hex string to data
@param hexString -->hex string formatter such as "73 74 31 34"
 @result  NSData --> return data formatter
 */
+(NSData*) hexToBytes :(NSString *)hexString;

/**
 change string to data formatter string
 @param str -->string formatter such as "123"
 @result  NSString --> return data formatter string ,such as "31 32 33"
 */
+(NSString *)stringToData:(NSString *)str;
/**
 get array from command.json , array conatains the key , and all value for the key
 @result  NSArray --> return all data in command.json
 */
+(NSArray*)GetCommandArrayFromCommandJson;

/**
 write array to command.json
 */
+(void)SaveCommandToCommandJson:(NSArray *)commandArray;

+(void)SaveCommandToJsonFile:(NSArray *)commandArray andFileName:(NSString *)file;

/**
 get array from command.json , array conatains the key , and all value for the key
 @param-->filePath get json file with path
 @result  NSArray --> return all data in command.json
 */

+(NSArray*)GetCommandArrayFromCommandJsonWithPath:(NSString *)filePath;

/**
 run apple script to get access to handle Ymodel , if error = nil ,return 1 ,else return 0
 */
+(NSString *)YmodelScript:(NSString *)scpt;
/**
get config dictionary from config
@param-->filePath get json file with path
@result   NSDictionary--> return all data in config
*/

+(NSDictionary *)getConfigFromConfigJson;

/**
 write dict to config
 */
+(void)saveConfigFromConfigJson:(NSDictionary *)dict;

@end
