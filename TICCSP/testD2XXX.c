//
//  testD2XXX.c
//  TICCSP
//
//  Created by apple on 17/11/29.
//  Copyright © 2017年 coco. All rights reserved.
//

#include "testD2XXX.h"

/*
	Test app to send data to a terminal monitoring a second serial port.
 
	To build use the following gcc statement
	(assuming you have the d2xx library in the /usr/local/lib directory).
	gcc -o timeouts main.c -L. -lftd2xx -Wl,-rpath /usr/local/lib
 */

#include <stdio.h>
#include <assert.h>
#include "ftd2xx.h"



#define ARRAY_SIZE(x) sizeof((x))/sizeof((x)[0])



/* Test data which is easy to check visually */
static char testPattern[] = "\n"
"0123456789ABCDEF================FEDCBA9876543210\n"
"1DDDDDDDDDDDDDDD================DDDDDDDDDDDDDDD1\n"
"2DDDDDDDDDDDDDDD================DDDDDDDDDDDDDDD2\n"
"3DDDDDDDDDDDDDDD================DDDDDDDDDDDDDDD3\n"
"4DDDDDDDDDDDDDDD================DDDDDDDDDDDDDDD4\n"
"5DDDDDDDDDDDDDDD================DDDDDDDDDDDDDDD5\n"
"6DDDDDDDDDDDDDDD================DDDDDDDDDDDDDDD6\n"
"7DDDDDDDDDDDDDDD================DDDDDDDDDDDDDDD7\n"
"================0DDDDDDDDDDDDDD0================\n"
"================1DDDDDDDDDDDDDD1================\n"
"================2DDDDDDDDDDDDDD2================\n"
"================3DDDDDDDDDDDDDD3================\n"
"================4DDDDDDDDDDDDDD4================\n"
"================5DDDDDDDDDDDDDD5================\n"
"================6DDDDDDDDDDDDDD6================\n"
"================7DDDDDDDDDDDDDD7================\n"
"7DDDDDDDDDDDDDDD================DDDDDDDDDDDDDDD7\n"
"6DDDDDDDDDDDDDDD================DDDDDDDDDDDDDDD6\n"
"5DDDDDDDDDDDDDDD================DDDDDDDDDDDDDDD5\n"
"4DDDDDDDDDDDDDDD================DDDDDDDDDDDDDDD4\n"
"3DDDDDDDDDDDDDDD================DDDDDDDDDDDDDDD3\n"
"2DDDDDDDDDDDDDDD================DDDDDDDDDDDDDDD2\n"
"1DDDDDDDDDDDDDDD================DDDDDDDDDDDDDDD1\n"
"0123456789ABCDEF================FEDCBA9876543210\n"
"\n";

FT_HANDLE openPortWithPath(char *path,int baudRate){
    
    FT_STATUS  ftStatus = FT_OK;
    FT_HANDLE  ftHandle = NULL;
    
    ftStatus = FT_OpenEx(path, FT_OPEN_BY_SERIAL_NUMBER, &ftHandle);
    if (ftStatus != FT_OK)
    {
        printf("open port %s fail",path);
        return ftHandle;
    }
    
    assert(ftHandle != NULL);
    
    ftStatus = FT_ResetDevice(ftHandle);
    if (ftStatus != FT_OK)
    {
        printf("Failure.  FT_ResetDevice returned %d.\n", (int)ftStatus);
        return ftHandle;
    }
    
    ftStatus = FT_SetBaudRate(ftHandle, (ULONG)baudRate);
    if (ftStatus != FT_OK)
    {
        printf("Failure.  FT_SetBaudRate(%d) returned %d.\n",
               baudRate,
               (int)ftStatus);
        return ftHandle;
    }
    
    ftStatus = FT_SetDataCharacteristics(ftHandle,
                                         FT_BITS_8,
                                         FT_STOP_BITS_1,
                                         FT_PARITY_NONE);
    if (ftStatus != FT_OK)
    {
        printf("Failure.  FT_SetDataCharacteristics returned %d.\n", (int)ftStatus);
        goto exit;
    }
    
    // Indicate our presence to remote computer
    ftStatus = FT_SetDtr(ftHandle);
    if (ftStatus != FT_OK)
    {
        printf("Failure.  FT_SetDtr returned %d.\n", (int)ftStatus);
        goto exit;
    }
    
    // Flow control is needed for higher baud rates
    ftStatus = FT_SetFlowControl(ftHandle, FT_FLOW_RTS_CTS, 0, 0);
    if (ftStatus != FT_OK)
    {
        printf("Failure.  FT_SetFlowControl returned %d.\n", (int)ftStatus);
        goto exit;
    }
    
    // Assert Request-To-Send to prepare remote computer
    ftStatus = FT_SetRts(ftHandle);
    if (ftStatus != FT_OK)
    {
        printf("Failure.  FT_SetRts returned %d.\n", (int)ftStatus);
        goto exit;
    }
    
    ftStatus = FT_SetTimeouts(ftHandle, 3000, 3000);	// 3 seconds
    if (ftStatus != FT_OK)
    {
        printf("Failure.  FT_SetTimeouts returned %d\n", (int)ftStatus);
        goto exit;
    }
exit:
    return ftHandle;
}


