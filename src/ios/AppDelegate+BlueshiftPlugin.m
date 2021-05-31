//
//  AppDelegate+BlueshiftPlugin.m
//  Blueshift
//
//  Created by Ketan Shikhare on 26/03/21.
//  Copyright Blueshift 2021. All rights reserved.


#import "AppDelegate+BlueshiftPlugin.h"
#import "BlueshiftPlugin.h"
#import <BlueShift_iOS_SDK/BlueShift.h>
#import <objc/runtime.h>

@implementation AppDelegate (BlueshiftPlugin)

+ (void)swizzleHostAppDelegate {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        id uiApplicationDelegate = [UIApplication sharedApplication].delegate;
        
        if ([uiApplicationDelegate respondsToSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)]) {
            SEL registerForNotificationSelector = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
            SEL swizzledRegisterForNotificationSelector = @selector(blueshift_swizzled_application:didRegisterForRemoteNotificationsWithDeviceToken:);
            [self swizzleMethodWithClass:class defaultSelector:registerForNotificationSelector andSwizzledSelector:swizzledRegisterForNotificationSelector];
        } else {
            SEL noregisterForNotificationSelector = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
            SEL swizzledNoregisterForNotificationSelector = @selector(blueshift_swizzled_no_application:didRegisterForRemoteNotificationsWithDeviceToken:);
            [self swizzleMethodWithClass:class defaultSelector:noregisterForNotificationSelector andSwizzledSelector:swizzledNoregisterForNotificationSelector];
        }
        
        if ([uiApplicationDelegate respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
            SEL receivedNotificationSelector = @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:);
            SEL swizzledReceivedNotificationSelector = @selector(blueshift_swizzled_application:didReceiveRemoteNotification:fetchCompletionHandler:);
            [self swizzleMethodWithClass:class defaultSelector:receivedNotificationSelector andSwizzledSelector:swizzledReceivedNotificationSelector];
        } else {
            SEL noReceivedNotificationSelector = @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:);
            SEL swizzledNoReceivedNotificationSelector = @selector(blueshift_swizzled_no_application:didReceiveRemoteNotification:fetchCompletionHandler:);
            [self swizzleMethodWithClass:class defaultSelector:noReceivedNotificationSelector andSwizzledSelector:swizzledNoReceivedNotificationSelector];
        }
        
