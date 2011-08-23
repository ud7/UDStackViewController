//
//  UDStackNavigationController.m
//
//  Created by Rolandas Razma on 8/21/11.
//  Copyright (c) 2011 UD7. All rights reserved.
//

#import "UDStackNavigationController.h"
#import <QuartzCore/QuartzCore.h>


@interface UDStackNavigationController (UDPrivate)

- (void)changeStackState;
- (NSMutableArray *)activeStackViewCache;
- (void)updateActiveStackViewCache;

@end


@implementation UDStackNavigationController {
    NSMutableDictionary *_stacks;
    NSString            *_activeStackIdentifyer;
    CGRect              _activeStackPresentationRect;
    NSMutableDictionary *_stacksViewCache;
}


#pragma mark -
#pragma mark NSObject


- (void)dealloc {
    [_stacks release];
    [_activeStackIdentifyer release];
    [_stacksViewCache release];
    [super dealloc];
}


#pragma mark -
#pragma mark UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create state switching button
    UIButton *stackStateChangingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [stackStateChangingButton setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin)];
    [stackStateChangingButton setFrame:CGRectMake((self.navigationBar.frame.size.width -88) /2, 0, 88, self.navigationBar.frame.size.height)];
    [stackStateChangingButton addTarget:self action:@selector(changeStackState) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:stackStateChangingButton];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Leave only recent 3
    for ( NSMutableArray *stackViewCache in [_stacksViewCache allValues] ) {
        if( stackViewCache.count > 3 ){
            [stackViewCache removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, stackViewCache.count -3)]];
        }
    }
}


#pragma mark -
#pragma mark UINavigationController


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSAssert(!(self.viewControllers.count == 1 && animated), @"dont use -[UDStackNavigationController pushViewController:animated:YES] on first controller in stack. Use -[UDStackNavigationController presentViewController:fromRect:withIdentifier:]");
    
    if( !_stacksViewCache ) {
        _stacksViewCache = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    
    // Grab look of old view
    [self updateActiveStackViewCache];
    
    [super pushViewController:viewController animated:animated];
}


- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    NSMutableArray *viewCache = [self activeStackViewCache];
    if( viewCache.count ){
        [viewCache removeLastObject];
    }
    return [super popViewControllerAnimated:animated];
}


- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    NSAssert(!(self.viewControllers.count == 1), @"Already at root");
    
    [_stacks setObject:self.viewControllers forKey:_activeStackIdentifyer];
    
    if( animated ){
        [self updateActiveStackViewCache];
                
        if( [self.delegate respondsToSelector:@selector(stackNavigationController:willDismissViewController:animated:)] ){
            [(id<UDStackNavigationControllerDelegate>)self.delegate stackNavigationController:self willDismissViewController:self.topViewController animated:YES];
        }

        [self setViewControllers:[NSArray arrayWithObject:[self.viewControllers objectAtIndex:0]] animated:NO];

        // Create move cache
        UIImageView *imageView = [[UIImageView alloc] initWithImage: [self.activeStackViewCache lastObject]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imageView setFrame:self.topViewController.view.bounds];
        [self.topViewController.view addSubview:imageView];
        [imageView release];
        
        // Animate transition
        [UIView animateWithDuration: 0.33f
                         animations: ^{
                             [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                             [imageView setFrame:_activeStackPresentationRect];
                         } 
                         completion: ^(BOOL finished){
                             // Remove Cache View
                             [imageView removeFromSuperview];
                             
                             [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                         }];
        
    }else{
        [self setViewControllers:[NSArray arrayWithObject:[self.viewControllers objectAtIndex:0]] animated:NO];
        
        if( [self.delegate respondsToSelector:@selector(stackNavigationController:willDismissViewController:animated:)] ){
            [(id<UDStackNavigationControllerDelegate>)self.delegate stackNavigationController:self willDismissViewController:self.topViewController animated:NO];
        }
    }
    
    return self.viewControllers;
}


#pragma mark -
#pragma mark UDStackNavigationController


- (NSMutableArray *)activeStackViewCache {
    return [_stacksViewCache objectForKey:_activeStackIdentifyer];
}


- (void)updateActiveStackViewCache {

    if( self.viewControllers.count > 1 ){
        NSMutableArray *activeStackViewCache = self.activeStackViewCache;
        if( !activeStackViewCache ){
            activeStackViewCache = [NSMutableArray arrayWithCapacity:4];
            [_stacksViewCache setObject:activeStackViewCache forKey:_activeStackIdentifyer];
        }
        
        UIGraphicsBeginImageContext(self.topViewController.view.frame.size);
        [self.topViewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        if( activeStackViewCache.count < self.viewControllers.count -1 ){
            [activeStackViewCache addObject:UIGraphicsGetImageFromCurrentImageContext()];        
        }else{
            [activeStackViewCache replaceObjectAtIndex:self.viewControllers.count -2 withObject:UIGraphicsGetImageFromCurrentImageContext()];
        }
        UIGraphicsEndImageContext();
    }

}


- (NSArray *)viewCacheForStackWithIdentifier:(NSString *)stackIdentifier {
    return [_stacksViewCache objectForKey:stackIdentifier];
}


- (void)changeStackState {
    if( self.viewControllers.count == 1 ){
        if( _activeStackIdentifyer ){
            [self presentStackWithIdentifier: _activeStackIdentifyer
                                    animated: YES
                                    fromRect: _activeStackPresentationRect];
        }
    }else{
        // more than root
        [self popToRootViewControllerAnimated:YES];
    }
}


- (void)presentViewController:(UIViewController *)viewController animated:(BOOL)animated fromRect:(CGRect)fromRect withStackIdentifier:(NSString *)stackIdentifier {
    [_activeStackIdentifyer release];
    _activeStackIdentifyer = [stackIdentifier copy];
    _activeStackPresentationRect = fromRect;
    
    if( !animated ) {
        [self pushViewController:viewController animated:NO];
        return;
    }
    
    NSAssert(!(self.viewControllers.count > 1), @"-[UDStackNavigationController presentViewController:fromRect:withIdentifier:] can be used only from rootViewController. Use -[UDStackNavigationController pushViewController:animated:YES] instead");
    
    if( !_stacks ) _stacks = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    // Create move cache
    UIImage *presentationImage = [[self activeStackViewCache] lastObject];
    if( !presentationImage && [self.delegate respondsToSelector:@selector(stackNavigationController:presentationImageForStackWithIdentifier:)] ){
        presentationImage = [(id<UDStackNavigationControllerDelegate>)self.delegate stackNavigationController:self presentationImageForStackWithIdentifier:_activeStackIdentifyer];
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:presentationImage];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setFrame:_activeStackPresentationRect];
    [self.topViewController.view addSubview:imageView];
    [imageView release];

    // Animate transition
    [UIView animateWithDuration: 0.33f
                     animations: ^{
                         [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                         [imageView setFrame:self.topViewController.view.bounds];
                     } 
                     completion: ^(BOOL finished){
                         [self pushViewController:viewController animated:NO];
                         [_stacks setObject:self.viewControllers forKey:_activeStackIdentifyer];
                         
                         // Remove Cache View
                         [imageView removeFromSuperview];
                         
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                     }];

}


- (BOOL)presentStackWithIdentifier:(NSString *)stackIdentifier animated:(BOOL)animated fromRect:(CGRect)fromRect {
    NSArray *stack = [_stacks objectForKey:stackIdentifier];

    if( !stack ) return NO;

    [_activeStackIdentifyer release];
    _activeStackIdentifyer = [stackIdentifier copy];
    _activeStackPresentationRect = fromRect;
    
    if( !animated ){
        [self setViewControllers:stack animated:NO];
    }
    
    // Create move cache
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [[self activeStackViewCache] lastObject]];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setFrame:fromRect];
    [self.topViewController.view addSubview:imageView];
    [imageView release];
    
    // Animate transition
    [UIView animateWithDuration: 0.33f
                     animations: ^{
                         [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                         [imageView setFrame:self.topViewController.view.bounds];
                     } 
                     completion: ^(BOOL finished){
                         [self setViewControllers:stack animated:NO];
                         
                         // Remove Cache View
                         [imageView removeFromSuperview];
                         
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                     }];
    

    return YES;
}


@end
