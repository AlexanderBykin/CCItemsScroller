//
//  CCItemsScroller.m
//
//  Created by Aleksander Bykin on 26.06.12.
//  Copyright 2012. All rights reserved.
//

#import "CCItemsScroller.h"

@implementation CCItemsScroller{
    CGRect _rect;
    CGPoint _startSwipe;
    CGPoint _offset;
    CGSize _itemSize;
    NSInteger _lastSelectedIndex;
    BOOL _isDragging;
    BOOL _isFingerMoved;
    BOOL _isAnimationEnabled;
    CGPoint _lastPos;
    CGPoint _velPos;
}

+(id)itemsScrollerWithItems:(NSArray *)items andOrientation:(CCItemsScrollerOrientations)orientation andRect:(CGRect)rect{
    return [[self alloc] initWithItems:items andOrientation:(CCItemsScrollerOrientations)orientation andRect:rect];
}

-(id)initWithItems:(NSArray *)items andOrientation:(CCItemsScrollerOrientations)orientation andRect:(CGRect)rect{
    self = [super init];
    
    if(self){
        _rect = rect;
        _orientation = orientation;
        _isSwallowTouches = YES;
        
        _isDragging = NO;
        _isFingerMoved = NO;
        _isAnimationEnabled = NO;

        _lastPos = CGPointZero;
        _velPos = CGPointZero;

#ifdef __CC_PLATFORM_IOS
        self.isTouchEnabled = YES;
#elif defined(__CC_PLATFORM_MAC)
        self.isMouseEnabled = YES;
        //self.isKeyboardEnabled = YES;
        activatedEvent = NO;
#endif
        [self updateItems:items];
        
        [self schedule:@selector(moveTick:)];
    }
    
    return self;
}

-(void)moveTick:(ccTime)delta{
    if(_isAnimationEnabled == NO){
        return;
    }
    
    float friction = 0.95f;
    
    if(_isDragging == NO){
        // inertia
        _velPos = CGPointMake(_velPos.x*friction, _velPos.y*friction);
        
        if(_orientation == CCItemsScrollerHorizontal){
            _offset.x += _velPos.x;
            
            if(_offset.x > _rect.origin.x){
                _isAnimationEnabled = NO;
                _velPos.x *= -1;
                _offset.x = _rect.origin.x;
            }
            else if(_offset.x < -(self.contentSize.width-_rect.size.width-_rect.origin.x)){
                _isAnimationEnabled = NO;
                _velPos.x *= -1;
                _offset.x = -(self.contentSize.width-_rect.size.width-_rect.origin.x);
            }
        }
        
        if(_orientation == CCItemsScrollerVertical){
            _offset.y += _velPos.y;
            
            if (_offset.y > _rect.origin.y) {
                _isAnimationEnabled = NO;
                _velPos.y *= -1;
                _offset.y = _rect.origin.y;
            }
            else if (_offset.y < -(self.contentSize.height-_rect.size.height-_rect.origin.y))
            {
                _isAnimationEnabled = NO;
                _velPos.y *= -1;
                _offset.y = -(self.contentSize.height-_rect.size.height-_rect.origin.y);
            }
        }
        
        self.position = ccp(_offset.x, _offset.y);
    }
    else
    {
        _velPos.x = ( self.position.x - _lastPos.x ) / 2;
        _velPos.y = ( self.position.y - _lastPos.y ) / 2;
        _lastPos = CGPointMake(self.position.x, self.position.y);
    }
}