//        if ([uiApplicationDelegate respondsToSelector:@selector(application:didReceiveRemoteNotification:)]) {
//            SEL receivedNotificationSelector = @selector(application:didReceiveRemoteNotification:);
//            SEL swizzledReceivedNotificationSelector = @selector(blueshift_swizzled_application:didReceiveRemoteNotification:);
//            [self swizzleMethodWithClass:class defaultSelector:receivedNotificationSelector andSwizzledSelector:swizzledReceivedNotificationSelector];
//        } else {
//            SEL noReceivedNotificationSelector = @selector(application:didReceiveRemoteNotification:);
//            SEL swizzledNoReceivedNotificationSelector = @selector(blueshift_swizzled_no_application:didReceiveRemoteNotification:);
//            [self swizzleMethodWithClass:class defaultSelector:noReceivedNotificationSelector andSwizzledSelector:swizzledNoReceivedNotificationSelector];
//        }
        
        if ([uiApplicationDelegate respondsToSelector:@selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:)]) {
            SEL originalSelector = @selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
            SEL swizzledSelector = @selector(blueshift_swizzled_userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
            [self swizzleMethodWithClass:class defaultSelector:originalSelector andSwizzledSelector:swizzledSelector];
        } else {
            SEL originalSelector = @selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
            SEL swizzledSelector = @selector(blueshift_swizzled_no_userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
            [self swizzleMethodWithClass:class defaultSelector:originalSelector andSwizzledSelector:swizzledSelector];
        }

        if ([uiApplicationDelegate respondsToSelector:@selector(userNotificationCenter:willPresentNotification:withCompletionHandler:)]) {
            SEL originalSelector = @selector(userNotificationCenter:willPresentNotification:withCompletionHandler:);
            SEL swizzledSelector = @selector(blueshift_swizzled_userNotificationCenter:willPresentNotification:withCompletionHandler:);
            [self swizzleMethodWithClass:class defaultSelector:originalSelector andSwizzledSelector:swizzledSelector];
        } else {
            SEL originalSelector = @selector(userNotificationCenter:willPresentNotification:withCompletionHandler:);
            SEL swizzledSelector = @selector(blueshift_swizzled_no_userNotificationCenter:willPresentNotification:withCompletionHandler:);
            [self swizzleMethodWithClass:class defaultSelector:originalSelector andSwizzledSelector:swizzledSelector];
        }
                
        if ([uiApplicationDelegate respondsToSelector:@selector(application:openURL:options:)]) {
            SEL originalSelector = @selector(application:openURL:options:);
            SEL swizzledSelector = @selector(blueshift_swizzled_application:openURL:options:);
            [self swizzleMethodWithClass:class defaultSelector:originalSelector andSwizzledSelector:swizzledSelector];
        } else {
            SEL originalSelector = @selector(application:openURL:options:);
            SEL swizzledSelector = @selector(blueshift_swizzled_no_application:openURL:options:);
            [self swizzleMethodWithClass:class defaultSelector:originalSelector andSwizzledSelector:swizzledSelector];
        }
        
        if ([uiApplicationDelegate respondsToSelector:@selector(application:continueUserActivity:restorationHandler:)]) {
            SEL originalSelector = @selector(application:continueUserActivity:restorationHandler:);
            SEL swizzledSelector = @selector(blueshift_swizzled_application:continueUserActivity:restorationHandler:);
            [self swizzleMethodWithClass:class defaultSelector:originalSelector andSwizzledSelector:swizzledSelector];
        } else {
            SEL originalSelector = @selector(application:continueUserActivity:restorationHandler:);
            SEL swizzledSelector = @selector(blueshift_swizzled_no_application:continueUserActivity:restorationHandler:);
            [self swizzleMethodWithClass:class defaultSelector:originalSelector andSwizzledSelector:swizzledSelector];
        }
        
        if ([uiApplicationDelegate respondsToSelector:@selector(applicationWillEnterForeground:)]) {
            SEL originalSelector = @selector(applicationWillEnterForeground:);
            SEL swizzledSelector = @selector(blueshift_swizzled_applicationWillEnterForeground:);
            [self swizzleMethodWithClass:class defaultSelector:originalSelector andSwizzledSelector:swizzledSelector];
        } else {
            SEL originalSelector = @selector(applicationWillEnterForeground:);
            SEL swizzledSelector = @selector(blueshift_swizzled_no_applicationWillEnterForeground:);
            [self swizzleMethodWithClass:class defaultSelector:originalSelector andSwizzledSelector:swizzledSelector];
        }
        
        if ([uiApplicationDelegate respondsToSelector:@selector(applicationDidEnterBackground:)]) {
            SEL originalSelector = @selector(applicationDidEnterBackground:);
            SEL swizzledSelector = @selector(blueshift_swizzled_applicationDidEnterBackground:);
            [self swizzleMethodWithClass:class defaultSelector:originalSelector andSwizzledSelector:swizzledSelector];
        } else {
            SEL originalSelector = @selector(applicationDidEnterBackground:);
            SEL swizzledSelector = @selector(blueshift_swizzled_no_applicationDidEnterBackground:);
            [self swizzleMethodWithClass:class defaultSelector:originalSelector andSwizzledSelector:swizzledSelector];
        }
    });
}

+ (void)swizzleMethodWithClass:(Class)class defaultSelector:(SEL)defaultSelector andSwizzledSelector:(SEL)swizzledSelector {
    Method defaultMethod = class_getInstanceMethod(class, defaultSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL isSuccess = class_addMethod(class, defaultSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (isSuccess) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(defaultMethod), method_getTypeEncoding(defaultMethod));
    } else {
        method_exchangeImplementations(defaultMethod, swizzledMethod);
    }
}

- (void)blueshift_swizzled_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [self blueshift_swizzled_application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    
    [[BlueShift sharedInstance].appDelegate registerForRemoteNotification:deviceToken];
}

