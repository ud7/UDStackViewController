//
//  UDMainViewController.m
//  UDStackView
//
//  Created by Rolandas Razma on 8/21/11.
//  Copyright (c) 2011 UD7. All rights reserved.
//

#import "UDMainViewController.h"
#import "UDColoredViewController.h"


@implementation UDMainViewController {
    UIButton *_activeStackButton;
}


#pragma mark -
#pragma mark UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    UIImageView *logoView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ud7logo.png"]] autorelease];
    [self.navigationItem setTitleView:logoView];

    UIImageView *triangleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"triangle.png"]] autorelease];
    [triangleView setFrame:CGRectMake((logoView.frame.size.width -triangleView.frame.size.width) /2, 43, triangleView.frame.size.width, triangleView.frame.size.height)];
    [logoView addSubview:triangleView];
    
    [self.navigationBar setBarStyle:UIBarStyleBlack];
}


#pragma mark -
#pragma mark UDMainViewController


- (IBAction)presentStackViewFromButton:(UIButton *)button {
    _activeStackButton = button;
    
    // Im using single button, so im generating reuseIdentifier for each button
    NSString *reuseIdentifier = [button description];
    
    
    UDStackNavigationController *stackNavigationController;
    if( !(stackNavigationController = [self dequeueStackNavigationControllerWithIdentifier:reuseIdentifier]) ){
        UDColoredViewController *coloredViewController = [[[UDColoredViewController alloc] init] autorelease];
        stackNavigationController = [[[UDStackNavigationController alloc] initWithRootViewController:coloredViewController reuseIdentifier:reuseIdentifier] autorelease];
    }
    
    
    [self presentStackNavigationController: stackNavigationController
                                  fromRect: button.frame];
}


#pragma mark -
#pragma mark UDStackViewController


- (void)stackNavigationControllerWill:(UDStackNavigationController *)stackNavigationController {
    [_activeStackButton.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
     
    CGFloat angle = 0.09f;
    NSUInteger stackCount = 0;

    for ( UIImage *image in stackNavigationController.viewControllersViewCache ) {
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
        [imageView setFrame:_activeStackButton.bounds];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_activeStackButton addSubview:imageView];
        
        stackCount++;
        if( stackCount < stackNavigationController.viewControllersViewCache.count ){
            [imageView setTransform: CGAffineTransformRotate(CGAffineTransformIdentity, angle *(stackCount%2?-1:1))];
        }
    }
    
}


@end
