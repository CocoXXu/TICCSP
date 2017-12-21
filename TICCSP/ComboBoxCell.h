//
//  ComboBoxCell.h
//  TICCSP
//
//  Created by apple on 17/12/21.
//  Copyright © 2017年 coco. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ComboBoxCell : NSComboBoxCell
- (void)popUpList;

- (void)closePopUpWindow;

- (BOOL)isPopUpWindowVisible;
@end
