//
//  Blueshift.m
//  Blueshift
//
//  Created by Ketan Shikhare on 15/03/21.
//  Copyright Blueshift 2021. All rights reserved.

#define BLUESHIFT_PREF_API_KEY                  @"com.blueshift.config.event_api_key"
#define BLUESHIFT_PREF_PUSH_ENABLED             @"com.blueshift.config.push_enabled"
#define BLUESHIFT_PREF_IN_APP_ENABLED           @"com.blueshift.config.in_app_enabled"
#define BLUESHIFT_PREF_IN_APP_INTERVAL          @"com.blueshift.config.in_app_interval_seconds"
#define BLUESHIFT_PREF_IN_APP_BACKGROUND_FETCH_ENABLED @"com.blueshift.config.in_app_background_fetch_enabled"
#define BLUESHIFT_PREF_IN_APP_MANUAL_MODE_ENABLED @"com.blueshift.config.in_app_manual_mode_enabled"
#define BLUESHIFT_PREF_DEVICE_ID_SOURCE         @"com.blueshift.config.device_id_source"
#define BLUESHIFT_PREF_DEVICE_ID_CUSTOM_VALUE   @"com.blueshift.config.device_id_custom_value"
#define BLUESHIFT_PREF_BATCH_INTERVAL_SECONDS   @"com.blueshift.config.batch_interval_seconds"
#define BLUESHIFT_PREF_AUTO_APP_OPEN_ENABLED    @"com.blueshift.config.auto_app_open_enabled"
#define BLUESHIFT_PREF_AUTO_APP_OPEN_INTERVAL_SECONDS @"com.blueshift.config.auto_app_open_interval_seconds"

#define BLUESHIFT_PREF_DEBUG_ENABLED            @"com.blueshift.config.debug_logs_enabled"
#define BLUESHIFT_PREF_APP_GROUP_ID             @"com.blueshift.config.app_group_id"
#define BLUESHIFT_PREF_SILENT_PUSH_ENABLED      @"com.blueshift.config.silent_push_enabled"
#define BLUESHIFT_PREF_REGION                   @"com.blueshift.config.region"
#define BLUESHIFT_PREF_SDK_COREDATA_FILES_LOCATION  @"com.blueshift.config.sdk_coredata_files_location"

#define BLUESHIFT_SERIAL_QUEUE                  "com.blueshift.sdk"

#define BLUESHIFT_DEEPLINK_REPLAY_START         @"OnBlueshiftDeepLinkReplayStart"
#define BLUESHIFT_DEEPLINK_REPLAY_FAIL          @"OnBlueshiftDeepLinkReplayFail"
#define BLUESHIFT_DEEPLINK_SUCCESS              @"OnBlueshiftDeepLinkSuccess"
#define BLUESHIFT_DEEPLINK_ATTRIBUTE            @"deepLink"
#define BLUESHIFT_ERROR_ATTRIBUTE               @"error"

#define BLUESHIFT_DEVICEID_SOURCE_IDFV          @"BlueshiftDeviceIdSourceIDFV"
#define BLUESHIFT_DEVICEID_SOURCE_UUID          @"BlueshiftDeviceIdSourceUUID"
#define BLUESHIFT_DEVICEID_SOURCE_IDFVBUNDLEID  @"BlueshiftDeviceIdSourceIDFVBundleID"
#define BLUESHIFT_DEVICEID_SOURCE_CUSTOM        @"BlueshiftDeviceIdSourceCustom"

#define BLUESHIFT_REGION_US                     @"US"
#define BLUESHIFT_REGION_EU                     @"EU"

#define BLUESHIFT_SDK_DOCUMENTS_DIRECTORY       @"Documents"
#define BLUESHIFT_SDK_LIBRARY_DIRECTORY         @"Library"

#import <Cordova/CDV.h>
#import "BlueshiftPlugin.h"
#import "AppDelegate+BlueshiftPlugin.h"
#import <BlueShift_iOS_SDK/BlueshiftVersion.h>

