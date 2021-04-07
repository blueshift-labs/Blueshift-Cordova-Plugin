//
//  Blueshift.m
//  Blueshift
//
//  Created by Ketan Shikhare on 15/03/21.
//  Copyright Blueshift 2021. All rights reserved.

#define BLUESHIFT_PREF_API_KEY @"com.blueshift.config.event_api_key"
#define BLUESHIFT_PREF_PUSH_ENABLED @"com.blueshift.config.push_enabled"
#define BLUESHIFT_PREF_IN_APP_ENABLED @"com.blueshift.config.in_app_enabled"
#define BLUESHIFT_PREF_IN_APP_INTERVAL @"com.blueshift.config.in_app_interval_seconds"
#define BLUESHIFT_PREF_IN_APP_BACKGROUND_FETCH_ENABLED @"com.blueshift.config.in_app_background_fetch_enabled"
#define BLUESHIFT_PREF_IN_APP_MANUAL_MODE_ENABLED @"com.blueshift.config.in_app_manual_mode_enabled"
#define BLUESHIFT_PREF_DEVICE_ID_SOURCE @"com.blueshift.config.device_id_source"
#define BLUESHIFT_PREF_DEVICE_ID_CUSTOM_VALUE @"com.blueshift.config.device_id_custom_value"
#define BLUESHIFT_PREF_BATCH_INTERVAL_SECONDS @"com.blueshift.config.batch_interval_seconds"
#define BLUESHIFT_PREF_AUTO_APP_OPEN_ENABLED @"com.blueshift.config.auto_app_open_enabled"
#define BLUESHIFT_PREF_AUTO_APP_OPEN_INTERVAL_SECONDS @"com.blueshift.config.auto_app_open_interval_seconds"

#define BLUESHIFT_PREF_DEBUG_ENABLED @"com.blueshift.config.debug_enabled"
#define BLUESHIFT_PREF_SCENE_DELEGATE_ENABLED @"com.blueshift.config.scene_delegate_enabled"
#define BLUESHIFT_PREF_APP_GROUP_ID @"com.blueshift.config.app_group_id"
#define BLUESHIFT_PREF_IDFA_COLLECTION_ENABLED @"com.blueshift.config.idfa_collection_enabled"
#define BLUESHIFT_PREF_SILENT_PUSH_ENABLED @"com.blueshift.config.silent_push_enabled"

#define BLUESHIFT_SERIAL_QUEUE "com.blueshift.sdk"

#import <Cordova/CDV.h>
#import "BlueshiftPlugin.h"
#import "AppDelegate.h"
#import <UserNotifications/UNUserNotificationCenter.h>

@implementation BlueshiftPlugin

static dispatch_queue_t bsft_serial_queue() {
    static dispatch_queue_t bsft_serial_queue;
    static dispatch_once_t s_done;
    dispatch_once(&s_done, ^{
        bsft_serial_queue = dispatch_queue_create(BLUESHIFT_SERIAL_QUEUE, DISPATCH_QUEUE_SERIAL);
    });
    return bsft_serial_queue;
}

#pragma mark: Plugin initialisation
- (void)pluginInitialize {
    [self initialiseBlueshiftSDK];
}

- (void)initialiseBlueshiftSDK {
    BlueShiftConfig *config = [[BlueShiftConfig alloc] init];
    [self setAPIKeyForConfig:config];
    
    [self setAppGroupIdForConfig:config];
    [self setDebugEnabledForConfig:config];
    [self setIDFACollectionEnabledForConfig:config];
    [self setSceneDelegateEnabledForConfig:config];

    [self setPushEnabledForConfig:config];
    [self setSilentPushEnabledForConfig:config];

    [self setInAppEnabledForConfig:config];
    [self setInAppIntervalForConfig:config];
    [self setInAppManualModeEnabledForConfig:config];
    [self setBackgroundFetchEnabledForConfig:config];
    
    [self setBatchUploadIntervalForConfig:config];
    [self setDeviceIdSourceForConfig:config];
    [self setAppOpenIntervalForConfig:config];
    
    config.blueshiftUniversalLinksDelegate = self;
    
    [BlueShift initWithConfiguration:config];
}

- (void)setAPIKeyForConfig:(BlueShiftConfig*)config {
    if ([self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_API_KEY] != nil) {
        NSString* apiKey = (NSString*)[self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_API_KEY];
        config.apiKey = apiKey;
    }
}