-(void)updateItems:(NSArray*)items{
    int i = 0;
    CGFloat x = 0;
    CGFloat y = 0;
    
    for (CCNode *item in items)
    {
        if(i == 0){
            int csWidth = 0;
            int csHeight = 0;
            
            _itemSize = CGSizeMake(item.contentSize.width, item.contentSize.height);
            
            if(_orientation == CCItemsScrollerHorizontal){
                csWidth = items.count*_itemSize.width;
                csHeight = _rect.size.height;
            }
            
            if(_orientation == CCItemsScrollerVertical){
                csWidth = _rect.size.width;
                csHeight = items.count*_itemSize.height;
            }
            
            self.contentSize = CGSizeMake(csWidth, csHeight);
        }
        
        if (_orientation == CCItemsScrollerHorizontal) {
            x = (i * item.contentSize.width);
        }
        
        if(_orientation == CCItemsScrollerVertical){
            CGFloat itemOffsetY = (i+1) * item.contentSize.height;
            NSLog(@"Item %d offsetY='%f'", i, itemOffsetY);
            y = self.contentSize.height - itemOffsetY;
        }
        
        item.tag = i;
        item.position = ccp(x, y);
        
        if (!item.parent)
            [self addChild:item z:i tag:i];
        
        ++i;
    }
    
    _offset.x = _rect.origin.x;
    _offset.y = _rect.origin.y;
    
    if(_orientation == CCItemsScrollerHorizontal)
        self.position = ccp(_rect.origin.x, _rect.origin.y);
    
    if(_orientation == CCItemsScrollerVertical){
        _offset.y = -(self.contentSize.height-_rect.size.height-_rect.origin.y);
        self.position = ccp(_rect.origin.x, _offset.y);
    }
}

-(void) visit
{
    CGRect _glRect = CC_RECT_POINTS_TO_PIXELS(_rect);
    
    //glPushMatrix();
    glEnable(GL_SCISSOR_TEST);
    glScissor(_glRect.origin.x, _glRect.origin.y, _glRect.size.width, _glRect.size.height);
    
    [super visit];
    
    glDisable(GL_SCISSOR_TEST);
    //glPopMatrix();
}

#ifdef __CC_PLATFORM_IOS


- (void)registerWithTouchDispatcher
{
    CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];
    int priority = INT_MIN - 1;
    
    [dispatcher addTargetedDelegate:self priority:priority swallowsTouches:_isSwallowTouches];
}

/*
-(void) onEnterTransitionDidFinish
{
    int priority = INT_MIN - 1;
    
    NSLog(@"Setting up touch events...");
    CCDirector *director =  (CCDirector*)[CCDirector sharedDirector];
    [[director touchDispatcher] removeDelegate:self];
	[[director touchDispatcher] addTargetedDelegate:self priority:priority  swallowsTouches:YES];
    
    //CMLog(@"...%s...", __PRETTY_FUNCTION__);
	[super onEnterTransitionDidFinish];
}

#elif defined (__CC_PLATFORM_MAC)
-(void) onEnter
{
    int priority = INT_MIN - 1;
    
    NSLog(@"Setting up mouse events...");
    [[[CCDirector sharedDirector] eventDispatcher] removeMouseDelegate:self];
    [[[CCDirector sharedDirector] eventDispatcher] addMouseDelegate:self priority:priority];
    
    [super onEnter];
}
 */

#elif defined (__CC_PLATFORM_MAC)

-(NSInteger) mouseDelegatePriority {
    return INT_MIN - 1;
}

#endif

/*
- (void)onExit
{
#ifdef __CC_PLATFORM_IOS
    CCDirector *director =  (CCDirector*)[CCDirector sharedDirector];
	[[director touchDispatcher] removeDelegate:self];
#elif defined (__CC_PLATFORM_MAC)
    [[[CCDirector sharedDirector] eventDispatcher] removeMouseDelegate:self];
#endif
	[super onExit];
}
 */