@implementation BlueshiftPlugin {
    BOOL isPageLoaded;
}

static NSString* launchPushNotificationAdditionalInfo = nil;
static NSString* universalLinkAdditionalInfo = nil;

static dispatch_queue_t bsft_serial_queue(void) {
    static dispatch_queue_t bsft_serial_queue;
    static dispatch_once_t s_done;
    dispatch_once(&s_done, ^{
        bsft_serial_queue = dispatch_queue_create(BLUESHIFT_SERIAL_QUEUE, DISPATCH_QUEUE_SERIAL);
    });
    return bsft_serial_queue;
}

#pragma mark: Plugin initialisation

- (void)pluginInitialize {
    [self setObservers];
    [self initialiseBlueshiftSDK];
    [AppDelegate swizzleMainAppDelegate];
}

- (void)setObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeepLinkURLNotification:) name:BLUESHIFT_HANDLE_DEEPLINK_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceReady) name:CDVPageDidLoadNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishLaunchingNotification:) name:UIApplicationDidFinishLaunchingNotification object:nil];
}

- (void)initialiseBlueshiftSDK {
    BlueShiftConfig *config = [[BlueShiftConfig alloc] init];
    [self setAPIKeyForConfig:config];
    
    [self setAppGroupIdForConfig:config];
    [self setDebugEnabledForConfig:config];

    [self setPushEnabledForConfig:config];
    [self setSilentPushEnabledForConfig:config];

    [self setInAppEnabledForConfig:config];
    [self setInAppIntervalForConfig:config];
    [self setInAppManualModeEnabledForConfig:config];
    [self setBackgroundFetchEnabledForConfig:config];
    
    [self setBatchUploadIntervalForConfig:config];
    [self setDeviceIdSourceForConfig:config];
    [self setAppOpenTrackingEnabledForConfig:config];
    [self setUserNotificationCenterDelegate:config];
    
    [self setSDKCoreDataFilesLocation:config];
    [self setRegion:config];

    config.blueshiftUniversalLinksDelegate = self;
    
    [BlueShift initWithConfiguration:config];
}

- (void)deviceReady {
    if (isPageLoaded == NO) {
        isPageLoaded = YES;
        if (launchPushNotificationAdditionalInfo != nil) {
            [self fireDocumentEventForName:BLUESHIFT_DEEPLINK_SUCCESS additionalInfo:launchPushNotificationAdditionalInfo];
            launchPushNotificationAdditionalInfo = nil;
        }
        if (universalLinkAdditionalInfo) {
            [self fireDocumentEventForName:BLUESHIFT_DEEPLINK_SUCCESS additionalInfo:universalLinkAdditionalInfo];
            universalLinkAdditionalInfo = nil;
        }
    }
}

