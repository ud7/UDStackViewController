//
//  UDAppDelegate.m
//  UDStackView
//
//  Created by Rolandas Razma on 8/21/11.
//  Copyright (c) 2011 UD7. All rights reserved.
//

#import "UDAppDelegate.h"
#import "UDMainViewController.h"
#import "UDStackNavigationController.h"


@implementation UDAppDelegate {
    UIWindow *_window;
}


- (void)dealloc {
    [_window release];
    [super dealloc];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UDMainViewController *mainViewController = [[[UDMainViewController alloc] init] autorelease];
    UDStackNavigationController *stackNavigationController = [[[UDStackNavigationController alloc] initWithRootViewController:mainViewController] autorelease];
    [stackNavigationController setDelegate:mainViewController];
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_window setRootViewController:stackNavigationController];
    [_window makeKeyAndVisible];

    return YES;
}


@end
