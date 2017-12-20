/*
 To build use the following gcc statement
 (assuming you have the d2xx library in the /usr/local/lib directory).
 gcc -o read main.c -L. -lftd2xx -Wl,-rpath,/usr/local/lib
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include "ftd2xx.h"

#define BUF_SIZE 0x10

#define MAX_DEVICES		50

//static void dumpBuffer(unsigned char *buffer, int elements)
//{
//	int j;
//    
//	printf(" [");
//	for (j = 0; j < elements; j++)
//	{
//		if (j > 0)
//			printf(", ");
//		printf("0x%02X", (unsigned int)buffer[j]);
//	}
//	printf("]\n");
//}

int mainGet(char allFiture[MAX_DEVICES][64] , int dnum){
//    unsigned char 	cBufWrite[BUF_SIZE];
    char * 	pcBufLD[MAX_DEVICES + 1];
    char 	cBufLD[MAX_DEVICES][64];
    FT_STATUS	ftStatus;
    int	iNumDevs = 0;
    int	i;
    
    for(i = 0; i < MAX_DEVICES; i++) {
        pcBufLD[i] = cBufLD[i];
    }
    pcBufLD[MAX_DEVICES] = NULL;
    
    ftStatus = FT_ListDevices(pcBufLD, &iNumDevs, FT_LIST_ALL | FT_OPEN_BY_SERIAL_NUMBER);
    
    if(ftStatus != FT_OK) {
        printf("Error: FT_ListDevices(%d)\n", (int)ftStatus);
        return 1;
    }
    dnum = 0;
    printf("Device %d", dnum);
    for(i = 0; ( (i <MAX_DEVICES) && (i < iNumDevs) ); i++) {
        printf("Device %d Serial Number - %s\n", i, cBufLD[i]);
        strcpy(allFiture[i], cBufLD[i]);
        dnum++;
    }
    
    return dnum;
}


int mainReadWithName(char *name,char *Description,char *ProductId,char *VendorId,char *Manufacturer,char *newsn){
    unsigned char 	cBufWrite[BUF_SIZE];
    char * 	pcBufLD[MAX_DEVICES + 1];
    char 	cBufLD[MAX_DEVICES][64];
    static FT_PROGRAM_DATA Data;
    FT_STATUS	ftStatus;
    FT_HANDLE	ftHandle[MAX_DEVICES];
    
    int	iNumDevs = 0;
    int	i, j;
    static FT_DEVICE ftDevice;
    int retCode = 0;
    
    for(i = 0; i < MAX_DEVICES; i++) {
        pcBufLD[i] = cBufLD[i];
    }
    pcBufLD[MAX_DEVICES] = NULL;
    
    ftStatus = FT_ListDevices(pcBufLD, &iNumDevs, FT_LIST_ALL | FT_OPEN_BY_SERIAL_NUMBER);
    
    if(ftStatus != FT_OK) {
        printf("Error: FT_ListDevices(%d)\n", (int)ftStatus);
        return 1;
    }
    
    for(i = 0; ( (i <MAX_DEVICES) && (i < iNumDevs) ); i++) {
        printf("Device %d Serial Number - %s\n", i, cBufLD[i]);
    }
    
    for(j = 0; j < BUF_SIZE; j++) {
        cBufWrite[j] = j;
    }
    
    for(i = 0; ( (i <MAX_DEVICES) && (i < iNumDevs) ) ; i++) {
        if (strcmp(cBufLD[i], name)) {
            continue;
        }
        /* Setup */
        if((ftStatus = FT_OpenEx(cBufLD[i], FT_OPEN_BY_SERIAL_NUMBER, &ftHandle[i])) != FT_OK){
            /*
             This can fail if the ftdi_sio driver is loaded
             use lsmod to check this and rmmod ftdi_sio to remove
             also rmmod usbserial
             */
            printf("Error FT_OpenEx(%d), device %d\n", (int)ftStatus, i);
            printf("Use lsmod to check if ftdi_sio (and usbserial) are present.\n");
            printf("If so, unload them using rmmod, as they conflict with ftd2xx.\n");
            return 1;
        }
        
        if(ftStatus != FT_OK) {
            /*
             This can fail if the ftdi_sio driver is loaded
             use lsmod to check this and rmmod ftdi_sio to remove
             also rmmod usbserial
             */
            printf("FT_Open(%s) failed\n", cBufLD[i]);
            return 1;
        }
        
        printf("FT_Open succeeded.  Handle is %p\n", ftHandle[i]);
        
        ftStatus = FT_GetDeviceInfo(ftHandle[i],
                                    &ftDevice,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL);
        if (ftStatus != FT_OK)
        {
            printf("FT_GetDeviceType FAILED!\n");
            retCode = 1;
            goto exit;
        }
        
        printf("FT_GetDeviceInfo succeeded.  Device is type %d.\n",
               (int)ftDevice);
        
        
        
        
        /* MUST set Signature1 and 2 before calling FT_EE_Read */
        Data.Signature1 = 0x00000000;
        Data.Signature2 = 0xffffffff;
        Data.Manufacturer = (char *)malloc(256); /* E.g "FTDI" */
        Data.ManufacturerId = (char *)malloc(256); /* E.g. "FT" */
        Data.Description = (char *)malloc(256); /* E.g. "USB HS Serial Converter" */
        Data.SerialNumber = (char *)malloc(256); /* E.g. "FT000001" if fixed, or NULL *///---------we need to change
        if (Data.Manufacturer == NULL ||
            Data.ManufacturerId == NULL ||
            Data.Description == NULL ||
            Data.SerialNumber == NULL)
        {
            printf("Failed to allocate memory.\n");
            retCode = 1;
            goto exit;
        }
        
        ftStatus = FT_EE_Read(ftHandle[i], &Data);
        if(ftStatus != FT_OK) {
            printf("FT_EE_Read failed\n");
            retCode = 1;
            goto exit;
        }
        
        printf("FT_EE_Read succeeded.\n\n");
        int pid = Data.ProductId;
        int vid = Data.VendorId;
        sprintf(ProductId, "%x ",pid);
        sprintf(VendorId, "%04x",vid);
        strcpy(Description, Data.Description);
        strcpy(Manufacturer, Data.Manufacturer);
        strcpy(newsn, Data.SerialNumber);
        break;
        
    }
