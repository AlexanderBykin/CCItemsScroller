/*
 This content is released under the MIT License.
 
 Copyright (c) 2012 Aleksander Bykin
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "cocos2d.h"

typedef enum{
    CCItemsScrollerVertical,
    CCItemsScrollerHorizontal
} CCItemsScrollerOrientations;

@protocol CCItemsScrollerDelegate;

@interface CCItemsScroller : CCLayer

@property (strong, nonatomic) id<CCItemsScrollerDelegate> delegate;
@property (assign, nonatomic) CCItemsScrollerOrientations orientation;
@property (assign, nonatomic) BOOL isSwallowTouches;

+(id)itemsScrollerWithItems:(NSArray*)items andOrientation:(CCItemsScrollerOrientations)orientation andRect:(CGRect)rect;

-(id)initWithItems:(NSArray*)items andOrientation:(CCItemsScrollerOrientations)orientation andRect:(CGRect)rect;

-(void)updateItems:(NSArray*)items;

@end

// Items scroller delegate for catch event
@protocol CCItemsScrollerDelegate <NSObject>

@required

- (void)itemsScroller:(CCItemsScroller *)sender didSelectItemIndex:(int)index;
- (void)itemsScroller:(CCItemsScroller *)sender didUnSelectItemIndex:(int)index;

@end

// Selectable item protocol, inherit it to implement your unique selectable items
@protocol CCSelectableItemDelegate <NSObject>

@optional

-(void)setIsSelected:(BOOL)isSelected;

@end