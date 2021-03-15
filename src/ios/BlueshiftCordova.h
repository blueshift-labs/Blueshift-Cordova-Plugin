//
//  Blueshift.h
//  Blueshift
//
//  Created by Ketan Shikhare on 15/03/21.
//  Copyright Blueshift 2021. All rights reserved.

@interface BlueshiftCordova : CDVPlugin

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
- (void)setUserInfoFirstname:(CDVInvokedUrlCommand*)command;
- (void)setUserInfoLastname:(CDVInvokedUrlCommand*)command;
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

@end
