# Blueshift-Cordova-Plugin

Cordova plugin is a package of injected code that allows the Cordova WebView to communicate with the native platform.

## Get Blueshift Cordova Plugin
To integrate Blueshift Android SDK to a Cordova project, you should get the latest Blueshift Cordova Plugin from GitHub. For this, go to the project’s root folder and run the following command from your terminal window.

```
cordova plugin add https://github.com/blueshift-labs/Blueshift-Cordova-Plugin --variable BSFT_EVENT_API_KEY=<event-api-key>
```

### Android
#### Add Firebase Messaging to the project
Integrate firebase to the host app if the app does not have it integrated already. Then add the following lines to the AndroidManifest.xml file to let Blueshift handle all the push messages.

```xml
<service android:name="com.blueshift.fcm.BlueshiftMessagingService">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```
If the host app already has a FirebaseMessagingService implementation, please refer to [this](https://developer.blueshift.com/docs/push-notifications-android-sdk) documentation to see how you can override the BlueshiftMessagingService.

### iOS
To support rich push notifications from Blueshift, set up notification service and content extensions as mentioned in [this](https://developer.blueshift.com/docs/integrate-your-ios-apps-notifications-with-blueshift) document. 

## Configure the plugin (optional)
This is an optional step if you only need event reporting and push messaging as a service from Blueshift.

Once the plugin is added to the project, Blueshift SDK will be able to initialize automatically with a default set of configurations. If you wish to change these configurations, make use of the preference tag in the `config.xml` file.

Below are the complete set of configurations you can specify using the `config.xml` file with their sample values.

### Android
```xml
<!-- Tells the SDK to set app's icon for use in Notifications. If not provided,
default app icon will be used. -->
<preference name="com.blueshift.config.app_icon" value="mipmap/ic_launcher"/>

<!-- Tells the SDK to enable/disable push notification.
Default value: true -->
<preference name="com.blueshift.config.push_enabled" value="true"/>

<!-- Tells the SDK to enable/disable in-app messages.
Default value: false -->
<preference name="com.blueshift.config.in_app_enabled" value="true"/>

<!-- Tells the SDK to enable/disable Javascript in in-app messages.
Default value: false -->
<preference name="com.blueshift.config.in_app_javascript_enabled" value="true"/>

<!-- Tells the SDK to change interval between in-app messages.
Default value: 60 (1 minute) -->
<preference name="com.blueshift.config.in_app_interval_seconds" value="180"/>

<!-- Tells the SDK to enable/disable in-app message background fetch.
Default value: true -->
<preference name="com.blueshift.config.in_app_background_fetch_enabled" value="true"/>

<!-- Tells the SDK to enable/disable in-app message manual mode.
Default value: false -->
<preference name="com.blueshift.config.in_app_manual_mode_enabled" value="false"/>

<!-- Tells the SDK to set a custom notification color.
Default value: system default. -->
<preference name="com.blueshift.config.notification_color" value="color/notification_color"/>

<!-- Tells the SDK to set a custom small icon.
Default value: app icon. -->
<preference name="com.blueshift.config.notification_icon_small" value="drawable/notification_icon_small"/>

<!-- Tells the SDK to set a custom large icon.
Default value: app icon. -->
<preference name="com.blueshift.config.notification_icon_large" value="drawable/notification_icon_large"/>

<!-- Tells the SDK to set a default notification channel id.
Default value: set by the SDK. -->
<preference name="com.blueshift.config.notification_channel_id" value="notification_channel_id"/>

<!-- Tells the SDK to set a default notification channel name.
Default value: set by the SDK. -->
<preference name="com.blueshift.config.notification_channel_name" value="notification_channel_name"/>

<!-- Tells the SDK to set a default notification channel description.
Default value: set by the SDK. -->
<preference name="com.blueshift.config.notification_channel_description" value="notification_channel_description"/>

<!-- Tells the SDK to set a device id source. Supported values are, 
ADVERTISING_ID, INSTANCE_ID, GUID, ADVERTISING_ID_PKG_NAME, INSTANCE_ID_PKG_NAME.
Default value: ADVERTISING_ID. -->
<preference name="com.blueshift.config.device_id_source" value="INSTANCE_ID"/>

<!-- Tells the SDK to set a custom batch interval.
Default value: 1800 (30 minutes). -->
<preference name="com.blueshift.config.batch_interval_seconds" value="1800"/>

<!-- Tells the SDK to enable/disable auto app_open events.
Default value: false. -->
<preference name="com.blueshift.config.auto_app_open_enabled" value="true"/>

<!-- Tells the SDK to set an interval between auto app_open events.
Default value: 86400 (24 hours). -->
<preference name="com.blueshift.config.auto_app_open_interval_seconds" value="180"/>

<!-- Tells the SDK to set a job id for batch events' JobScheduler.
Default value: set by the SDK. -->
<preference name="com.blueshift.config.bulk_event_job_id" value="950"/>

<!-- Tells the SDK to set a job id for network change listener's JobScheduler.
Default value: set by the SDK. -->
<preference name="com.blueshift.config.network_change_job_id" value="951"/>

```

### iOS
```xml
<!-- Tells the SDK to enable/disable push notification.
Default value: true -->
<preference name="com.blueshift.config.push_enabled" value="true"/>

<!-- Tells the SDK to enable/disable in-app messages.
Default value: false -->
<preference name="com.blueshift.config.in_app_enabled" value="true"/>

<!-- Set app group id to the SDK. It will be used for carousel push notification
deep link tracking. -->
<preference name="com.blueshift.config.app_group_id" value="group.blueshift.reads"/>

<!-- Tells the SDK to enable/disable the SDK debug logs.
Default value: false -->
<preference name="com.blueshift.config.debug_enabled" value="true"/>

<!-- Tells the SDK to change interval between in-app messages.
Default value: 60 seconds (1 minute) -->
<preference name="com.blueshift.config.in_app_interval_seconds" value="30"/>

<!-- Tells the SDK to enable/disable in-app message background fetch.
Default value: true -->
<preference name="com.blueshift.config.in_app_background_fetch_enabled" value="true"/>

<!-- Tells the SDK to enable/disable in-app message manual mode.
Default value: false -->
<preference name="com.blueshift.config.in_app_manual_mode_enabled" value="false"/>

<!-- Tells the SDK to set a device id source. Supported values are, 
BlueshiftDeviceIdSourceIDFV, BlueshiftDeviceIdSourceUUID, BlueshiftDeviceIdSourceIDFVBundleID.
Default value: BlueshiftDeviceIdSourceIDFV. -->
<preference name="com.blueshift.config.device_id_source" value="BlueshiftDeviceIdSourceUUID"/>

<!-- Tells the SDK to set a custom batch interval.
Default value: 300 seconds (5 minutes). -->
<preference name="com.blueshift.config.batch_interval_seconds" value="60"/>

<!-- Tells the SDK to enable/disable auto app_open events.
Default value: false. -->
<preference name="com.blueshift.config.auto_app_open_enabled" value="true"/>

<!-- Tells the SDK to set an interval between auto app_open events.
Default value: 86400 seconds (24 hours). -->
<preference name="com.blueshift.config.auto_app_open_interval_seconds" value="180"/>

<!-- Tells the SDK to enable/disable the silent push registration.
Default value: true. -->
<preference name="com.blueshift.config.silent_push_enabled" value="false"/>
```

## Calling the plugin’s Js method
Once you integrate the plugin successfully, you can start calling the method provided in the Js module. Below are the set of methods provided out of the box in the plugin.

```JS
/**
* Registers a page for showing in-app message.
*
* @param {string} screenName    Name of the screen.
*/
Blueshift.registerForInAppMessages(screenName);

/**
* Unregisters a page from showing in-app message.
*/
Blueshift.unregisterForInAppMessages();

/**
* Fetches in-app messages from the Blueshift API and provides them in the callbacks.
* 
* @param {function} success    Success callback with the in-app API response.
* @param {function} error      Error callback with an error message.
*/
Blueshift.fetchInAppMessages(success, error);

/**
* Display in-app message if the current page is registered for in-app messages.
*/
Blueshift.displayInAppMessages();

/**
* Send any custom event to Blueshift.
* 
* @param {string} eventName    Name of the custom event.
* @param {object} extras       Additional params (if any).
* @param {boolean} canBatch    Tells if this event can be batched or not.
*/
Blueshift.trackCustomEvent(eventName, extras, canBatch);

/**
* Sends an identify event with the details available.
* 
* @param {object} extras   Additional params (if any)
* @param {string} canBatch Tells if this event can be batched or not.
*/
Blueshift.identify(extras, canBatch);

/**
* Save email in the SDK.
* 
* @param {string} email email of the customer.
*/
Blueshift.setUserInfoEmailID(email);

/**
 * Get email id string set in the SDK.
 *
 * @param {function} success success callback.
 */
Blueshift.getUserInfoEmailID(success);

/**
* Save customerId in the SDK.
* 
* @param {string} customerId customerId of the customer.
*/
Blueshift.setUserInfoCustomerID(customerId);

/**
 * Get customer id string set in the SDK.
 *
 * @param {function} success success callback.
 */
Blueshift.getUserInfoCustomerID(success);

/**
* Save firstname in the SDK.
* 
* @param {string} firstname firstname of the customer.
*/
Blueshift.setUserInfoFirstName(firstname);

/**
 * Get first name string set in the SDK.
 *
 * @param {function} success success callback.
 */
Blueshift.getUserInfoFirstName(success);

/**
* Save lastname in the SDK.
* 
* @param {string} lastname lastname of the customer.
*/
Blueshift.setUserInfoLastName(lastname);

/**
 * Get last name string set in the SDK.
 *
 * @param {function} success success callback.
 */
Blueshift.getUserInfoLastName(success);

/**
* Save additional user info in the SDK.
* 
* @param {object} extras additional user info.
*/
Blueshift.setUserInfoExtras(extras);

/**
 * Get extras JSON data set in the SDK.
 *
 * @param {function} success success callback.
 */
Blueshift.getUserInfoExtras(success);

/**
* Remove all the saved user info from the SDK.
*/
Blueshift.removeUserInfo();

/**
 * Get current device id string used by the SDK.
 *
 * @param {function} success success callback.
 */
Blueshift.getCurrentDeviceId(success);

/**
* Calls Blueshift's live content API with email and given slot name and live content context.
* 
* @param {string} slot slot name of the live content.
* @param {object} lcContext live content context.
* @param {function} success success callback.
* @param {function} error error callback.
*/
Blueshift.getLiveContentByEmail(slot, lcContext, success, error);

/**
* Calls Blueshift's live content API with customer id and given slot name and live content context.
* 
* @param {string} slot slot name of the live content.
* @param {object} lcContext live content context.
* @param {function} success success callback.
* @param {function} error error callback.
*/
Blueshift.getLiveContentByCustomerID(slot, lcContext, success, error);

/**
* Calls Blueshift's live content API with device id and given slot name and live content context.
* 
* @param {string} slot slot name of the live content.
* @param {object} lcContext live content context.
* @param {function} success success callback.
* @param {function} error error callback.
*/
Blueshift.getLiveContentByDeviceID(slot, lcContext, success, error);

/**
 * Enable/disable SDK's event tracking.
 * 
 * @param {boolean} enabled When true, tracking is enabled. When false, disabled.
 */
Blueshift.enableTracking(enabled);

/**
 * Enable/disable SDK's event tracking.
 * 
 * @param {boolean} enabled When true, tracking is enabled. When false, disabled.
 * @param {boolean} wipeData When true, events will be wiped. When false, nothing happens.
 */
Blueshift.enableTracking(enabled, wipeData);

/**
 * Get status of event tracking set in the SDK.
 *
 * @param {function} success success callback.
 */
Blueshift.getEnableTrackingStatus(success);

/**
 * Opt-in or opt-out of push notifications sent from Blueshift.
 * 
 * @param {boolean} enabled When true, opt-in else opt-out.
 */
Blueshift.enablePush(enabled);

/**
 * Get opt-in or opt-out status of push notifications set in the SDK.
 *
 * @param {function} success success callback.
 */
Blueshift.getEnablePushStatus(success);

/**
 * Opt-in or opt-out of in-app notifications sent from Blueshift.
 * 
 * @param {boolean} enabled When true, opt-in else opt-out.
 */
Blueshift.enableInApp(enabled);

/**
 * Get opt-in or opt-out status of in-app notifications set in the SDK.
 *
 * @param {function} success success callback.
 */
Blueshift.getEnableInAppStatus(success);

/**
 * Register for remote notifications using SDK. Calling this method will show push permission dialogue to the user.
 * Note - This is only applicable for the iOS devices.
 */
Blueshift.registerForRemoteNotification(); 

/**
 * Set current location of the device in the Blueshift SDK.
 * Note - This is only applicable for the iOS devices.
 *
 * @param {double} latitude location latitude value.
 * @param {double} longitude location longitude value.
 */
Blueshift.setCurrentLocation(latitude, longitude);

```

### Deep link callbacks - 
Set up event listeners to listen to the deep link events triggered by Blueshift plugin. Once deep link is received, you can perform some business logic to navigate to desired screen.

-- `OnBlueshiftDeepLinkReplayStart` - Universal links are shortened links and requires replaying in order to get the original URL. This event will be fired when the replaying of the URL beigns. (Applicable to only universal links)
- `OnBlueshiftDeepLinkSuccess` - Push, in-app and universal link deep links will be triggered under this event name.
- `OnBlueshiftDeepLinkReplayFail` - This event will be fired when the URL replay fails due to some error. (Applicable to only universal links)

```JS
document.addEventListener('OnBlueshiftDeepLinkReplayStart', function(e) {
    showLoader();
});

document.addEventListener('OnBlueshiftDeepLinkSuccess',  function(e){
    hideLoader();
    alert("Deep link - "+e.deepLink);
  });
  
document.addEventListener('OnBlueshiftDeepLinkReplayFail',  function(e){
    hideLoader();
    alert("Deep link - "+e.deepLink);
  });

```