int testWrite()
{
    int        retCode = -1; // Assume failure
    int        f = 0;
    FT_STATUS  ftStatus = FT_OK;
    FT_HANDLE  ftHandle = NULL;
    int        portNum = -1; // Deliberately invalid
    DWORD      bytesToWrite = 0;
    DWORD      bytesWritten = 0;
    int        inputRate = -1; // Entered on command line
    int        baudRate = -1; // Rate to actually use
    int        rates[] = {50, 75, 110, 134, 150, 200,
        300, 600, 1200, 1800, 2400, 4800,
        9600, 19200, 38400, 57600, 115200,
        230400, 460800, 576000, 921600};
    // Missing, or invalid.  Just use first port.
    portNum = 0;
    
    baudRate = 115200;
    
    printf("Trying FTDI device %d at %d baud.\n", portNum, baudRate);
    
//    ftStatus = FT_Open(portNum, &ftHandle);
    
    ftStatus = FT_OpenEx("FIXTURE12", FT_OPEN_BY_SERIAL_NUMBER, &ftHandle);
    if (ftStatus != FT_OK)
    {
        printf("FT_Open(%d) failed, with error %d.\n", portNum, (int)ftStatus);
        printf("Use lsmod to check if ftdi_sio (and usbserial) are present.\n");
        printf("If so, unload them using rmmod, as they conflict with ftd2xx.\n");
        goto exit;
    }
    
    assert(ftHandle != NULL);
    
    ftStatus = FT_ResetDevice(ftHandle);
    if (ftStatus != FT_OK)
    {
        printf("Failure.  FT_ResetDevice returned %d.\n", (int)ftStatus);
        goto exit;
    }
    
    ftStatus = FT_SetBaudRate(ftHandle, (ULONG)baudRate);
    if (ftStatus != FT_OK)
    {
        printf("Failure.  FT_SetBaudRate(%d) returned %d.\n",
               baudRate,
               (int)ftStatus);
        goto exit;
    }
    
    ftStatus = FT_SetDataCharacteristics(ftHandle,
                                         FT_BITS_8,
                                         FT_STOP_BITS_1,
                                         FT_PARITY_NONE);
    if (ftStatus != FT_OK)
    {
        printf("Failure.  FT_SetDataCharacteristics returned %d.\n", (int)ftStatus);
        goto exit;
    }
    
    // Indicate our presence to remote computer
    ftStatus = FT_SetDtr(ftHandle);
    if (ftStatus != FT_OK)
    {
        printf("Failure.  FT_SetDtr returned %d.\n", (int)ftStatus);
        goto exit;
    }
    
    // Flow control is needed for higher baud rates
    ftStatus = FT_SetFlowControl(ftHandle, FT_FLOW_RTS_CTS, 0, 0);
    if (ftStatus != FT_OK)
    {
        printf("Failure.  FT_SetFlowControl returned %d.\n", (int)ftStatus);
        goto exit;
    }
    
    // Assert Request-To-Send to prepare remote computer
    ftStatus = FT_SetRts(ftHandle);
    if (ftStatus != FT_OK)
    {
        printf("Failure.  FT_SetRts returned %d.\n", (int)ftStatus);
        goto exit;
    }
    
    ftStatus = FT_SetTimeouts(ftHandle, 3000, 3000);	// 3 seconds
    if (ftStatus != FT_OK)
    {
        printf("Failure.  FT_SetTimeouts returned %d\n", (int)ftStatus);
        goto exit;
    }
    
    bytesToWrite = (DWORD)(sizeof(testPattern) - 1); // Don't write string terminator
    
    ftStatus = FT_Write(ftHandle,
                        testPattern,
                        bytesToWrite,
                        &bytesWritten);
    if (ftStatus != FT_OK) 
    {
        printf("Failure.  FT_Write returned %d\n", (int)ftStatus);
        goto exit;
    }
    
    if (bytesWritten != bytesToWrite)
    {
        printf("Failure.  FT_Write wrote %d bytes instead of %d.\n",
               (int)bytesWritten,
               (int)bytesToWrite);
        goto exit;
    }
    
    // Success
    retCode = 0;
    printf("Successfully wrote %d bytes\n", (int)bytesWritten);
    
exit:
    if (ftHandle != NULL)
        FT_Close(ftHandle);
    
    return retCode;
}


