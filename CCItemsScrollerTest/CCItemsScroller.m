/*
 This content is released under the MIT License.
 
 Copyright (c) 2012 Aleksander Bykin
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "CCItemsScroller.h"

#define MAX_VEL (5.0f)

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
    CGPoint _clickedPoint; //location of touch begin/mouse down event
    CGPoint _distMov;
    CGPoint _prevMovPos;
    CGFloat velMul;
    BOOL _activatedEvent;
    
    CGFloat _timeDiff, _startTime, _endTime;
#ifdef __CC_PLATFORM_IOS
    
#elif defined (__CC_PLATFORM_MAC)
    
#endif
}

@synthesize delegate=_delegate, orientation=_orientation, isSwallowTouches=_isSwallowTouches;

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
        _activatedEvent = NO;
        
        _lastPos = CGPointZero;
        _velPos = CGPointZero;
        _clickedPoint = CGPointZero;
        _distMov = CGPointZero;
        _prevMovPos = CGPointZero;
        velMul = _timeDiff = _startTime = _endTime = 0.0f;
        
#ifdef __CC_PLATFORM_IOS
        self.isTouchEnabled = YES;
#elif defined(__CC_PLATFORM_MAC)
        self.isMouseEnabled = YES;
        //self.isKeyboardEnabled = YES;
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
    
    CGFloat friction = 0.95f;
    
    if(_isDragging == NO){
        // inertia
        _velPos = CGPointMake(_velPos.x*friction, _velPos.y*friction);
        
        CCMoveTo *moveTo = nil;
        
        if(_orientation == CCItemsScrollerHorizontal){
            _offset.x += _velPos.x;
            
            if(_offset.x > _rect.origin.x){
                _isAnimationEnabled = NO;
                _velPos.x *= -1;
                _offset.x = _rect.origin.x;
                moveTo = [CCMoveTo actionWithDuration:0.3f position:CGPointMake(_rect.origin.x, _offset.y)];
            }
            else if(_offset.x < -(self.contentSize.width-_rect.size.width-_rect.origin.x)){
                _isAnimationEnabled = NO;
                _velPos.x *= -1;
                _offset.x = -(self.contentSize.width-_rect.size.width-_rect.origin.x);
                moveTo = [CCMoveTo actionWithDuration:0.3f position:CGPointMake(-(self.contentSize.width-_rect.size.width-_rect.origin.x), _offset.y)];
            }
        }
        
        if(_orientation == CCItemsScrollerVertical){
            _offset.y += _velPos.y;
            
            if (_offset.y > _rect.origin.y) {
                _isAnimationEnabled = NO;
                _velPos.y *= -1;
                _offset.y = _rect.origin.y;
                moveTo = [CCMoveTo actionWithDuration:0.3f position:CGPointMake(_offset.x, _rect.origin.y)];
            }
            else if (_offset.y < -(self.contentSize.height-_rect.size.height-_rect.origin.y))
            {
                _isAnimationEnabled = NO;
                _velPos.y *= -1;
                _offset.y = -(self.contentSize.height-_rect.size.height-_rect.origin.y);
                moveTo = [CCMoveTo actionWithDuration:0.3f position:CGPointMake(_offset.x, -(self.contentSize.height-_rect.size.height-_rect.origin.y))];
            }
        }
        
        if(_orientation == CCItemsScrollerVertical){
            _offset.y += _velPos.y;
            
            if (_offset.y > _rect.origin.y) {
                _isAnimationEnabled = NO;
                _velPos.y *= -1;
                _offset.y = _rect.origin.y;
                moveTo = [CCMoveTo actionWithDuration:0.3f position:CGPointMake(_offset.x, _rect.origin.y)];
            }
            else if (_offset.y < -(self.contentSize.height-_rect.size.height-_rect.origin.y))
            {
                _isAnimationEnabled = NO;
                _velPos.y *= -1;
                _offset.y = -(self.contentSize.height-_rect.size.height-_rect.origin.y);
                moveTo = [CCMoveTo actionWithDuration:0.3f position:CGPointMake(_offset.x, -(self.contentSize.height-_rect.size.height-_rect.origin.y))];
            }
        }
        
        if(moveTo == nil){
            self.position = ccp(_offset.x, _offset.y);
        }
        else {
            [self runAction:moveTo];
        }
    }
    else
    {
        _velPos.x = ( self.position.x - _lastPos.x ) / 2;
        _velPos.y = ( self.position.y - _lastPos.y ) / 2;
        
        _velPos = ccpMult(_velPos,velMul);
        NSLog(@"_timeDiff: %.2f, velMul: %.2f", _timeDiff, velMul);
        
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
        
        item.position = ccp(x, y);
        
        if (!item.parent) {
            [self addChild:item];
        }
        
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
    
    glEnable(GL_SCISSOR_TEST);
    glScissor(_glRect.origin.x, _glRect.origin.y, _glRect.size.width, _glRect.size.height);
    
    [super visit];
    
    glDisable(GL_SCISSOR_TEST);
}

#ifdef __CC_PLATFORM_IOS


- (void)registerWithTouchDispatcher
{
    CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];
    int priority = INT_MIN;
    
    [dispatcher addTargetedDelegate:self priority:priority swallowsTouches:_isSwallowTouches];
}

#elif defined (__CC_PLATFORM_MAC)

-(NSInteger) mouseDelegatePriority {
    return INT_MIN;
}

#endif

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
    
    _startTime = CACurrentMediaTime();
    _clickedPoint = touchPoint;
    _activatedEvent = result;
    
    return result;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    _distMov = ccpSub(touchPoint, _prevMovPos);
    _endTime = CACurrentMediaTime();
    _timeDiff = _endTime - _startTime;
    
    _timeDiff = MAX(_timeDiff, 0.35f);
    
    CGFloat distCovered = ABS(ccpLengthSQ(_distMov));
    velMul = ((distCovered/(_timeDiff*_timeDiff))/10000.0f);
    velMul = MAX(velMul, 1.0f);
    velMul = MIN(velMul, MAX_VEL);
    
    if (_isDragging == YES)
    {
        if(_orientation == CCItemsScrollerHorizontal){
            _offset.x = _startSwipe.x + touchPoint.x;
        }
        
        if(_orientation == CCItemsScrollerVertical){
            _offset.y = _startSwipe.y + touchPoint.y;
        }
        self.position = ccp(_offset.x, _offset.y);
    }
    
    CGFloat diffSQ = ccpLengthSQ(ccpSub(touchPoint, _clickedPoint));
    if(ABS(diffSQ) >32.0f) {
        _isFingerMoved = YES;
    }
    else {
        _isFingerMoved = NO;
    }
    
    _prevMovPos = touchPoint;
    _startTime = _endTime;
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
        
        if(isX && isY && !_isFingerMoved && _activatedEvent){
            [self setSelectedItemIndex:[self.children indexOfObject:item]];
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
    
    _startTime = CACurrentMediaTime();
    _clickedPoint = location;
    _activatedEvent = result;
    
    return result;
    
}

-(BOOL) ccMouseDragged:(NSEvent *)event {
    CGPoint location = [(CCDirectorMac*)[CCDirector sharedDirector] convertEventToGL:event];
    
    _distMov = ccpSub(location, _prevMovPos);
    _endTime = CACurrentMediaTime();
    _timeDiff = _endTime - _startTime;
    
    _timeDiff = MAX(_timeDiff, 0.35f);
    
    CGFloat distCovered = ABS(ccpLengthSQ(_distMov));
    velMul = ((distCovered/(_timeDiff*_timeDiff))/10000.0f);
    velMul = MAX(velMul, 1.0f);
    velMul = MIN(velMul, MAX_VEL);
    
    if (_isDragging == YES)
    {
        if(_orientation == CCItemsScrollerHorizontal){
            _offset.x = _startSwipe.x + location.x;
        }
        
        if(_orientation == CCItemsScrollerVertical){
            _offset.y = _startSwipe.y + location.y;
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
    //NSLog(@"mouseUp");
    
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
        
        if(isX && isY && !_isFingerMoved && _activatedEvent ){
            [self setSelectedItemIndex:[self.children indexOfObject:item]];
            return YES;
        }
    }
    
    return NO;
}
#endif

-(void)setSelectedItemIndex:(NSInteger)index{
    id currentChild = [self.children objectAtIndex:index];
    id lastSelectedChild = [self.children objectAtIndex:_lastSelectedIndex];
    
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

@end
