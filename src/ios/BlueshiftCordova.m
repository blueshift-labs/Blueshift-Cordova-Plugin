//
//  Blueshift.m
//  Blueshift
//
//  Created by Ketan Shikhare on 15/03/21.
//  Copyright Blueshift 2021. All rights reserved.

#import <Cordova/CDV.h>
#import <BlueShift_iOS_SDK/BlueShift.h>
#import "BlueshiftCordova.h"

@implementation BlueshiftCordova

- (void)registerForInAppMessages:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    if (command.arguments.count > 0) {
        NSString* screenName = [command.arguments objectAtIndex:0];
        if (screenName && screenName.length > 0) {
            [[BlueShift sharedInstance] registerForInAppMessage:screenName];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully registered for in-app notifications."];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid screen name passed. Failed to register for in-app notifications."];
        }
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Missing parameter Screen name. Failed to register for in-app notifications."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)unregisterForInAppMessages:(CDVInvokedUrlCommand*)command {
    [[BlueShift sharedInstance] unregisterForInAppMessage];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully un-registered for in-app notfiications."];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)fetchInAppMessages:(CDVInvokedUrlCommand*)command {
    [[BlueShift sharedInstance] fetchInAppNotificationFromAPI:^{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully fetched in-app notfiications."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } failure:^(NSError * _Nonnull error) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Failed to fetch in-app notfiications."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)displayInAppMessages:(CDVInvokedUrlCommand*)command {
    [[BlueShift sharedInstance] displayInAppNotification];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully un-registered for in-app notfiications."];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)trackCustomEvent:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    if (command.arguments.count > 0) {
        NSString* eventName = (NSString*)[command.arguments objectAtIndex:0];
        NSDictionary* eventParams = (NSDictionary*)[command.arguments objectAtIndex:1];
        BOOL isBatch = (BOOL)[command.arguments objectAtIndex:2];
        if (eventName) {
            if (!eventParams) {
                eventParams = nil;
            }
            [[BlueShift sharedInstance] trackEventForEventName:eventName andParameters:eventParams canBatchThisEvent:isBatch];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully tracked the event."];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Missing event name. Failed to track the event."];
        }
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to track the event."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)identify:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    if (command.arguments.count > 0) {
        NSDictionary* eventParams = (NSDictionary*)[command.arguments objectAtIndex:0];
        BOOL isBatch = (BOOL)[command.arguments objectAtIndex:1];
        if (!eventParams) {
            eventParams = nil;
        }
        [[BlueShift sharedInstance] identifyUserWithDetails:eventParams canBatchThisEvent:isBatch];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully tracked the identify event."];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to track the identify event."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setUserInfoEmailID:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    if (command.arguments.count > 0) {
        NSString* emailId = (NSString*)[command.arguments objectAtIndex:0];
        [[BlueShiftUserInfo sharedInstance] setEmail:emailId];
        [[BlueShiftUserInfo sharedInstance] save];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully set the user email id."];
        
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed save the user email id."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setUserInfoCustomerID:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    if (command.arguments.count > 0) {
        NSString* customerId = (NSString*)[command.arguments objectAtIndex:0];
        [[BlueShiftUserInfo sharedInstance] setEmail:customerId];
        [[BlueShiftUserInfo sharedInstance] save];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully set the user customer id."];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed save the user customer id."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setUserInfoFirstname:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    if (command.arguments.count > 0) {
        NSString* firstName = (NSString*)[command.arguments objectAtIndex:0];
        [[BlueShiftUserInfo sharedInstance] setFirstName:firstName];
        [[BlueShiftUserInfo sharedInstance] save];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully set the user first name."];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed save the user first name."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}

- (void)setUserInfoLastname:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    if (command.arguments.count > 0) {
        NSString* lastName = (NSString*)[command.arguments objectAtIndex:0];
            [[BlueShiftUserInfo sharedInstance] setLastName:lastName];
            [[BlueShiftUserInfo sharedInstance] save];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully set the user last name."];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed save the user last name."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setUserInfoExtras:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    if (command.arguments.count > 0) {
        NSDictionary* extras = (NSDictionary*)[command.arguments objectAtIndex:0];
//            [[BlueShiftUserInfo sharedInstance] setex:lastName];
//            [[BlueShiftUserInfo sharedInstance] save];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully set the extras for the user."];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed set the extras."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)removeUserInfo:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    [BlueShiftUserInfo removeCurrentUserInfo];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully removed the user info."];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)enableTracking:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    BOOL isEnabled = (BOOL)[command.arguments objectAtIndex:0];
    [[BlueShift sharedInstance] enableTracking:isEnabled];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully updated the enable tracking status."];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)enablePush:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    BOOL isPushEnabled = (BOOL)[command.arguments objectAtIndex:0];
    [[BlueShiftAppData currentAppData] setEnablePush:isPushEnabled];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully updated the enable push status."];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// TODO
- (void)enableInApp:(CDVInvokedUrlCommand*)command {
    
}

- (void)getLiveContentByEmail:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        NSString* emailId = (NSString*)[command.arguments objectAtIndex:0];
        NSDictionary* context = (NSDictionary*)[command.arguments objectAtIndex:1];
        if (emailId) {
            if (!context) {
                context = nil;
            }
            [BlueShiftLiveContent fetchLiveContentByEmail:emailId withContext:context success:^(NSDictionary * data) {
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:data];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                
            } failure:^(NSError * error) {
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"API failed to fetch live content using email."];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to fetch live content using email ."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }
}

- (void)getLiveContentByCustomerID:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        NSString* customerId = (NSString*)[command.arguments objectAtIndex:0];
        NSDictionary* context = (NSDictionary*)[command.arguments objectAtIndex:1];
        if (customerId) {
            if (!context) {
                context = nil;
            }
            [BlueShiftLiveContent fetchLiveContentByCustomerID:customerId withContext:context success:^(NSDictionary * data) {
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:data];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                
            } failure:^(NSError * error) {
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"API failed to fetch live content using customer id."];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to fetch live content using email."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }
}

- (void)getLiveContentByDeviceID:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count > 0) {
        NSString* deviceId = (NSString*)[command.arguments objectAtIndex:0];
        NSDictionary* context = (NSDictionary*)[command.arguments objectAtIndex:1];
        if (deviceId) {
            if (!context) {
                context = nil;
            }
            [BlueShiftLiveContent fetchLiveContentByDeviceID:deviceId withContext:context success:^(NSDictionary * data) {
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:data];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                
            } failure:^(NSError * error) {
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"API failed to fetch live content using device Id."];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to fetch live content using device Id."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }
}

- (void)registerForRemoteNotification:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    [[BlueShift sharedInstance].appDelegate registerForNotification];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully registeredfor remote notifications."];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setCurrentLocation:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    if (command.arguments.count == 2) {
        double latitude = [[command.arguments objectAtIndex: 0] doubleValue];
        double longitude = [[command.arguments objectAtIndex:1] doubleValue];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        if (location) {
            [[BlueShiftDeviceData currentDeviceData] setCurrentLocation:location];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully set the device location."];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Failed to set the device location."];
        }
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments. Failed to set location."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
