//
//  UDStackNavigationController.h
//
//  Created by Rolandas Razma on 8/21/11.
//  Copyright (c) 2011 UD7. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UDStackNavigationController : UINavigationController

@property (nonatomic, readonly) NSString *reuseIdentifier;
@property (nonatomic, readonly) NSArray  *viewControllersViewCache;
@property (nonatomic, readonly) UIImage  *topViewCache;

- (id)initWithRootViewController:(UIViewController *)rootViewController reuseIdentifier:(NSString *)reuseIdentifier;

@end
