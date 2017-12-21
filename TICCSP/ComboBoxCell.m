//
//  ComboBoxCell.m
//  TICCSP
//
//  Created by apple on 17/12/21.
//  Copyright © 2017年 coco. All rights reserved.
//

#import "ComboBoxCell.h"

@implementation ComboBoxCell
- (void)popUpList

{
    
    if ([self isPopUpWindowVisible])
        
    {
        
        return;
        
    }
    
    else
        
    {
        
        [_buttonCell performClick:nil];//模拟鼠标事件
        
    }
    
}

- (void)closePopUpWindow

{
    
    if ([self isPopUpWindowVisible])
        
    {
        
        [_popUp close];
        
    }
    
}

- (BOOL)isPopUpWindowVisible

{
    
    return [_popUp isVisible];
    
}


@end
