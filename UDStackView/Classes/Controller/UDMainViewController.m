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
    [logoView setContentMode:UIViewContentModeScaleAspectFit];
    [logoView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight)];
    [self.navigationItem setTitleView:logoView];

    UIImageView *triangleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"triangle.png"]] autorelease];
    [triangleView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [triangleView setFrame:CGRectMake((logoView.frame.size.width -triangleView.frame.size.width) /2, 43, triangleView.frame.size.width, triangleView.frame.size.height)];
    [logoView addSubview:triangleView];
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
}


- (void)didReceiveMemoryWarning {
    // we dont want view to unload so don't call supper
}


#pragma mark -
#pragma mark UDMainViewController


- (IBAction)presentStackViewFromButton:(UIButton *)button {
    _activeStackButton = button;
    
    // Im using single button, so im generating reuseIdentifier for each button
    NSString *reusableIdentifier = [_activeStackButton description];
    
    if( ![(UDStackNavigationController *)self.navigationController presentStackWithIdentifier:reusableIdentifier animated:YES fromRect:button.frame] ){
        UDColoredViewController *coloredViewController = [[[UDColoredViewController alloc] initWithColor:[UIColor yellowColor]] autorelease];
        [(UDStackNavigationController *)self.navigationController presentViewController: coloredViewController
                                                                               animated: YES 
                                                                               fromRect: button.frame
                                                                    withStackIdentifier: reusableIdentifier];
    }
    
}


#pragma mark -
#pragma mark UDStackViewControllerDelegate


- (void)stackNavigationController:(UDStackNavigationController *)stackNavigationController willDismissViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if( _activeStackButton.subviews.count ){
        [_activeStackButton.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    CGFloat angle = 0.09f;
    NSUInteger stackCount = 0;

    NSArray *stackViewCache = [stackNavigationController viewCacheForStackWithIdentifier:[_activeStackButton description]];
    
    for ( UIImage *image in stackViewCache ) {
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
        [imageView setFrame:_activeStackButton.bounds];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_activeStackButton addSubview:imageView];
        
        stackCount++;
        if( stackCount < stackViewCache.count ){
            [imageView setTransform: CGAffineTransformRotate(CGAffineTransformIdentity, angle *(stackCount%2?-1:1))];
        }
    }
    
}


- (UIImage *)stackNavigationController:(UDStackNavigationController *)stackNavigationController presentationImageForStackWithIdentifier:(NSString *)stackIdentifier {
    UIImage *presentationImage = [[stackNavigationController viewCacheForStackWithIdentifier:stackIdentifier] lastObject];
    return (presentationImage?presentationImage:[_activeStackButton imageForState:UIControlStateNormal]);
}


@end
