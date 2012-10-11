//
//  main.m
//  CCItemsScrollerTest
//
//  Created by  on 17.07.12.
//  Copyright Apple 2012. All rights reserved.
//

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#import <UIKit/UIKit.h>
#import "cocos2d.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"AppController");
    [pool release];
    return retVal;
}

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

#import <Cocoa/Cocoa.h>
#import "cocos2d.h"

int main(int argc, char *argv[])
{
	[CCGLView load_];
    return NSApplicationMain(argc,  (const char **) argv);
}

#endif