- (void)setDebugEnabledForConfig:(BlueShiftConfig*)config {
    if ([self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_DEBUG_ENABLED] != nil) {
        BOOL debugEnabled = [[self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_DEBUG_ENABLED] boolValue];
        config.debug = debugEnabled;
    }
}

- (void)setSceneDelegateEnabledForConfig:(BlueShiftConfig*)config {
    if ([self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_SCENE_DELEGATE_ENABLED] != nil) {
        BOOL isSceneDelegateEnabled = [[self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_SCENE_DELEGATE_ENABLED] boolValue];
        if (@available(iOS 13.0, *)) {
            config.isSceneDelegateConfiguration = isSceneDelegateEnabled;
        }
    }
}

- (void)setIDFACollectionEnabledForConfig:(BlueShiftConfig*)config {
    if ([self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_IDFA_COLLECTION_ENABLED] != nil) {
        BOOL isIDFACollectionEnabled = [[self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_IDFA_COLLECTION_ENABLED] boolValue];
        config.enableIDFACollection = isIDFACollectionEnabled;
    }
}
- (void)setAppGroupIdForConfig:(BlueShiftConfig*)config {
    if ([self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_APP_GROUP_ID] != nil) {
        NSString* appGroupID = (NSString*)[self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_APP_GROUP_ID];
        config.appGroupID = appGroupID;
    }
}

- (void)setPushEnabledForConfig:(BlueShiftConfig*)config {
    if ([self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_PUSH_ENABLED] != nil) {
        BOOL enablePushNotification = [[self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_PUSH_ENABLED] boolValue];
        config.enablePushNotification = enablePushNotification;
    }
}

- (void)setSilentPushEnabledForConfig:(BlueShiftConfig*)config {
    if ([self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_SILENT_PUSH_ENABLED] != nil) {
        BOOL enableSilentPushNotification = [[self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_SILENT_PUSH_ENABLED] boolValue];
        config.enableSilentPushNotification = enableSilentPushNotification;
    }
}

- (void)setInAppEnabledForConfig:(BlueShiftConfig*)config {
    if ([self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_IN_APP_ENABLED] != nil) {
        BOOL enableInAppNotification = [[self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_IN_APP_ENABLED] boolValue];
        config.enableInAppNotification = enableInAppNotification;
    }
}

- (void)setInAppIntervalForConfig:(BlueShiftConfig*)config {
    if ([self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_IN_APP_INTERVAL] != nil) {
        double inAppNotificationInterval = [[self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_IN_APP_INTERVAL] doubleValue];
        if (inAppNotificationInterval != 0) {
            config.BlueshiftInAppNotificationTimeInterval = inAppNotificationInterval;
        }
    }
}

- (void)setDeviceIdSourceForConfig:(BlueShiftConfig*)config {
    if ([self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_DEVICE_ID_SOURCE] != nil) {
        double deviceIdSource = [[self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_DEVICE_ID_SOURCE] intValue];
        config.blueshiftDeviceIdSource = (BlueshiftDeviceIdSource)deviceIdSource;
        if (config.blueshiftDeviceIdSource == BlueshiftDeviceIdSourceCustom) {
            [self setCustomDeviceForConfig:config];
        }
    }
}

- (void)setCustomDeviceForConfig:(BlueShiftConfig*)config {
    if ([self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_DEVICE_ID_CUSTOM_VALUE] != nil) {
        NSString *customDeviceId = (NSString*)[self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_DEVICE_ID_CUSTOM_VALUE];
        config.customDeviceId = customDeviceId;
    }
}

- (void)setInAppManualModeEnabledForConfig:(BlueShiftConfig*)config {
    if ([self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_IN_APP_MANUAL_MODE_ENABLED] != nil) {
        BOOL inAppManualTriggerEnabled = [[self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_IN_APP_MANUAL_MODE_ENABLED] boolValue];
        config.inAppManualTriggerEnabled = inAppManualTriggerEnabled;
    }
}

- (void)setBackgroundFetchEnabledForConfig:(BlueShiftConfig*)config {
    if ([self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_IN_APP_BACKGROUND_FETCH_ENABLED] != nil) {
        BOOL inAppBackgroundFetchEnabled = [[self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_IN_APP_BACKGROUND_FETCH_ENABLED] boolValue];
        config.inAppBackgroundFetchEnabled = inAppBackgroundFetchEnabled;
    }
}