#ifdef __CC_PLATFORM_IOS
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];    
    
    // Swallow touches
    BOOL result = (CGRectContainsPoint(_rect, touchPoint) || !_isSwallowTouches);
    
    _isDragging = result;
    
    _startSwipe = CGPointMake(_offset.x - touchPoint.x, _offset.y - touchPoint.y);
    
    _isFingerMoved = NO;
    
    return result;    
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    //NSLog(@"mouseDragged ... ccTouchMoved");
    
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];    
    
    if (_isDragging == YES)
    {
        if(_orientation == CCItemsScrollerHorizontal){
            _offset.x = _startSwipe.x + touchPoint.x;
            
            if(_offset.x > _rect.origin.x){
                _offset.x = _rect.origin.x;
            }
            else if(_offset.x < -(self.contentSize.width-_rect.size.width-_rect.origin.x)){
                _offset.x = -(self.contentSize.width-_rect.size.width-_rect.origin.x);
            }
        }
        
        if(_orientation == CCItemsScrollerVertical){
            _offset.y = _startSwipe.y + touchPoint.y;
            
            if(_startSwipe.y < touchPoint.y){
                if (_offset.y > _rect.origin.y) {
                    _offset.y = _rect.origin.y;
                }else
                    if (_offset.y < -(self.contentSize.height-_rect.size.height-_rect.origin.y))
                    {
                        _offset.y = -(self.contentSize.height-_rect.size.height-_rect.origin.y);
                    }
            }
            else {
                if (_offset.y > _rect.origin.y) {
                    _offset.y = _rect.origin.y;
                }
            }
        }
        
        if(self.position.x != _offset.x || self.position.y != _offset.y){
            _isFingerMoved = YES;
        }
        
        self.position = ccp(_offset.x, _offset.y);
    }
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    _isDragging = NO;
    _isAnimationEnabled = _isFingerMoved;
    
    // Finger moved, do not select item
    if(_isFingerMoved == YES){
        return;
    }
    
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];    
    
    CGFloat touchX = 0;
    CGFloat touchY = 0;
    
    if(_orientation == CCItemsScrollerHorizontal){
        touchY = touchPoint.y;
        touchX = self.position.x*-1 + touchPoint.x;
    }
    
    if(_orientation == CCItemsScrollerVertical){
        touchX = touchPoint.x;
        touchY = self.position.y - touchPoint.y;
        
        if(touchY < 0)
            touchY *= -1;
    }
    
    for (CCLayer *item in self.children) {
        BOOL isX = NO;
        BOOL isY = NO;
        
        if(_orientation == CCItemsScrollerHorizontal){
            isX = (touchX >= item.position.x && touchX <= item.position.x + item.contentSize.width);
            isY = (touchY >= self.position.y && touchY <= self.position.y + item.contentSize.height);
        }
        
        if(_orientation == CCItemsScrollerVertical){        
            isX = (touchX >= item.position.x && touchX <= item.contentSize.width);
            isY = (touchY >= item.position.y && touchY <= item.position.y + item.contentSize.height);
        }
        
        if(isX && isY){
            [self setSelectedItemIndex:item.tag];            
            break;
        }
    }
    
}
#elif defined (__CC_PLATFORM_MAC)
-(BOOL) ccMouseDown:(NSEvent*)event {
    
    CGPoint location = [(CCDirectorMac*)[CCDirector sharedDirector] convertEventToGL:event];
    
    // Swallow touches
    BOOL result = (CGRectContainsPoint(_rect, location) || !_isSwallowTouches);
    
    _isDragging = result;
    
    _startSwipe = CGPointMake(_offset.x - location.x, _offset.y - location.y);
    
    _isFingerMoved = NO;
    
    activatedEvent = result;
    
    _clickedPoint = location;
    
    //NSLog(@"mouseDown");
    
    return result;
    
}

