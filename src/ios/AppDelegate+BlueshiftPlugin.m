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

@import UserNotifications;

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
        
        if ([uiApplicationDelegate respondsToSelector:@selector(application:didReceiveRemoteNotification:)]) {
            SEL receivedNotificationSelector = @selector(application:didReceiveRemoteNotification:);
            SEL swizzledReceivedNotificationSelector = @selector(blueshift_swizzled_application:didReceiveRemoteNotification:);
            [self swizzleMethodWithClass:class defaultSelector:receivedNotificationSelector andSwizzledSelector:swizzledReceivedNotificationSelector];
        } else {
            SEL noReceivedNotificationSelector = @selector(application:didReceiveRemoteNotification:);
            SEL swizzledNoReceivedNotificationSelector = @selector(blueshift_swizzled_no_application:didReceiveRemoteNotification:);
            [self swizzleMethodWithClass:class defaultSelector:noReceivedNotificationSelector andSwizzledSelector:swizzledNoReceivedNotificationSelector];
        }
        
        if ([uiApplicationDelegate respondsToSelector:@selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:)]) {
            SEL receivedNotificationResponseSelector = @selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
            SEL swizzledReceivedNotificationResponseSelector = @selector(blueshift_swizzled_userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
            [self swizzleMethodWithClass:class defaultSelector:receivedNotificationResponseSelector andSwizzledSelector:swizzledReceivedNotificationResponseSelector];
        } else {
            SEL noReceivedNotificationResponseSelector = @selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
            SEL swizzledNoReceivedNotificationResponseSelector = @selector(blueshift_swizzled_no_userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
            [self swizzleMethodWithClass:class defaultSelector:noReceivedNotificationResponseSelector andSwizzledSelector:swizzledNoReceivedNotificationResponseSelector];
        }
//
//        if ([uiApplicationDelegate respondsToSelector:@selector(userNotificationCenter:willPresentNotification:withCompletionHandler:)]) {
//            SEL receivedNotificationResponseSelector = @selector(userNotificationCenter:willPresentNotification:withCompletionHandler:);
//            SEL swizzledReceivedNotificationResponseSelector = @selector(blueshift_swizzled_userNotificationCenter:willPresentNotification:withCompletionHandler:);
//            [self swizzleMethodWithClass:class defaultSelector:receivedNotificationResponseSelector andSwizzledSelector:swizzledReceivedNotificationResponseSelector];
//        } else {
//            SEL noReceivedNotificationResponseSelector = @selector(userNotificationCenter:willPresentNotification:withCompletionHandler:);
//            SEL swizzledNoReceivedNotificationResponseSelector = @selector(blueshift_swizzled_no_userNotificationCenter:willPresentNotification:withCompletionHandler:);
//            [self swizzleMethodWithClass:class defaultSelector:noReceivedNotificationResponseSelector andSwizzledSelector:swizzledNoReceivedNotificationResponseSelector];
//        }
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
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
        [self blueshift_swizzled_application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    }
    [[BlueShift sharedInstance].appDelegate application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:^(UIBackgroundFetchResult result) {}];
}

- (void)blueshift_swizzled_no_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[BlueShift sharedInstance].appDelegate application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}

- (void)blueshift_swizzled_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self blueshift_swizzled_application:application didReceiveRemoteNotification:userInfo];
    [[BlueShift sharedInstance].appDelegate application:application didReceiveRemoteNotification:userInfo];
}

- (void)blueshift_swizzled_no_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[BlueShift sharedInstance].appDelegate application:application didReceiveRemoteNotification:userInfo];
}

- (void)blueshift_swizzled_userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    [self blueshift_swizzled_userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
    // We pass a nil completion handler to the SDK since the host delegate might be calling the completion handler instead
    [[BlueShift sharedInstance].userNotificationDelegate userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:^{}];
}

- (void)blueshift_swizzled_no_userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    [[BlueShift sharedInstance].userNotificationDelegate userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:^{}];
}

