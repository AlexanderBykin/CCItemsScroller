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

#import "HelloWorldLayer.h"
#import "CCSelectableItem.h"

@implementation HelloWorldLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	[scene addChild: layer];
	
	return scene;
}

-(id) init
{
    self = [super init];
    
	if(self) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
        
#ifdef __CC_PLATFORM_MAC
        self.isMouseEnabled = YES;
#endif
        
        CCLayerColor *bg = [CCLayerColor layerWithColor:ccc4(165, 0, 12, 255) width:winSize.width height:winSize.height];
        [self addChild:bg];
        
        NSMutableArray *pageArray = [NSMutableArray array];
        
        // Horizontal scroller
        CCLabelTTF *label1 = [CCLabelTTF labelWithString:@"Horizontal scroller" fontName:@"Marker Felt" fontSize:18];
        label1.position = ccp(winSize.width/2, winSize.height-label1.contentSize.height/2);
        [self addChild:label1];
        
        for (int i = 0; i < 15; i++) {
            CCSelectableItem *page = [[CCSelectableItem alloc] initWithNormalColor:ccc4(0,0,0,0) andSelectectedColor:ccc4(190, 150, 150, 255) andWidth:100 andHeight:100];
            
            CCSprite *image = [CCSprite spriteWithFile:(i % 2 == 0) ? @"bullet1.png" : @"bullet2.png"];
            image.position = ccp(page.contentSize.width/2, page.contentSize.height/2);
            [page addChild:image];
            
            [pageArray addObject:page];
        }
        
        CCItemsScroller *itemsScroller1 = [CCItemsScroller itemsScrollerWithItems:pageArray andOrientation:CCItemsScrollerHorizontal andRect:CGRectMake(20, winSize.height-120, winSize.width-40, 100)];
        itemsScroller1.delegate = self;
        [self addChild:itemsScroller1];
        
        
        
        // Vertical scroller        
        CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"Vertical scroller" fontName:@"Marker Felt" fontSize:18];
        label2.position = ccp(winSize.width/2, winSize.height-130-label1.contentSize.height/2);
        [self addChild:label2];
        
        pageArray = [NSMutableArray array];
        
        for (int i = 0; i < 400; i++) {
            CCSelectableItem *page = [[CCSelectableItem alloc] initWithNormalColor:ccc4(150, 150, 150, 125) andSelectectedColor:ccc4(190, 150, 150, 255) andWidth:winSize.width-40 andHeight:40];
            
            CCLabelTTF *lbl = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"item #%d", i+1] fontName:@"Marker Felt" fontSize:15];
            lbl.position = ccp(page.contentSize.width/2, page.contentSize.height/2);
            [page addChild:lbl];
            
            [pageArray addObject:page];
        }
        
        CCItemsScroller *itemsScroller2 = [CCItemsScroller itemsScrollerWithItems:pageArray andOrientation:CCItemsScrollerVertical andRect:CGRectMake(20, 20, winSize.width-40, winSize.height-170)];
        itemsScroller2.delegate = self;
        [self addChild:itemsScroller2];     
	}
    
	return self;
}

-(void)itemsScroller:(CCItemsScroller *)sender didSelectItemIndex:(int)index{
    NSLog(@"Selected item index = '%d'", index);
}

-(void)itemsScroller:(CCItemsScroller *)sender didUnSelectItemIndex:(int)index{
    
}

@end
