//
//  UDStackNavigationController.h
//
//  Created by Rolandas Razma on 8/21/11.
//  Copyright (c) 2011 UD7. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UDStackNavigationController : UINavigationController

- (void)presentViewController:(UIViewController *)viewController animated:(BOOL)animated fromRect:(CGRect)fromRect withStackIdentifier:(NSString *)stackIdentifier;
- (BOOL)presentStackWithIdentifier:(NSString *)stackIdentifier animated:(BOOL)animated fromRect:(CGRect)fromRect;
- (NSArray *)viewCacheForStackWithIdentifier:(NSString *)stackIdentifier;
   
@end


@protocol UDStackNavigationControllerDelegate <UINavigationControllerDelegate>
@optional

- (UIImage *)stackNavigationController:(UDStackNavigationController *)stackNavigationController presentationImageForStackWithIdentifier:(NSString *)stackIdentifier;
- (void)stackNavigationController:(UDStackNavigationController *)stackNavigationController willDismissViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end