exit:
    free(Data.Manufacturer);
    free(Data.ManufacturerId);
    free(Data.Description);
    //	free(Data.SerialNumber);
    
    
    
    FT_Close(ftHandle[i]);
    printf("Returning %d\n", retCode);
    return retCode;
    
}

int   mainRead(int argc, char *argv[],char *name)
{
    
	FT_STATUS	ftStatus;
	FT_HANDLE	ftHandle0;
	int iport;
	static FT_PROGRAM_DATA Data;
	static FT_DEVICE ftDevice;
	DWORD libraryVersion = 0;
	int retCode = 0;
    
    
    unsigned char 	cBufWrite[BUF_SIZE];
 	char * 	pcBufLD[MAX_DEVICES + 1];
	char 	cBufLD[MAX_DEVICES][64];
 	int	iNumDevs = 0;
	int	i, j;
 	
	for(i = 0; i < MAX_DEVICES; i++) {
		pcBufLD[i] = cBufLD[i];
	}
	pcBufLD[MAX_DEVICES] = NULL;
	
    //-----get lib version-------
    ftStatus = FT_GetLibraryVersion(&libraryVersion);
	if (ftStatus == FT_OK)
	{
		printf("Library version = 0x%x\n", (unsigned int)libraryVersion);
	}
    
	else
	{
		printf("Error reading library version.\n");
		return 1;
	}
    
    
    //-------------list device---------
	ftStatus = FT_ListDevices(pcBufLD, &iNumDevs, FT_LIST_ALL | FT_OPEN_BY_SERIAL_NUMBER);
	
	if(ftStatus != FT_OK) {
		printf("Error: FT_ListDevices(%d)\n", (int)ftStatus);
		return 1;
	}
    
	for(i = 0; ( (i <MAX_DEVICES) && (i < iNumDevs) ); i++) {
		printf("Device %d Serial Number - %s\n", i, cBufLD[i]);
	}
    
    for(j = 0; j < BUF_SIZE; j++) {
		cBufWrite[j] = j;
	}
 
  //-------------select port-------------
	if(argc > 1) {
		sscanf(argv[1], "%d", &iport);
	}
	else {
		iport = 0;
	}
    
	printf("Opening port %d\n", iport);
	
	ftStatus = FT_Open(iport, &ftHandle0);
	if(ftStatus != FT_OK) {
		/*
         This can fail if the ftdi_sio driver is loaded
         use lsmod to check this and rmmod ftdi_sio to remove
         also rmmod usbserial
		 */
		printf("FT_Open(%d) failed\n", iport);
		return 1;
	}
	
	printf("FT_Open succeeded.  Handle is %p\n", ftHandle0);
    
	ftStatus = FT_GetDeviceInfo(ftHandle0,
	                            &ftDevice,
	                            NULL,
	                            NULL,
	                            NULL,
	                            NULL);
	if (ftStatus != FT_OK)
	{
		printf("FT_GetDeviceType FAILED!\n");
		retCode = 1;
		goto exit;
	}
    
	printf("FT_GetDeviceInfo succeeded.  Device is type %d.\n",
	       (int)ftDevice);
    
 
    
    
	/* MUST set Signature1 and 2 before calling FT_EE_Read */
	Data.Signature1 = 0x00000000;
	Data.Signature2 = 0xffffffff;
	Data.Manufacturer = (char *)malloc(256); /* E.g "FTDI" */
	Data.ManufacturerId = (char *)malloc(256); /* E.g. "FT" */
	Data.Description = (char *)malloc(256); /* E.g. "USB HS Serial Converter" */
	Data.SerialNumber = (char *)malloc(256); /* E.g. "FT000001" if fixed, or NULL *///---------we need to change
	if (Data.Manufacturer == NULL ||
	    Data.ManufacturerId == NULL ||
	    Data.Description == NULL ||
	    Data.SerialNumber == NULL)
	{
		printf("Failed to allocate memory.\n");
		retCode = 1;
		goto exit;
	}
    
	ftStatus = FT_EE_Read(ftHandle0, &Data);
	if(ftStatus != FT_OK) {
		printf("FT_EE_Read failed\n");
		retCode = 1;
		goto exit;
	}
    
	printf("FT_EE_Read succeeded.\n\n");
    
    strcpy(name ,Data.SerialNumber  );
exit:
	free(Data.Manufacturer);
	free(Data.ManufacturerId);
	free(Data.Description);
//	free(Data.SerialNumber);
    
    
    
	FT_Close(ftHandle0);
	printf("Returning %d\n", retCode);
	return retCode;
}

