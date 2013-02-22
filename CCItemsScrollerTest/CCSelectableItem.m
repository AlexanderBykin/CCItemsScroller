/*
 This content is released under the MIT License.
 
 Copyright (c) 2012 Aleksander Bykin
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/*
 Description: This class is just for sample, you can inherit CCSelectableItemDelegate protocol anytime,
 for your self writed selectable item and implement its unique logic.
 */

#import "CCSelectableItem.h"

@implementation CCSelectableItem

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
