//
//  UDStackController.h
//
//  Created by Rolandas Razma on 8/21/11.
//  Copyright (c) 2011 UD7. All rights reserved.
//

#import <UIKit/UIKit.h>


@class UDStackNavigationController;


@interface UDStackViewController : UIViewController

@property(nonatomic, readonly) UINavigationBar *navigationBar;

- (UDStackNavigationController *)dequeueStackNavigationControllerWithIdentifier:(NSString *)identifier;
- (void)presentStackNavigationController:(UDStackNavigationController *)viewController fromRect:(CGRect)rect;
- (void)stackNavigationControllerWill:(UDStackNavigationController *)stackNavigationController;
   
@end