- (void)blueshift_swizzled_no_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[BlueShift sharedInstance].appDelegate registerForRemoteNotification:deviceToken];
}

- (void)blueshift_swizzled_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [self blueshift_swizzled_application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];

    [[BlueShift sharedInstance].appDelegate application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:^(UIBackgroundFetchResult result) {}];
}

- (void)blueshift_swizzled_no_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[BlueShift sharedInstance].appDelegate application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}

//- (void)blueshift_swizzled_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    [self blueshift_swizzled_application:application didReceiveRemoteNotification:userInfo];
//        [[BlueShift sharedInstance].appDelegate application:application didReceiveRemoteNotification:userInfo];
//}
//
//- (void)blueshift_swizzled_no_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    [[BlueShift sharedInstance].appDelegate application:application didReceiveRemoteNotification:userInfo];
//}

- (void)blueshift_swizzled_userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    [self blueshift_swizzled_userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
    // We pass a nil completion handler to the SDK since the host delegate might be calling the completion handler instead
    [[BlueShift sharedInstance].userNotificationDelegate userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:^{}];
}

- (void)blueshift_swizzled_no_userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    [[BlueShift sharedInstance].userNotificationDelegate userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
}

- (void)blueshift_swizzled_userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    [self blueshift_swizzled_userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
    // We pass a nil completion handler to the SDK since the host delegate might be calling the completion handler instead
    [[BlueShift sharedInstance].userNotificationDelegate userNotificationCenter:center willPresentNotification:notification withCompletionHandler:^(UNNotificationPresentationOptions options) {}];
}

- (void)blueshift_swizzled_no_userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    [[BlueShift sharedInstance].userNotificationDelegate userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
}

//- (void)blueshift_swizzled_application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation {
//    [[NSNotificationCenter defaultCenter] postNotificationName:BLUESHIFT_HANDLE_DEEPLINK_NOTIFICATION object:url userInfo:nil];
//}
//
//- (void)blueshift_swizzled_no_application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation {
//    [[NSNotificationCenter defaultCenter] postNotificationName:BLUESHIFT_HANDLE_DEEPLINK_NOTIFICATION object:url userInfo:nil];
//}

- (void)blueshift_swizzled_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
    NSURL *openedURL = [url copy];
    NSDictionary *openedOptions = [options copy];
    [self blueshift_swizzled_application:app openURL:url options:options];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BLUESHIFT_HANDLE_DEEPLINK_NOTIFICATION object:openedURL userInfo:openedOptions];
}

- (void)blueshift_swizzled_no_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
    [[NSNotificationCenter defaultCenter] postNotificationName:BLUESHIFT_HANDLE_DEEPLINK_NOTIFICATION object:url userInfo:options];
}

- (void)blueshift_swizzled_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    NSURL *url = [userActivity.webpageURL copy];
    [self blueshift_swizzled_application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
    
    [[BlueShift sharedInstance].appDelegate handleBlueshiftUniversalLinksForURL:url];
}

- (void)blueshift_swizzled_no_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    [[BlueShift sharedInstance].appDelegate handleBlueshiftUniversalLinksForURL:userActivity.webpageURL];
}

- (void)blueshift_swizzled_applicationWillEnterForeground:(UIApplication *)application {
    [self blueshift_swizzled_applicationWillEnterForeground:application];
    
    [[BlueShift sharedInstance].appDelegate appDidBecomeActive:application];
}

- (void)blueshift_swizzled_no_applicationWillEnterForeground:(UIApplication *)application {
    [[BlueShift sharedInstance].appDelegate appDidBecomeActive:application];
}

- (void)blueshift_swizzled_applicationDidEnterBackground:(UIApplication *)application {
    [self blueshift_swizzled_applicationDidEnterBackground:application];
    
    [[BlueShift sharedInstance].appDelegate appDidEnterBackground:application];
}

- (void)blueshift_swizzled_no_applicationDidEnterBackground:(UIApplication *)application {
    [[BlueShift sharedInstance].appDelegate appDidEnterBackground:application];
}

@end