int mainWriteDesciption(char *oldname , char *newdesc){
    FT_STATUS	ftStatus;
    FT_HANDLE	ftHandle0;
    int iport;
    static FT_PROGRAM_DATA Data;
    static FT_DEVICE ftDevice;
    DWORD libraryVersion = 0;
    int retCode = 0;
    unsigned char 	cBufWrite[BUF_SIZE];
    char * 	pcBufLD[MAX_DEVICES + 1];
    char 	cBufLD[MAX_DEVICES][64];
    int	iNumDevs = 0;
    int	i, j;
    
    for(i = 0; i < MAX_DEVICES; i++) {
        pcBufLD[i] = cBufLD[i];
    }
    pcBufLD[MAX_DEVICES] = NULL;
    
    //-----get lib version-------
    ftStatus = FT_GetLibraryVersion(&libraryVersion);
    if (ftStatus == FT_OK)
    {
        printf("Library version = 0x%x\n", (unsigned int)libraryVersion);
    }
    
    else
    {
        printf("Error reading library version.\n");
        return 1;
    }
    
    
    //-------------list device---------
    ftStatus = FT_ListDevices(pcBufLD, &iNumDevs, FT_LIST_ALL | FT_OPEN_BY_SERIAL_NUMBER);
    
    if(ftStatus != FT_OK) {
        printf("Error: FT_ListDevices(%d)\n", (int)ftStatus);
        return 1;
    }
    
    for(i = 0; ( (i <MAX_DEVICES) && (i < iNumDevs) ); i++) {
        printf("Device %d Serial Number - %s\n", i, cBufLD[i]);
    }
    
    for(j = 0; j < BUF_SIZE; j++) {
        cBufWrite[j] = j;
    }

    
    ftStatus = FT_OpenEx(oldname, FT_OPEN_BY_SERIAL_NUMBER, &ftHandle0);
    
    if(ftStatus != FT_OK) {
        /*
         This can fail if the ftdi_sio driver is loaded
         use lsmod to check this and rmmod ftdi_sio to remove
         also rmmod usbserial
         */
        printf("FT_Open(%d) failed\n", iport);
        return 1;
    }
    
    printf("FT_Open succeeded.  Handle is %p\n", ftHandle0);
    
    ftStatus = FT_GetDeviceInfo(ftHandle0,
                                &ftDevice,
                                NULL,
                                NULL,
                                NULL,
                                NULL);
    if (ftStatus != FT_OK)
    {
        printf("FT_GetDeviceType FAILED!\n");
        retCode = 1;
        goto exit;
    }
    
    printf("FT_GetDeviceInfo succeeded.  Device is type %d.\n",
           (int)ftDevice);
    
    
    
    //	Data.Signature1 = 0x00000000;
    //	Data.Signature2 = 0xffffffff;
    //	Data.VendorId = 0x0403;
    //	Data.ProductId = 0x6001;
    //	Data.Manufacturer =  "FTDI";
    //	Data.ManufacturerId = "FT";
    //	Data.Description = "USB <-> Serial";
    //	Data.SerialNumber = "FT000001";		// if fixed, or NULL
    //
    //	Data.MaxPower = 44;
    //	Data.PnP = 1;
    //	Data.SelfPowered = 0;
    //	Data.RemoteWakeup = 1;
    //	Data.Rev4 = 1;
    //	Data.IsoIn = 0;
    //	Data.IsoOut = 0;
    //	Data.PullDownEnable = 1;
    //	Data.SerNumEnable = 1;
    //	Data.USBVersionEnable = 0;
    //	Data.USBVersion = 0x110;
    
    
    
    /* MUST set Signature1 and 2 before calling FT_EE_Read */
    Data.Signature1 = 0x00000000;
    Data.Signature2 = 0xffffffff;
    Data.Manufacturer = (char *)malloc(256); /* E.g "FTDI" */
    Data.ManufacturerId = (char *)malloc(256); /* E.g. "FT" */
    Data.Description = (char *)malloc(256); /* E.g. "USB HS Serial Converter" */
    Data.SerialNumber = (char *)malloc(256); /* E.g. "FT000001" if fixed, or NULL *///---------we need to change
    if (Data.Manufacturer == NULL ||
        Data.ManufacturerId == NULL ||
        Data.Description == NULL ||
        Data.SerialNumber == NULL)
    {
        printf("Failed to allocate memory.\n");
        retCode = 1;
        goto exit;
    }
    
    ftStatus = FT_EE_Read(ftHandle0, &Data);
    if(ftStatus != FT_OK) {
        printf("FT_EE_Read failed\n");
        retCode = 1;
        goto exit;
    }
    
    printf("FT_EE_Read succeeded.\n\n");
    Data.Description = newdesc;		// if fixed, or NULL
    printf("new Description = %s\n", Data.Description);
    
    ftStatus = FT_EE_Program(ftHandle0, &Data);
    if(ftStatus != FT_OK) {
        printf("FT_EE_Program failed (%d)\n", (int)ftStatus);
        FT_Close(ftHandle0);
    }else{
        printf("FT_EE_Read succeeded!!!.\n\n");
    }
    
exit:
    free(Data.Manufacturer);
    free(Data.ManufacturerId);
//    free(Data.Description);
    free(Data.SerialNumber);
    
    
    
    FT_Close(ftHandle0);
    printf("Returning %d\n", retCode);
    return retCode;

}
//
//
//
int mainWriteName(char *oldname , char *newname)
{
    
	FT_STATUS	ftStatus;
	FT_HANDLE	ftHandle0;
	int iport;
	static FT_PROGRAM_DATA Data;
	static FT_DEVICE ftDevice;
	DWORD libraryVersion = 0;
	int retCode = 0;
    
    
    unsigned char 	cBufWrite[BUF_SIZE];
//	unsigned char * pcBufRead = NULL;
	char * 	pcBufLD[MAX_DEVICES + 1];
	char 	cBufLD[MAX_DEVICES][64];
//	DWORD	dwRxSize = 0;
//	DWORD 	dwBytesWritten, dwBytesRead;
// 	FT_HANDLE	ftHandle[MAX_DEVICES];
	int	iNumDevs = 0;
	int	i, j;
//	int	iDevicesOpen;
	
	for(i = 0; i < MAX_DEVICES; i++) {
		pcBufLD[i] = cBufLD[i];
	}
	pcBufLD[MAX_DEVICES] = NULL;
	
    //-----get lib version-------
    ftStatus = FT_GetLibraryVersion(&libraryVersion);
	if (ftStatus == FT_OK)
	{
		printf("Library version = 0x%x\n", (unsigned int)libraryVersion);
	}
    
	else
	{
		printf("Error reading library version.\n");
		return 1;
	}
    
    
    //-------------list device---------
	ftStatus = FT_ListDevices(pcBufLD, &iNumDevs, FT_LIST_ALL | FT_OPEN_BY_SERIAL_NUMBER);
	
	if(ftStatus != FT_OK) {
		printf("Error: FT_ListDevices(%d)\n", (int)ftStatus);
		return 1;
	}
    
	for(i = 0; ( (i <MAX_DEVICES) && (i < iNumDevs) ); i++) {
		printf("Device %d Serial Number - %s\n", i, cBufLD[i]);
	}
    
    for(j = 0; j < BUF_SIZE; j++) {
		cBufWrite[j] = j;
	}
    
    //-------------select port-------------
//	if(argc > 1) {
//		sscanf(argv[1], "%d", &iport);
//	}
//	else {
//		iport = 0;
//	}
    
    ftStatus = FT_OpenEx(oldname, FT_OPEN_BY_SERIAL_NUMBER, &ftHandle0);
//	ftStatus = FT_Open(iport, &ftHandle0);
	if(ftStatus != FT_OK) {
		/*
         This can fail if the ftdi_sio driver is loaded
         use lsmod to check this and rmmod ftdi_sio to remove
         also rmmod usbserial
		 */
		printf("FT_Open(%d) failed\n", iport);
		return 1;
	}
	
	printf("FT_Open succeeded.  Handle is %p\n", ftHandle0);
    
	ftStatus = FT_GetDeviceInfo(ftHandle0,
	                            &ftDevice,
	                            NULL,
	                            NULL,
	                            NULL,
	                            NULL);
	if (ftStatus != FT_OK)
	{
		printf("FT_GetDeviceType FAILED!\n");
		retCode = 1;
		goto exit;
	}
    
	printf("FT_GetDeviceInfo succeeded.  Device is type %d.\n",
	       (int)ftDevice);
    
    
    
    //	Data.Signature1 = 0x00000000;
    //	Data.Signature2 = 0xffffffff;
    //	Data.VendorId = 0x0403;
    //	Data.ProductId = 0x6001;
    //	Data.Manufacturer =  "FTDI";
    //	Data.ManufacturerId = "FT";
    //	Data.Description = "USB <-> Serial";
    //	Data.SerialNumber = "FT000001";		// if fixed, or NULL
    //
    //	Data.MaxPower = 44;
    //	Data.PnP = 1;
    //	Data.SelfPowered = 0;
    //	Data.RemoteWakeup = 1;
    //	Data.Rev4 = 1;
    //	Data.IsoIn = 0;
    //	Data.IsoOut = 0;
    //	Data.PullDownEnable = 1;
    //	Data.SerNumEnable = 1;
    //	Data.USBVersionEnable = 0;
    //	Data.USBVersion = 0x110;
    
    
    
	/* MUST set Signature1 and 2 before calling FT_EE_Read */
	Data.Signature1 = 0x00000000;
	Data.Signature2 = 0xffffffff;
	Data.Manufacturer = (char *)malloc(256); /* E.g "FTDI" */
	Data.ManufacturerId = (char *)malloc(256); /* E.g. "FT" */
	Data.Description = (char *)malloc(256); /* E.g. "USB HS Serial Converter" */
	Data.SerialNumber = (char *)malloc(256); /* E.g. "FT000001" if fixed, or NULL *///---------we need to change
	if (Data.Manufacturer == NULL ||
	    Data.ManufacturerId == NULL ||
	    Data.Description == NULL ||
	    Data.SerialNumber == NULL)
	{
		printf("Failed to allocate memory.\n");
		retCode = 1;
		goto exit;
	}
    
	ftStatus = FT_EE_Read(ftHandle0, &Data);
	if(ftStatus != FT_OK) {
		printf("FT_EE_Read failed\n");
		retCode = 1;
		goto exit;
	}
    
	printf("FT_EE_Read succeeded.\n\n");
    
//	printf("Signature1 = %d\n", (int)Data.Signature1);
//	printf("Signature2 = %d\n", (int)Data.Signature2);
//	printf("Version = %d\n", (int)Data.Version);
//    
//	printf("VendorId = 0x%04X\n", Data.VendorId);
//	printf("ProductId = 0x%04X\n", Data.ProductId);
//	printf("Manufacturer = %s\n", Data.Manufacturer);
//	printf("ManufacturerId = %s\n", Data.ManufacturerId);
//	printf("Description = %s\n", Data.Description);
//	printf("SerialNumber = %s\n", Data.SerialNumber);  //---------we need to change
//	printf("MaxPower = %d\n", Data.MaxPower);
//	printf("PnP = %d\n", Data.PnP) ;
//	printf("SelfPowered = %d\n", Data.SelfPowered);
//	printf("RemoteWakeup = %d\n", Data.RemoteWakeup);
//    
    
    
//	if (ftDevice == FT_DEVICE_232R)
//	{
//		/* Rev 6 (FT232R) extensions */
//		printf("232R:\n");
//		printf("-----\n");
//		printf("\tUseExtOsc = 0x%X\n", Data.UseExtOsc);			// Use External Oscillator
//		printf("\tHighDriveIOs = 0x%X\n", Data.HighDriveIOs);			// High Drive I/Os
//		printf("\tEndpointSize = 0x%X\n", Data.EndpointSize);			// Endpoint size
//        
//		printf("\tPullDownEnableR = 0x%X\n", Data.PullDownEnableR);		// non-zero if pull down enabled
//		printf("\tSerNumEnableR = 0x%X\n", Data.SerNumEnableR);		// non-zero if serial number to be used
//        
//		printf("\tInvertTXD = 0x%X\n", Data.InvertTXD);			// non-zero if invert TXD
//		printf("\tInvertRXD = 0x%X\n", Data.InvertRXD);			// non-zero if invert RXD
//		printf("\tInvertRTS = 0x%X\n", Data.InvertRTS);			// non-zero if invert RTS
//		printf("\tInvertCTS = 0x%X\n", Data.InvertCTS);			// non-zero if invert CTS
//		printf("\tInvertDTR = 0x%X\n", Data.InvertDTR);			// non-zero if invert DTR
//		printf("\tInvertDSR = 0x%X\n", Data.InvertDSR);			// non-zero if invert DSR
//		printf("\tInvertDCD = 0x%X\n", Data.InvertDCD);			// non-zero if invert DCD
//		printf("\tInvertRI = 0x%X\n", Data.InvertRI);				// non-zero if invert RI
//        
//		printf("\tCbus0 = 0x%X\n", Data.Cbus0);				// Cbus Mux control
//		printf("\tCbus1 = 0x%X\n", Data.Cbus1);				// Cbus Mux control
//		printf("\tCbus2 = 0x%X\n", Data.Cbus2);				// Cbus Mux control
//		printf("\tCbus3 = 0x%X\n", Data.Cbus3);				// Cbus Mux control
//		printf("\tCbus4 = 0x%X\n", Data.Cbus4);				// Cbus Mux control
//        
//		printf("\tRIsD2XX = 0x%X\n", Data.RIsD2XX); // non-zero if using D2XX
//	}
//    
    
    Data.SerialNumber = newname;		// if fixed, or NULL
    printf("new SerialNumber = %s\n", Data.SerialNumber);
    
    ftStatus = FT_EE_Program(ftHandle0, &Data);
	if(ftStatus != FT_OK) {
		printf("FT_EE_Program failed (%d)\n", (int)ftStatus);
		FT_Close(ftHandle0);
	}else{
        printf("FT_EE_Read succeeded!!!.\n\n");
    }
    
exit:
	free(Data.Manufacturer);
	free(Data.ManufacturerId);
	free(Data.Description);
    //	free(Data.SerialNumber);
    
    
    
	FT_Close(ftHandle0);
	printf("Returning %d\n", retCode);
	return retCode;
}