- (void)didFinishLaunchingNotification:(NSNotification*)notification {
    if (!notification) return;
    if(notification.userInfo) {
        [[BlueShift sharedInstance].appDelegate handleRemoteNotificationOnLaunchWithLaunchOptions:notification.userInfo];
    }
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
        NSString* deviceIdSource = [self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_DEVICE_ID_SOURCE];
        if ([deviceIdSource isEqualToString: BLUESHIFT_DEVICEID_SOURCE_IDFV]) {
            config.blueshiftDeviceIdSource = BlueshiftDeviceIdSourceIDFV;
        } else if ([deviceIdSource isEqualToString: BLUESHIFT_DEVICEID_SOURCE_UUID]){
            config.blueshiftDeviceIdSource = BlueshiftDeviceIdSourceUUID;
        } else if([deviceIdSource isEqualToString: BLUESHIFT_DEVICEID_SOURCE_IDFVBUNDLEID]) {
            config.blueshiftDeviceIdSource = BlueshiftDeviceIdSourceIDFVBundleID;
        } else if([deviceIdSource isEqualToString:BLUESHIFT_DEVICEID_SOURCE_CUSTOM]) {
            config.blueshiftDeviceIdSource = BlueshiftDeviceIdSourceCustom;
        }
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

- (void)setUserNotificationCenterDelegate:(BlueShiftConfig*)config {
    if (@available(iOS 10.0, *)) {
        id uiApplicationDelegate = [UIApplication sharedApplication].delegate;
        SEL didReceiveNotification = @selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
        SEL willPresentNotification = @selector(userNotificationCenter:willPresentNotification:withCompletionHandler:);
        BOOL isUNCenterDelegate = ([uiApplicationDelegate respondsToSelector:didReceiveNotification] || [uiApplicationDelegate respondsToSelector:willPresentNotification]);
        if (isUNCenterDelegate == YES) {
            config.userNotificationDelegate = uiApplicationDelegate;
        }
    }
}

- (void)setRegion:(BlueShiftConfig*)config {
    if ([self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_REGION] != nil) {
        NSString* region = [self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_REGION];
        if ([region isEqualToString: BLUESHIFT_REGION_EU]) {
            config.region = BlueshiftRegionEU;
        }
    }
}

- (void)setSDKCoreDataFilesLocation:(BlueShiftConfig*)config {
    if ([self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_SDK_COREDATA_FILES_LOCATION] != nil) {
        NSString* directory = [self.commandDelegate.settings valueForKey:BLUESHIFT_PREF_SDK_COREDATA_FILES_LOCATION];
        if ([directory isEqualToString: BLUESHIFT_SDK_LIBRARY_DIRECTORY]) {
            config.sdkCoreDataFilesLocation = BlueshiftFilesLocationLibraryDirectory;
        }
    }
}

#pragma mark: Deep link events handling
- (void)handleDeepLinkURLNotification:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[NSURL class]]) {
        NSURL *url = (NSURL*)notification.object;
        if (url) {
            NSString *additionalInfo = [NSString stringWithFormat:@"{'%@':'%@'}",BLUESHIFT_DEEPLINK_ATTRIBUTE, url.absoluteString];
            if (isPageLoaded) {
                [self fireDocumentEventForName:BLUESHIFT_DEEPLINK_SUCCESS additionalInfo: additionalInfo];
            } else {
                launchPushNotificationAdditionalInfo = additionalInfo;
            }
        }
    }
}

- (void)fireDocumentEventForName:(NSString*) eventName additionalInfo:(NSString*)additionalInfo {
    if (eventName && additionalInfo) {
        NSString *js = [NSString stringWithFormat:@"cordova.fireDocumentEvent('%@', %@);",eventName,additionalInfo];
        [self.commandDelegate evalJs:js];
    }
}

