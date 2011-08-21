//
//  UDColoredViewController.m
//  UDStackView
//
//  Created by Rolandas Razma on 8/21/11.
//  Copyright (c) 2011 UD7. All rights reserved.
//

#import "UDColoredViewController.h"


@implementation UDColoredViewController {
    IBOutlet UIButton *_countingButton;
    UIColor     *_color;
    NSInteger   _count;
}


#pragma mark -
#pragma mark NSObject


- (void)dealloc {
    [_color release];
    [_countingButton release];
    [super dealloc];
}


#pragma mark -
#pragma mark UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Generate random color if controller was initializet without color
    if( !_color ){
        _color = [[UIColor colorWithRed: (CGFloat)random()/(CGFloat)RAND_MAX
                                  green: (CGFloat)random()/(CGFloat)RAND_MAX
                                   blue: (CGFloat)random()/(CGFloat)RAND_MAX
                                  alpha: 1.0f] retain];
    }
    [self.view setBackgroundColor:_color];
    
    // Setup view
    [self setTitle:[NSString stringWithFormat:@"%u", self.navigationController.viewControllers.count]];
    [_countingButton setTitle:[NSString stringWithFormat:@"%u", _count] forState:UIControlStateNormal];
    
    // This only for testing purposes only
    // Using this 'if' only because im using same viewController over and over again
    if( self.navigationController.viewControllers.count == 1 ){
        UIImageView *logoView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ud7logo.png"]] autorelease];
        [self.navigationItem setTitleView:logoView];
        
        UIImageView *triangleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"triangle.png"]] autorelease];
        [triangleView setFrame:CGRectMake((logoView.frame.size.width -triangleView.frame.size.width) /2, 43, triangleView.frame.size.width, triangleView.frame.size.height)];
        [logoView addSubview:triangleView];
    }
    
    // Some random barButton
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:self.navigationController.viewControllers.count +1 target:nil action:nil];
    [self.navigationItem setRightBarButtonItem:barButtonItem];
    [barButtonItem release];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    [_countingButton release], _countingButton = nil;
}


#pragma mark -
#pragma mark UDColoredViewController


- (id)initWithColor:(UIColor *)color {
    if( (self = [self init]) ){
        _color = [color copy];
    }
    return self;
}


- (IBAction)nextColor {
    UDColoredViewController *coloredViewController = [[UDColoredViewController alloc] init];
    [self.navigationController pushViewController:coloredViewController animated:YES];
    [coloredViewController release];
}


- (IBAction)increaseCount {
    [_countingButton setTitle:[NSString stringWithFormat:@"%u", ++_count] forState:UIControlStateNormal];
}


@end
