//
//  eeprom.h
//  FT232R-TOOLS
//
//  Created by user on 8/19/15.
//  Copyright (c) 2015 ___LEON_ZHANG___. All rights reserved.
//

//#include "ftd2xx.h"

#ifndef FT232R_TOOLS_eeprom_h
#define FT232R_TOOLS_eeprom_h

#define BUF_SIZE 0x10

#define MAX_DEVICES		50

extern int * mainRead(int argc, char *argv[],char *name  );
//extern int mainWrite(int argc, char *argv[],char *name);
//int mainWrite(int argc, char *argv[],char *name ,char *describtion);



extern int mainGet(char allFiture[MAX_DEVICES][64] , int dnum);

extern int mainReadWithName(char *name,char *Description,char *ProductId,char *VendorId,char *Manufacturer,char *newsn);


extern int mainWriteName(char *oldname , char *newname);

extern int mainWriteDesciption(char *oldname , char *newdesc);

#endif