#pragma mark: In app messages
- (void)registerForInAppMessages:(CDVInvokedUrlCommand*)command
{
    if (command.arguments.count > 0) {
        [self runOnSerialQueueAfter:500 block:^{
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
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully un-registered for in-app notifications."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)fetchInAppMessages:(CDVInvokedUrlCommand*)command {
    [self runOnSerialQueue:^{
        if ([[BlueShiftAppData currentAppData] getCurrentInAppNotificationStatus] == YES) {
            [[BlueShift sharedInstance] fetchInAppNotificationFromAPI:^{
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully fetched in-app notifications."];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } failure:^(NSError * _Nonnull error) {
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Failed to fetch in-app notifications."];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"In-app notifications are not currently enabled on the device."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

- (void)displayInAppMessages:(CDVInvokedUrlCommand*)command {
    [self runOnSerialQueue:^{
        [[BlueShift sharedInstance] displayInAppNotification];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully un-registered for in-app notifications."];
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
                [[BlueShift sharedInstance] trackEventForEventName:eventName andParameters:[self addCDSDKVersionString:eventParams] canBatchThisEvent:isBatch];
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
            [[BlueShift sharedInstance] identifyUserWithDetails:[self addCDSDKVersionString:eventParams] canBatchThisEvent:isBatch];
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
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to set the user email id."];
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
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to set the user customer id."];
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
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to set the user first name."];
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
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to set the user last name."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)setUserInfoExtras:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        [self runOnSerialQueue:^{
            NSDictionary* extras = (NSDictionary*)[command.arguments objectAtIndex:0];
            if (extras && [extras isKindOfClass:[NSDictionary class]]) {
                [[BlueShiftUserInfo sharedInstance] setExtras:[extras mutableCopy]];
                [[BlueShiftUserInfo sharedInstance] save];
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully set the extras for the user."];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Extras passed are not in valid JSON format. Failed to set the extras."];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to set the extras."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)removeUserInfo:(CDVInvokedUrlCommand*)command {
    [self runOnSerialQueue:^{
        [BlueShiftUserInfo removeCurrentUserInfo];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully removed the user info."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)resetDeviceId:(CDVInvokedUrlCommand*)command {
    [self runOnSerialQueue:^{
        CDVPluginResult* pluginResult = nil;
        if ([BlueShift sharedInstance].config.blueshiftDeviceIdSource == BlueshiftDeviceIdSourceUUID) {
        [[BlueShiftDeviceData currentDeviceData] resetDeviceUUID];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully reset the device id."];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Failed reset the device id."];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}


#pragma mark: enable/disable SDK functinality
- (void)enableTracking:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        [self runOnSerialQueue:^{
            BOOL isEnabled = [[command.arguments objectAtIndex:0] boolValue];
            BOOL wipeData = !isEnabled;
            if (command.arguments.count > 1) {
                wipeData = [[command.arguments objectAtIndex:1] boolValue];
            }
            [[BlueShift sharedInstance] enableTracking:isEnabled andEraseNonSyncedData:wipeData];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully updated the enable tracking status."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to set the enable tracking status."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)enablePush:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        [self runOnSerialQueue:^{
            BOOL isPushEnabled = [[command.arguments objectAtIndex:0] boolValue];
            [[BlueShiftAppData currentAppData] setEnablePush:isPushEnabled];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully updated the enable push status."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to set the enable push status."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)enableInApp:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        [self runOnSerialQueue:^{
            BOOL isInAppEnabled = [[command.arguments objectAtIndex:0] boolValue];
            [[BlueShiftAppData currentAppData] setEnableInApp:isInAppEnabled];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully updated the enable inApp status."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to set the enable inApp status."];
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
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Failed to fetch live content using email id."];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }];
            }];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to fetch live content using email id."];
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
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Failed to fetch live content using customer id."];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }];
            }];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to fetch live content using customer id."];
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
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Failed to fetch live content using device id."];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }];
            }];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to fetch live content using device id."];
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
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to set device location."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)setIDFA:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        NSString* idfa = (NSString*)[command.arguments objectAtIndex:0];
        [BlueShiftDeviceData currentDeviceData].deviceIDFA = idfa;
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully set the IDFA."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to set IDFA."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

#pragma mark: Getter methods

- (void)getEnableInAppStatus:(CDVInvokedUrlCommand*)command  {
    [self runOnSerialQueue:^{
        BOOL isEnabled = [BlueShiftAppData currentAppData].enableInApp;
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isEnabled];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getEnablePushStatus:(CDVInvokedUrlCommand*)command  {
    [self runOnSerialQueue:^{
        BOOL isEnabled = [BlueShiftAppData currentAppData].enablePush;
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isEnabled];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getEnableTrackingStatus:(CDVInvokedUrlCommand*)command  {
    [self runOnSerialQueue:^{
        BOOL isEnabled = [BlueShift sharedInstance].isTrackingEnabled;
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isEnabled];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}
- (void)getUserInfoEmailID:(CDVInvokedUrlCommand*)command  {
    [self runOnSerialQueue:^{
        NSString* emailId = [BlueShiftUserInfo sharedInstance].email;
        if (!emailId) {
            emailId = @"";
        }
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:emailId];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getUserInfoCustomerID:(CDVInvokedUrlCommand*)command  {
    [self runOnSerialQueue:^{
        NSString* customerId = [BlueShiftUserInfo sharedInstance].retailerCustomerID;
        if (!customerId) {
            customerId = @"";
        }
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:customerId];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getUserInfoFirstName:(CDVInvokedUrlCommand*)command  {
    [self runOnSerialQueue:^{
        NSString* firstName = [BlueShiftUserInfo sharedInstance].firstName;
        if (!firstName) {
            firstName = @"";
        }
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:firstName];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getUserInfoLastName:(CDVInvokedUrlCommand*)command  {
    [self runOnSerialQueue:^{
        NSString* lastName = [BlueShiftUserInfo sharedInstance].lastName;
        if (!lastName) {
            lastName = @"";
        }
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:lastName];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getUserInfoExtras:(CDVInvokedUrlCommand*)command {
    [self runOnSerialQueue:^{
        NSDictionary* extras = [BlueShiftUserInfo sharedInstance].extras;
        if (!extras) {
            extras = @{};
        }
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:extras];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getCurrentDeviceId:(CDVInvokedUrlCommand*)command  {
    [self runOnSerialQueue:^{
        NSString* deviceId = [BlueShiftDeviceData currentDeviceData].deviceUUID;
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:deviceId];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

#pragma mark: Serial queue
- (void)runOnSerialQueue:(void (^)(void))block {
    dispatch_async(bsft_serial_queue(), ^{
        block();
    });
}

- (void)runOnSerialQueueAfter:(NSTimeInterval)milliSeconds block:(void (^)(void))block {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, milliSeconds * NSEC_PER_MSEC),bsft_serial_queue(), ^{
        block();
    });
}

#pragma mark: Blueshift Universal links delegate methods
- (void)didCompleteLinkProcessing: (NSURL *_Nullable)url {
    if (url) {
        NSString *additionalInfo = [NSString stringWithFormat:@"{'%@':'%@'}",BLUESHIFT_DEEPLINK_ATTRIBUTE, url.absoluteString];
        if (isPageLoaded == YES) {
            [self fireDocumentEventForName:BLUESHIFT_DEEPLINK_SUCCESS additionalInfo:additionalInfo];
        } else {
            universalLinkAdditionalInfo = additionalInfo;
        }
    }
}

- (void)didFailLinkProcessingWithError: (NSError *_Nullable)error url:(NSURL *_Nullable)url {
    if (url) {
        NSString *additionalInfo = [NSString stringWithFormat:@"{'%@':'%@','%@':'%@'}",BLUESHIFT_DEEPLINK_ATTRIBUTE, url.absoluteString, BLUESHIFT_ERROR_ATTRIBUTE, error.localizedDescription];
        if (isPageLoaded == YES) {
            [self fireDocumentEventForName:BLUESHIFT_DEEPLINK_REPLAY_FAIL additionalInfo:additionalInfo];
        } else {
            universalLinkAdditionalInfo = additionalInfo;
        }
    }
}

- (void)didStartLinkProcessing {
    [self fireDocumentEventForName:BLUESHIFT_DEEPLINK_REPLAY_START additionalInfo:@"{}"];
}

#pragma mark - helper methods
- (NSDictionary *)addCDSDKVersionString: (NSDictionary*) details {
    NSString *sdkVersion = [NSString stringWithFormat:@"%@-CD-%@",kBlueshiftSDKVersion,kBlueshiftCordovaSDKVersion];
    if ([details isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [details mutableCopy];
        dict[kInAppNotificationModalSDKVersionKey] = sdkVersion;
        return dict;
    } else {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[kInAppNotificationModalSDKVersionKey] = sdkVersion;
        return dict;
    }
}

@end
