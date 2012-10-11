//
//  CCItemsScroller.h
//
//  Created by Aleksander Bykin on 26.06.12.
//  Copyright 2012. All rights reserved.
//

#import "cocos2d.h"

typedef enum{
    CCItemsScrollerVertical,
    CCItemsScrollerHorizontal
} CCItemsScrollerOrientations;

@protocol CCItemsScrollerDelegate;

@interface CCItemsScroller : CCLayer
#ifdef __CC_PLATFORM_MAC
{
    BOOL activatedEvent;
    CGPoint _clickedPoint;
}
#endif

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