-(BOOL) ccMouseDragged:(NSEvent *)event {
    //NSLog(@"mouseDragged");

    
    CGPoint location = [(CCDirectorMac*)[CCDirector sharedDirector] convertEventToGL:event];
    
    if (_isDragging == YES)
    {
        if(_orientation == CCItemsScrollerHorizontal){
            _offset.x = _startSwipe.x + location.x;
            
            if(_offset.x > _rect.origin.x){
                _offset.x = _rect.origin.x;
            }
            else if(_offset.x < -(self.contentSize.width-_rect.size.width-_rect.origin.x)){
                _offset.x = -(self.contentSize.width-_rect.size.width-_rect.origin.x);
            }
        }
        
        if(_orientation == CCItemsScrollerVertical){
            _offset.y = _startSwipe.y + location.y;
            
            if(_startSwipe.y < location.y){
                if (_offset.y > _rect.origin.y) {
                    _offset.y = _rect.origin.y;
                }else
                    if (_offset.y < -(self.contentSize.height-_rect.size.height-_rect.origin.y))
                    {
                        _offset.y = -(self.contentSize.height-_rect.size.height-_rect.origin.y);
                    }
            }
            else {
                if (_offset.y > _rect.origin.y) {
                    _offset.y = _rect.origin.y;
                }
            }
        }
        
        self.position = ccp(_offset.x, _offset.y);
    }
    
    
    CGFloat diffSQ = ccpLengthSQ(ccpSub(location, _clickedPoint));
    
    if(ABS(diffSQ) >32.0f) {
        _isFingerMoved = YES;
    }
    else {
        _isFingerMoved = NO;
    }
    return NO;
}

-(BOOL) ccMouseUp:(NSEvent*)event {
    //NSAssert(state == kBoxStateGrabbed, @"Paddle - Unexpected state!");
    NSLog(@"mouseUp");
    
    _isDragging = NO;
    _isAnimationEnabled = _isFingerMoved;
    
    CGPoint location = [(CCDirectorMac*)[CCDirector sharedDirector] convertEventToGL:event];
    
    CGFloat touchX = 0;
    CGFloat touchY = 0;
    
    if(_orientation == CCItemsScrollerHorizontal){
        touchY = location.y;
        touchX = self.position.x*-1 + location.x;
    }
    
    if(_orientation == CCItemsScrollerVertical){
        touchX = location.x;
        touchY = self.position.y - location.y;
        
        if(touchY < 0)
            touchY *= -1;
    }
    
    for (CCLayer *item in self.children) {
        BOOL isX = NO;
        BOOL isY = NO;
        
        if(_orientation == CCItemsScrollerHorizontal){
            isX = (touchX >= item.position.x && touchX <= item.position.x + item.contentSize.width);
            isY = (touchY >= self.position.y && touchY <= self.position.y + item.contentSize.height);
        }
        if(_orientation == CCItemsScrollerVertical){
            isX = (touchX >= item.position.x && touchX <= item.contentSize.width);
            isY = (touchY >= item.position.y && touchY <= item.position.y + item.contentSize.height);
        }
        
        if(isX && isY && !_isFingerMoved && activatedEvent ){
            [self setSelectedItemIndex:item.tag];
            return YES;
        }
    }
    
    return NO;
}
#endif

-(void)setSelectedItemIndex:(NSInteger)index{
    id currentChild = [self getChildByTag:index];
    id lastSelectedChild = [self getChildByTag:_lastSelectedIndex];
    
    if([lastSelectedChild respondsToSelector:@selector(setIsSelected:)])
    {
        [lastSelectedChild setIsSelected:NO];
        
        if([_delegate respondsToSelector:@selector(itemsScroller:didUnSelectItemIndex:)]){
#ifdef __CC_PLATFORM_IOS
            [_delegate itemsScroller:self didUnSelectItemIndex:_lastSelectedIndex];
#elif defined (__CC_PLATFORM_MAC)
            [_delegate itemsScroller:self didUnSelectItemIndex:(int)_lastSelectedIndex];
#endif
        }
    }
    
    if([currentChild respondsToSelector:@selector(setIsSelected:)]){
        [currentChild setIsSelected:YES];
    }
    
    _lastSelectedIndex = index;
    
    if([_delegate respondsToSelector:@selector(itemsScroller:didSelectItemIndex:)]) {
#ifdef __CC_PLATFORM_IOS
        [_delegate itemsScroller:self didSelectItemIndex:index];
#elif defined (__CC_PLATFORM_MAC)
        [_delegate itemsScroller:self didSelectItemIndex:(int)index];
#endif
    }
}

-(CCNode*) getItemWithIndex:(int)index{
    return [self getChildByTag:index];
}

@end
