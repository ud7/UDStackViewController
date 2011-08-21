//
//  UDStackController.m
//
//  Created by Rolandas Razma on 8/21/11.
//  Copyright (c) 2011 UD7. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UDStackViewController.h"
#import "UDStackNavigationController.h"


@interface UDStackViewController (UDPrivate)

- (void)dismissStackNavigationController:(UDStackNavigationController *)controller toRect:(CGRect)rect;

@end


@implementation UDStackViewController {
    UINavigationBar             *_navigationBar;
    NSMutableDictionary         *_stackNavigationControllers;
    UIButton                    *_changeStackStateButton;
    
    UIView                      *_originalView;
    
    NSString                    *_lastActiveStackIdentifier;
    CGRect                      _lastActiveStackPresentationRect;
}


#pragma mark -
#pragma mark NSObject


- (void)dealloc {
    [_stackNavigationControllers release];
    [super dealloc];
}


#pragma mark -
#pragma mark UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // We need to put UINavigationBar so switch views
    _originalView = self.view;
    UIView *parentView = [[[UIView alloc] initWithFrame:_originalView.frame] autorelease];
    [parentView setAutoresizingMask:_originalView.autoresizingMask];
    [parentView addSubview:_originalView];
    [_originalView setFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height -44)];
    [self setView:parentView];

    // Create navigation bar
    _navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [self.view addSubview:_navigationBar];
    [_navigationBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_navigationBar pushNavigationItem:self.navigationItem animated:NO];
    [_navigationBar release];

    // Create state switching button
    _changeStackStateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_changeStackStateButton setFrame:CGRectMake((_originalView.frame.size.width -88) /2, 0, 88, 44)];
    [_changeStackStateButton addTarget:self action:@selector(changeStackState) forControlEvents:UIControlEventTouchUpInside];
    [_navigationBar addSubview:_changeStackStateButton];
}


- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[_stackNavigationControllers allValues] makeObjectsPerformSelector:@selector(didReceiveMemoryWarning)];
}


#pragma mark -
#pragma mark UDStackController


- (void)changeStackState {
    [_navigationBar addSubview:_changeStackStateButton];
    
    UDStackNavigationController *stackNavigationController = [_stackNavigationControllers objectForKey:_lastActiveStackIdentifier];
    
    if( !stackNavigationController ){
        return;
    }else if( stackNavigationController.view.superview ){
        [self dismissStackNavigationController:stackNavigationController toRect:_lastActiveStackPresentationRect];
    }else{
        [self presentStackNavigationController:stackNavigationController fromRect:_lastActiveStackPresentationRect];
    }
}


- (UDStackNavigationController *)dequeueStackNavigationControllerWithIdentifier:(NSString *)identifier {
    UDStackNavigationController *stackNavigationController = [[_stackNavigationControllers objectForKey:identifier] retain];
    [_stackNavigationControllers removeObjectForKey:identifier];
    
    return [stackNavigationController autorelease];
}


- (void)presentStackNavigationController:(UDStackNavigationController *)viewController fromRect:(CGRect)rect {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    _lastActiveStackIdentifier      = viewController.reuseIdentifier;
    _lastActiveStackPresentationRect= rect;
    
    if( !_stackNavigationControllers ){
        _stackNavigationControllers = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    [_stackNavigationControllers setObject:viewController forKey:viewController.reuseIdentifier];

    // Move state button
    [viewController.navigationBar addSubview:_changeStackStateButton];
    [viewController.navigationBar setBarStyle:_navigationBar.barStyle];
        
    // Create move cache
    UIImageView *imageView = [[UIImageView alloc] initWithImage:viewController.topViewCache];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setFrame:rect];
    [_originalView addSubview:imageView];
    [imageView release];
    
    // Animate transition
    [UIView animateWithDuration:0.33f
                     animations:^{
                         [imageView setFrame:_originalView.bounds];
                     } 
                     completion:^(BOOL finished){
                         [viewController.view setFrame:self.view.bounds];
                         [self.view addSubview:viewController.view];
  
                         [imageView removeFromSuperview];
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                     }];
}


- (void)dismissStackNavigationController:(UDStackNavigationController *)viewController toRect:(CGRect)rect {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    // Create move cache
    UIImageView *imageView = [[UIImageView alloc] initWithImage:viewController.topViewCache];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setFrame:_originalView.bounds];
    [_originalView addSubview:imageView];
    [imageView release];
    
    // Remove active view controller
    [self stackNavigationControllerWill: viewController];
    [viewController.view removeFromSuperview];
    
    // Animate transition
    [UIView animateWithDuration:0.33f
                     animations:^{
                         [imageView  setFrame:rect];
                     } 
                     completion:^(BOOL finished){
                         [imageView removeFromSuperview];
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                     }];
}


- (void)stackNavigationControllerWill:(UDStackNavigationController *)stackNavigationController {
}


@synthesize navigationBar=_navigationBar;
@end