//- (void)blueshift_swizzled_userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
//    [self blueshift_swizzled_userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
//    // We pass a nil completion handler to the SDK since the host delegate might be calling the completion handler instead
//    [[BlueShift sharedInstance].userNotificationDelegate userNotificationCenter:center willPresentNotification:notification withCompletionHandler:^(UNNotificationPresentationOptions options) {}];
//}
//
//- (void)blueshift_swizzled_no_userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
//    [[BlueShift sharedInstance].userNotificationDelegate userNotificationCenter:center willPresentNotification:notification withCompletionHandler:^(UNNotificationPresentationOptions options) {}];
//}
//
//- (void)blueshift_swizzled_application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation {
//    [[NSNotificationCenter defaultCenter] postNotificationName:BLUESHIFT_HANDLE_DEEPLINK_NOTIFICATION object:url userInfo:nil];
//}
//
//- (void)blueshift_swizzled_no_application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation {
//    [[NSNotificationCenter defaultCenter] postNotificationName:BLUESHIFT_HANDLE_DEEPLINK_NOTIFICATION object:url userInfo:nil];
//}
//
//- (void)blueshift_swizzled_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
//    [[NSNotificationCenter defaultCenter] postNotificationName:BLUESHIFT_HANDLE_DEEPLINK_NOTIFICATION object:url userInfo:options];
//}
//
//- (void)blueshift_swizzled_no_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
//    [[NSNotificationCenter defaultCenter] postNotificationName:BLUESHIFT_HANDLE_DEEPLINK_NOTIFICATION object:url userInfo:options];
//}
//
//- (void)blueshift_swizzled_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
//    [[BlueShift sharedInstance].appDelegate handleBlueshiftUniversalLinksForURL:userActivity.webpageURL];
//}
//
//- (void)blueshift_swizzled_no_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
//    [[BlueShift sharedInstance].appDelegate handleBlueshiftUniversalLinksForURL:userActivity.webpageURL];
//}
//
//- (void)blueshift_swizzled_applicationWillEnterForeground:(UIApplication *)application {
//    [[BlueShift sharedInstance].appDelegate appDidBecomeActive:application];
//}
//
//- (void)blueshift_swizzled_no_applicationWillEnterForeground:(UIApplication *)application {
//    [[BlueShift sharedInstance].appDelegate appDidBecomeActive:application];
//}
//
//- (void)blueshift_swizzled_applicationDidEnterBackground:(UIApplication *)application {
//    [[BlueShift sharedInstance].appDelegate appDidEnterBackground:application];
//}
//
//- (void)blueshift_swizzled_no_applicationDidEnterBackground:(UIApplication *)application {
//    [[BlueShift sharedInstance].appDelegate appDidEnterBackground:application];
//}
//

//#pragma mark: Open URL delegate methods
//- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation {
//    [[NSNotificationCenter defaultCenter] postNotificationName:BLUESHIFT_HANDLE_DEEPLINK_NOTIFICATION object:url userInfo:nil];
//    if (!url) {
//        return NO;
//    }
//    return YES;
//}

//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
//    [[NSNotificationCenter defaultCenter] postNotificationName:BLUESHIFT_HANDLE_DEEPLINK_NOTIFICATION object:url userInfo:options];
//    if (!url) {
//        return NO;
//    }
//    return YES;
//}

//-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
//    NSURL *url = userActivity.webpageURL;
//    if (url) {
//        [[BlueShift sharedInstance].appDelegate handleBlueshiftUniversalLinksForURL:url];
//    }
//    return YES;
//}

//#pragma mark: Application Life cycle methods
//- (void)applicationWillEnterForeground:(UIApplication *)application {
//    [[BlueShift sharedInstance].appDelegate appDidBecomeActive:application];
//}
//
//- (void)applicationDidEnterBackground:(UIApplication *)application {
//    [[BlueShift sharedInstance].appDelegate appDidEnterBackground:application];
//}
@end