- (void)setBatchUploadIntervalForConfig:(BlueShiftConfig*)config {
    if ([self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_BATCH_INTERVAL_SECONDS] != nil) {
        double batchUploadInterval = [[self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_BATCH_INTERVAL_SECONDS] doubleValue];
        if (batchUploadInterval != 0) {
            [BlueShiftBatchUploadConfig.sharedInstance setBatchUploadTimer:batchUploadInterval];
        }
    }
}

- (void)setAppOpenTrackingEnabledForConfig:(BlueShiftConfig*)config {
    if ([self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_AUTO_APP_OPEN_ENABLED] != nil) {
        BOOL enableAppOpenTrackEvent = [[self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_AUTO_APP_OPEN_ENABLED] boolValue];
        config.enableAppOpenTrackEvent = enableAppOpenTrackEvent;
        if (enableAppOpenTrackEvent) {
            [self setAppOpenIntervalForConfig:config];
        }
    }
}

- (void)setAppOpenIntervalForConfig:(BlueShiftConfig*)config {
    if ([self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_AUTO_APP_OPEN_INTERVAL_SECONDS] != nil) {
        double appOpenInterval = [[self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_AUTO_APP_OPEN_INTERVAL_SECONDS] doubleValue];
        config.automaticAppOpenTimeInterval = appOpenInterval;
    }
}

