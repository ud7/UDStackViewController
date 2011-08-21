//
//  UDStackNavigationController.m
//
//  Created by Rolandas Razma on 8/21/11.
//  Copyright (c) 2011 UD7. All rights reserved.
//

#import "UDStackNavigationController.h"
#import <QuartzCore/QuartzCore.h>


@implementation UDStackNavigationController {
    NSString        *_reuseIdentifier;
    NSMutableArray  *_viewControllersViewCache;
}


#pragma mark -
#pragma mark NSObject


- (void)dealloc {
    [_viewControllersViewCache release];
    [_reuseIdentifier release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark UDStackNavigationController


- (id)initWithRootViewController:(UIViewController *)rootViewController reuseIdentifier:(NSString *)reuseIdentifier {
    if( (self = [super initWithRootViewController:rootViewController]) ){
        _reuseIdentifier            = [reuseIdentifier copy];
    }
    return self;
}


- (UIImage *)topViewCache {
    UIViewController *topViewController = self.topViewController;
    if( [topViewController isViewLoaded] ){
        // Grab look
        UIGraphicsBeginImageContext(topViewController.view.frame.size);
        [topViewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        [_viewControllersViewCache removeLastObject];
        [_viewControllersViewCache addObject:UIGraphicsGetImageFromCurrentImageContext()];
        UIGraphicsEndImageContext();
    }
    return [_viewControllersViewCache lastObject];
}


#pragma mark -
#pragma mark UINavigationController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // Leave only recent 3
    if( _viewControllersViewCache.count > 3 ){
        [_viewControllersViewCache removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _viewControllersViewCache.count -3)]];
    }
}


#pragma mark -
#pragma mark UINavigationController


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if( !_viewControllersViewCache ) {
        _viewControllersViewCache = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    // Grab look of old view
    if( self.topViewController ){
        UIGraphicsBeginImageContext(self.topViewController.view.frame.size);
        [self.topViewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        [_viewControllersViewCache removeLastObject];
        [_viewControllersViewCache addObject:UIGraphicsGetImageFromCurrentImageContext()];
        UIGraphicsEndImageContext();
    }
    
    [super pushViewController:viewController animated:animated];
    
    // Grab look of new view
    UIGraphicsBeginImageContext(self.topViewController.view.frame.size);
    [self.topViewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    [_viewControllersViewCache addObject:UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();
}


- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if( _viewControllersViewCache.count ) [_viewControllersViewCache removeLastObject];
    return [super popViewControllerAnimated:animated];
}


@synthesize reuseIdentifier=_reuseIdentifier, viewControllersViewCache=_viewControllersViewCache;
@end
