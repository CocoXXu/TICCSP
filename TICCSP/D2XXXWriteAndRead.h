//
//  D2XXXWriteAndRead.h
//  TICCSP
//
//  Created by apple on 17/11/29.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ftd2xx.h"

@interface D2XXXWriteAndRead : NSObject{
    FT_HANDLE ftHandle;
}
typedef void (^showReceiveDataBlock)(char *datas);
typedef void (^showResultBlock)(NSString *message);

-(id)initWithPortNameAndBaudRate:(NSString *)portName and:(NSString *)bandRate andShowResult:(showResultBlock)block;

-(void)readDataForBlock:(showReceiveDataBlock)block1;

-(BOOL)writeData:(NSData *)data;


@end
