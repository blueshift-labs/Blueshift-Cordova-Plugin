//
//  Blueshift.m
//  Blueshift
//
//  Created by Ketan Shikhare on 15/03/21.
//  Copyright Blueshift 2021. All rights reserved.

#import <Cordova/CDV.h>
#import <BlueShift_iOS_SDK/BlueShift.h>
#import "BlueshiftPlugin.h"

@implementation BlueshiftPlugin

static dispatch_queue_t bsft_serial_queue() {
    static dispatch_queue_t bsft_serial_queue;
    static dispatch_once_t s_done;
    dispatch_once(&s_done, ^{
        bsft_serial_queue = dispatch_queue_create("com.blueshift.cordova", DISPATCH_QUEUE_SERIAL);
        
    });
    
    return bsft_serial_queue;
}

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

- (void)trackCustomEvent:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        [self runOnSerialQueue:^{
            CDVPluginResult* pluginResult = nil;
            NSString* eventName = (NSString*)[command.arguments objectAtIndex:0];
            NSDictionary* eventParams = (NSDictionary*)[command.arguments objectAtIndex:1];
            BOOL isBatch = [[command.arguments objectAtIndex:2] boolValue];
            if (eventName) {
                if (!eventParams) {
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
            BOOL isBatch = [[command.arguments objectAtIndex:1] boolValue];
            if (!eventParams) {
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

- (void)enableTracking:(CDVInvokedUrlCommand*)command {
    [self runOnSerialQueue:^{
        BOOL isEnabled = [[command.arguments objectAtIndex:0] boolValue];
        BOOL wipeData = [[command.arguments objectAtIndex:1] boolValue];
        [[BlueShift sharedInstance] enableTracking:isEnabled andEraseNonSyncedData:wipeData];
        CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully updated the enable tracking status."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)enablePush:(CDVInvokedUrlCommand*)command {
    [self runOnSerialQueue:^{
        BOOL isPushEnabled = [[command.arguments objectAtIndex:0] boolValue];
        [[BlueShiftAppData currentAppData] setEnablePush:isPushEnabled];
        CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully updated the enable push status."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

// TODO
- (void)enableInApp:(CDVInvokedUrlCommand*)command {
    
}

- (void)getLiveContentByEmail:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        NSString* slot = (NSString*)[command.arguments objectAtIndex:0];
        NSDictionary* context = (NSDictionary*)[command.arguments objectAtIndex:1];
        if (slot) {
            if (!context) {
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
        NSDictionary* context = (NSDictionary*)[command.arguments objectAtIndex:1];
        if (slot) {
            if (!context) {
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
        NSDictionary* context = (NSDictionary*)[command.arguments objectAtIndex:1];
        if (slot) {
            if (!context) {
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

- (void)registerForRemoteNotification:(CDVInvokedUrlCommand*)command {
    [self runOnSerialQueue:^{
        CDVPluginResult* pluginResult = nil;
        [[BlueShift sharedInstance].appDelegate registerForNotification];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully registeredfor remote notifications."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

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

- (void)runOnSerialQueue:(void (^)(void))block {
    dispatch_async(bsft_serial_queue(), ^{
        block();
    });
}

@end
