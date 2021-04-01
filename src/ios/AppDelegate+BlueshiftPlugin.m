//
//  AppDelegate+BlueshiftPlugin.m
//  Blueshift
//
//  Created by Ketan Shikhare on 26/03/21.
//  Copyright Blueshift 2021. All rights reserved.


#import "AppDelegate+BlueshiftPlugin.h"
#import "BlueshiftPlugin.h"
#import <BlueShift_iOS_SDK/BlueShift.h>

@implementation AppDelegate (BlueshiftPlugin)

#pragma mark: Remote notification registration
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    [[BlueShift sharedInstance].appDelegate registerForRemoteNotification:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    [[BlueShift sharedInstance].appDelegate failedToRegisterForRemoteNotificationWithError:error];
}

#pragma mark: Remote notification delegate methods
- (void) application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification {
    [[BlueShift sharedInstance].appDelegate application:application handleRemoteNotification:notification.userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[BlueShift sharedInstance].appDelegate application:application handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[BlueShift sharedInstance].appDelegate handleRemoteNotification:userInfo forApplication:application fetchCompletionHandler:completionHandler];
}

#pragma mark: Open URL delegate methods
- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation {
    if (!url) {
        return NO;
    }
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
    [self showAlertForURL:url andTitle:@"Deep link 2"];
    if (!url) {
        return NO;
    }
    return YES;
}

-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    NSURL *url = userActivity.webpageURL;
    if (url && [[BlueShift sharedInstance] isBlueshiftUniversalLinkURL:url]) {
        [[BlueShift sharedInstance].appDelegate handleBlueshiftUniversalLinksForURL:url];
    }
    return YES;
}

- (void)openURL:(NSURL*)url options:(NSDictionary<NSString *, id> *)options completionHandler:(void (^ __nullable)(BOOL success))completion {
    [self showAlertForURL:url andTitle:@"Deep link"];
}

- (void)showAlertForURL:(NSURL*)url andTitle:(NSString*)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:url.absoluteString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancel];
    UIViewController *rootviewController = [[[UIApplication sharedApplication] delegate] window].rootViewController;
    [rootviewController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark: Application Life cycle methods
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[BlueShift sharedInstance].appDelegate appDidBecomeActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[BlueShift sharedInstance].appDelegate appDidEnterBackground:application];
}
@end
