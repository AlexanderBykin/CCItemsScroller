//
//  AppDelegate.h
//  CCItemsScrollerTest
//
//  Created by  on 17.07.12.
//  Copyright Apple 2012. All rights reserved.
//

#import "cocos2d.h"

#ifdef __CC_PLATFORM_IOS

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
    
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;

#elif defined(__CC_PLATFORM_MAC)

@interface AppController : NSObject <NSApplicationDelegate>
{
    
}

@property (strong) IBOutlet NSWindow	*window;
@property (strong) IBOutlet CCGLView	*glView;

- (IBAction)toggleFullScreen:(id)sender;

#endif

@end
