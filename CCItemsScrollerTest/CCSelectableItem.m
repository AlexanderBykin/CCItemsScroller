//
//  CCSelectableItem.m
//
//  Created by Aleksander Bykin on 02.07.12.
//  Copyright (c) 2012. All rights reserved.
//

// Description: This class is just for sample, you can inherit CCSelectableItemDelegate protocol anytime for your self writed selectable item and implement its unique logic.

#import "CCSelectableItem.h"

@implementation CCSelectableItem{
    CGPoint _beginTouch;
}

-(id)initWithNormalColor:(ccColor4B)normalColor andSelectectedColor:(ccColor4B)selectedColor andWidth:(GLfloat)w andHeight:(GLfloat)h{
    self = [super initWithColor:normalColor width:w height:h];
    
    if(self){
        _isSelected = NO;
        _normalColor = normalColor;
        _selectedColor = selectedColor;
    }
    
    return self;
}

-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    
    if(_isSelected){
        self.color = ccc3(_selectedColor.r, _selectedColor.g, _selectedColor.b);
        self.opacity = _selectedColor.a;
    }
    else{
        self.color = ccc3(_normalColor.r, _normalColor.g, _normalColor.b);
        self.opacity = _normalColor.a;
    }
}

@end
