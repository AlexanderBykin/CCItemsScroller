//
//  CCSelectableItem.h
//
//  Created by Aleksander Bykin on 02.07.12.
//  Copyright (c) 2012. All rights reserved.
//

// Description: This class is just for sample, you can inherit CCSelectableItemDelegate protocol anytime for your self writed selectable item and implement its unique logic.

#import "cocos2d.h"
#import "CCItemsScroller.h"

@interface CCSelectableItem : CCLayerColor<CCSelectableItemDelegate>

@property (assign, nonatomic) BOOL isSelected;
@property (assign, nonatomic) ccColor4B normalColor;
@property (assign, nonatomic) ccColor4B selectedColor;

-(id)initWithNormalColor:(ccColor4B)normalColor andSelectectedColor:(ccColor4B)selectedColor andWidth:(GLfloat)w andHeight:(GLfloat)h;

@end
