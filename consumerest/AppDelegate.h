//
//  AppDelegate.h
//  consumerest
//
//  Created by Damiano Fusco on 5/18/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    //NSString *_cookie;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *cookie;

+(AppDelegate*)instance;
+(NSString*)cookie;
+(void)setCookie:(NSString*)ck;

@end