#pragma mark: In app messages
- (void)registerForInAppMessages:(CDVInvokedUrlCommand*)command
{
    if (command.arguments.count > 0) {
        [self runOnSerialQueue:^{
            NSString* screenName = (NSString*)[command.arguments objectAtIndex:0];
            CDVPluginResult* pluginResult = nil;
            if (screenName && screenName.length > 0) {
                [[BlueShift sharedInstance] registerForInAppMessage:screenName];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully registered for in-app notifications."];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid screen name passed. Failed to register for in-app notifications."];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Missing parameter Screen name. Failed to register for in-app notifications."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)unregisterForInAppMessages:(CDVInvokedUrlCommand*)command {
    [self runOnSerialQueue:^{
        [[BlueShift sharedInstance] unregisterForInAppMessage];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully un-registered for in-app notfiications."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)fetchInAppMessages:(CDVInvokedUrlCommand*)command {
    [self runOnSerialQueue:^{
        [[BlueShift sharedInstance] fetchInAppNotificationFromAPI:^{
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully fetched in-app notfiications."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } failure:^(NSError * _Nonnull error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Failed to fetch in-app notfiications."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void)displayInAppMessages:(CDVInvokedUrlCommand*)command {
    [self runOnSerialQueue:^{
        [[BlueShift sharedInstance] displayInAppNotification];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully un-registered for in-app notfiications."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

#pragma mark: Events
- (void)trackCustomEvent:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        [self runOnSerialQueue:^{
            CDVPluginResult* pluginResult = nil;
            NSString* eventName = (NSString*)[command.arguments objectAtIndex:0];
            NSDictionary* eventParams = nil;
            BOOL isBatch = NO;
            if (command.arguments.count > 1) {
                eventParams = (NSDictionary*)[command.arguments objectAtIndex:1];
            }
            if (command.arguments.count > 2) {
                isBatch = [[command.arguments objectAtIndex:2] boolValue];
            }
            if (eventName) {
                if (eventParams && ![eventParams isKindOfClass:[NSDictionary class]]) {
                    eventParams = nil;
                }
                [[BlueShift sharedInstance] trackEventForEventName:eventName andParameters:eventParams canBatchThisEvent:isBatch];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully tracked the event."];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Missing event name. Failed to track the event."];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to track the event."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)identify:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        [self runOnSerialQueue:^{
            NSDictionary* eventParams = (NSDictionary*)[command.arguments objectAtIndex:0];
            BOOL isBatch = NO;
            if (command.arguments.count > 1) {
                isBatch = [[command.arguments objectAtIndex:1] boolValue];
            }
            if (eventParams && ![eventParams isKindOfClass:[NSDictionary class]]) {
                eventParams = nil;
            }
            [[BlueShift sharedInstance] identifyUserWithDetails:eventParams canBatchThisEvent:isBatch];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully tracked the identify event."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to track the identify event."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

#pragma mark: User info
- (void)setUserInfoEmailID:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        [self runOnSerialQueue:^{
            NSString* emailId = (NSString*)[command.arguments objectAtIndex:0];
            [[BlueShiftUserInfo sharedInstance] setEmail:emailId];
            [[BlueShiftUserInfo sharedInstance] save];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully set the user email id."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed save the user email id."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)setUserInfoCustomerID:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        [self runOnSerialQueue:^{
            NSString* customerId = (NSString*)[command.arguments objectAtIndex:0];
            [[BlueShiftUserInfo sharedInstance] setRetailerCustomerID:customerId];
            [[BlueShiftUserInfo sharedInstance] save];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully set the user customer id."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed save the user customer id."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)setUserInfoFirstName:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        [self runOnSerialQueue:^{
            NSString* firstName = (NSString*)[command.arguments objectAtIndex:0];
            [[BlueShiftUserInfo sharedInstance] setFirstName:firstName];
            [[BlueShiftUserInfo sharedInstance] save];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully set the user first name."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed save the user first name."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)setUserInfoLastName:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        [self runOnSerialQueue:^{
            NSString* lastName = (NSString*)[command.arguments objectAtIndex:0];
            [[BlueShiftUserInfo sharedInstance] setLastName:lastName];
            [[BlueShiftUserInfo sharedInstance] save];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully set the user last name."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed save the user last name."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)setUserInfoExtras:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        [self runOnSerialQueue:^{
            NSDictionary* extras = (NSDictionary*)[command.arguments objectAtIndex:0];
            if (extras && [extras isKindOfClass:[NSDictionary class]]) {
                [[BlueShiftUserInfo sharedInstance] setExtras:extras];
                [[BlueShiftUserInfo sharedInstance] save];
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully set the extras for the user."];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Extras passed are not in valid JSON format. Failed set the extras."];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed set the extras."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)removeUserInfo:(CDVInvokedUrlCommand*)command {
    [self runOnSerialQueue:^{
        [BlueShiftUserInfo removeCurrentUserInfo];
        CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully removed the user info."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

#pragma mark: enable/disable SDK functinality
- (void)enableTracking:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        [self runOnSerialQueue:^{
            BOOL isEnabled = [[command.arguments objectAtIndex:0] boolValue];
            BOOL wipeData = YES;
            if (command.arguments.count > 1) {
                wipeData = [[command.arguments objectAtIndex:1] boolValue];
            }
            [[BlueShift sharedInstance] enableTracking:isEnabled andEraseNonSyncedData:wipeData];
            CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully updated the enable tracking status."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed set the enable tracking status."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)enablePush:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        [self runOnSerialQueue:^{
            BOOL isPushEnabled = [[command.arguments objectAtIndex:0] boolValue];
            [[BlueShiftAppData currentAppData] setEnablePush:isPushEnabled];
            CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully updated the enable push status."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed set the enable push status."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)enableInApp:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        [self runOnSerialQueue:^{
            BOOL isInAppEnabled = [[command.arguments objectAtIndex:0] boolValue];
            [[BlueShiftAppData currentAppData] setEnableInApp:isInAppEnabled];
            CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully updated the enable inApp status."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed set the enable inApp status."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

#pragma mark: Live content
- (void)getLiveContentByEmail:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        NSString* slot = (NSString*)[command.arguments objectAtIndex:0];
        NSDictionary* context = nil;
        if (command.arguments.count > 1) {
            context = (NSDictionary*)[command.arguments objectAtIndex:1];
        }
        if (slot) {
            if (context && ![context isKindOfClass:[NSDictionary class]]) {
                context = nil;
            }
            [self runOnSerialQueue:^{
                [BlueShiftLiveContent fetchLiveContentByEmail:slot withContext:context success:^(NSDictionary * data) {
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:data];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    
                } failure:^(NSError * error) {
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"API failed to fetch live content using email."];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }];
            }];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to fetch live content using email ."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }
}

- (void)getLiveContentByCustomerID:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        NSString* slot = (NSString*)[command.arguments objectAtIndex:0];
        NSDictionary* context = nil;
        if (command.arguments.count > 1) {
            context = (NSDictionary*)[command.arguments objectAtIndex:1];
        }
        if (slot) {
            if (context && ![context isKindOfClass:[NSDictionary class]]) {
                context = nil;
            }
            [self runOnSerialQueue:^{
                [BlueShiftLiveContent fetchLiveContentByCustomerID:slot withContext:context success:^(NSDictionary * data) {
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:data];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    
                } failure:^(NSError * error) {
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"API failed to fetch live content using customer id."];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }];
            }];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to fetch live content using email."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }
}

- (void)getLiveContentByDeviceID:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        NSString* slot = (NSString*)[command.arguments objectAtIndex:0];
        NSDictionary* context = nil;
        if (command.arguments.count > 1) {
            context = (NSDictionary*)[command.arguments objectAtIndex:1];
        }
        if (slot) {
            if (context && ![context isKindOfClass:[NSDictionary class]]) {
                context = nil;
            }
            [self runOnSerialQueue:^{
                [BlueShiftLiveContent fetchLiveContentByDeviceID:slot withContext:context success:^(NSDictionary * data) {
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:data];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                } failure:^(NSError * error) {
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"API failed to fetch live content using device Id."];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }];
            }];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to fetch live content using device Id."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }
}

#pragma mark: Push notifications
- (void)registerForRemoteNotification:(CDVInvokedUrlCommand*)command {
    [self runOnSerialQueue:^{
        CDVPluginResult* pluginResult = nil;
        [[BlueShift sharedInstance].appDelegate registerForNotification];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully registeredfor remote notifications."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

#pragma mark: Location
- (void)setCurrentLocation:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count == 2) {
        double latitude = [[command.arguments objectAtIndex: 0] doubleValue];
        double longitude = [[command.arguments objectAtIndex:1] doubleValue];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        [self runOnSerialQueue:^{
            CDVPluginResult* pluginResult = nil;
            if (location) {
                [[BlueShiftDeviceData currentDeviceData] setCurrentLocation:location];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully set the device location."];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Failed to set the device location."];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to set location."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

#pragma mark: Getter methods

- (void)getEnableInAppStatus:(CDVInvokedUrlCommand*)command  {
    [self runOnSerialQueue:^{
        BOOL isEnabled = [BlueShiftAppData currentAppData].enableInApp;
        CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isEnabled];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getEnablePushStatus:(CDVInvokedUrlCommand*)command  {
    [self runOnSerialQueue:^{
        BOOL isEnabled = [BlueShiftAppData currentAppData].enablePush;
        CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isEnabled];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getEnableTrackingStatus:(CDVInvokedUrlCommand*)command  {
    [self runOnSerialQueue:^{
        BOOL isEnabled = [BlueShift sharedInstance].isTrackingEnabled;
        CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isEnabled];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}
- (void)getUserInfoEmailID:(CDVInvokedUrlCommand*)command  {
    [self runOnSerialQueue:^{
        NSString* emailId = [BlueShiftUserInfo sharedInstance].email;
        CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:emailId];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getUserInfoCustomerID:(CDVInvokedUrlCommand*)command  {
    [self runOnSerialQueue:^{
        NSString* customerId = [BlueShiftUserInfo sharedInstance].retailerCustomerID;
        CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:customerId];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getUserInfoFirstname:(CDVInvokedUrlCommand*)command  {
    [self runOnSerialQueue:^{
        NSString* firstName = [BlueShiftUserInfo sharedInstance].firstName;
        CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:firstName];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getUserInfoLastname:(CDVInvokedUrlCommand*)command  {
    [self runOnSerialQueue:^{
        NSString* lastName = [BlueShiftUserInfo sharedInstance].lastName;
        CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:lastName];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getUserInfoExtras:(CDVInvokedUrlCommand*)command {
    [self runOnSerialQueue:^{
        NSDictionary* extras = [BlueShiftUserInfo sharedInstance].extras;
        CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:extras];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getCurrentDeviceId:(CDVInvokedUrlCommand*)command  {
    [self runOnSerialQueue:^{
        NSString* deviceId = [BlueShiftDeviceData currentDeviceData].deviceUUID;
        CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:deviceId];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

#pragma mark: Serial queue
- (void)runOnSerialQueue:(void (^)(void))block {
    dispatch_async(bsft_serial_queue(), ^{
        block();
    });
}

#pragma mark: Blueshift Universal links delegate methods
- (void) didCompleteLinkProcessing: (NSURL *_Nullable)url {
    
}

- (void) didFailLinkProcessingWithError: (NSError *_Nullable)error url:(NSURL *_Nullable)url {
    
}

- (void) didStartLinkProcessing {
    
}


@end
