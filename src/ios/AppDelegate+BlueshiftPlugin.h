//
//  AppDelegate+BlueshiftPlugin.h
//  Blueshift
//
//  Created by Ketan Shikhare on 26/03/21.
//  Copyright Blueshift 2021. All rights reserved.

#import "AppDelegate.h"

@interface AppDelegate (BlueshiftPlugin)

+ (void)swizzleHostAppDelegate;

@end
