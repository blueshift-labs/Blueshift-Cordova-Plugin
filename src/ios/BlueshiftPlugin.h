//
//  Blueshift.h
//  Blueshift
//
//  Created by Ketan Shikhare on 15/03/21.
//  Copyright Blueshift 2021. All rights reserved.

#import <BlueShift_iOS_SDK/BlueShift.h>

@interface BlueshiftPlugin : CDVPlugin <BlueshiftUniversalLinksDelegate>

// In App notifications
- (void)registerForInAppMessages:(CDVInvokedUrlCommand*)command;
- (void)unregisterForInAppMessages:(CDVInvokedUrlCommand*)command;
- (void)fetchInAppMessages:(CDVInvokedUrlCommand*)command;
- (void)displayInAppMessages:(CDVInvokedUrlCommand*)command;

// Tracking events
- (void)trackCustomEvent:(CDVInvokedUrlCommand*)command;
- (void)identify:(CDVInvokedUrlCommand*)command;

// Set UserInfo
- (void)setUserInfoEmailID:(CDVInvokedUrlCommand*)command;
- (void)setUserInfoCustomerID:(CDVInvokedUrlCommand*)command;
- (void)setUserInfoFirstName:(CDVInvokedUrlCommand*)command;
- (void)setUserInfoLastName:(CDVInvokedUrlCommand*)command;
- (void)setUserInfoExtras:(CDVInvokedUrlCommand*)command;
- (void)removeUserInfo:(CDVInvokedUrlCommand*)command;

// Manage SDK features
- (void)enableTracking:(CDVInvokedUrlCommand*)command;
- (void)enablePush:(CDVInvokedUrlCommand*)command;
- (void)enableInApp:(CDVInvokedUrlCommand*)command;

// Live content
- (void)getLiveContentByEmail:(CDVInvokedUrlCommand*)command;
- (void)getLiveContentByCustomerID:(CDVInvokedUrlCommand*)command;
- (void)getLiveContentByDeviceID:(CDVInvokedUrlCommand*)command;

// Remote notification & Location
- (void)registerForRemoteNotification:(CDVInvokedUrlCommand*)command;
- (void)setCurrentLocation:(CDVInvokedUrlCommand*)command;

// Getter methods
- (void)getEnableInAppStatus:(CDVInvokedUrlCommand*)command;
- (void)getEnablePushStatus:(CDVInvokedUrlCommand*)command;
- (void)getEnableTrackingStatus:(CDVInvokedUrlCommand*)command;
- (void)getUserInfoEmailID:(CDVInvokedUrlCommand*)command;
- (void)getUserInfoCustomerID:(CDVInvokedUrlCommand*)command;
- (void)getUserInfoFirstname:(CDVInvokedUrlCommand*)command;
- (void)getUserInfoLastname:(CDVInvokedUrlCommand*)command;
- (void)getUserInfoExtras:(CDVInvokedUrlCommand*)command;
- (void)getCurrentDeviceId:(CDVInvokedUrlCommand*)command;
@end
