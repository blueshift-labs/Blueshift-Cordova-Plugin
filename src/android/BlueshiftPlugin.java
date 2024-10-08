package com.blueshift.cordova;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import com.blueshift.Blueshift;
import com.blueshift.BlueshiftAppPreferences;
import com.blueshift.BlueshiftConstants;
import com.blueshift.BlueshiftLinksHandler;
import com.blueshift.BlueshiftLinksListener;
import com.blueshift.BlueshiftLogger;
import com.blueshift.BlueshiftRegion;
import com.blueshift.BuildConfig;
import com.blueshift.inappmessage.InAppApiCallback;
import com.blueshift.model.Configuration;
import com.blueshift.model.UserInfo;
import com.blueshift.rich_push.RichPushConstants;
import com.blueshift.util.DeviceUtils;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/**
 * This class echoes a string called from JavaScript.
 */
public class BlueshiftPlugin extends CordovaPlugin {
    private static final String TAG = "BlueshiftPlugin";

    /**
     * The below keys can be used for specifying the config values in the form of preferences.
     * <p>
     * Ex:
     * <preference name="com.blueshift.config.in_app_enabled" value="true"/>
     */
    private static final String BLUESHIFT_PREF_API_KEY = "com.blueshift.config.event_api_key";
    private static final String BLUESHIFT_PREF_APP_ICON = "com.blueshift.config.app_icon";
    private static final String BLUESHIFT_PREF_PUSH_ENABLED = "com.blueshift.config.push_enabled";
    private static final String BLUESHIFT_PREF_IN_APP_ENABLED = "com.blueshift.config.in_app_enabled";
    private static final String BLUESHIFT_PREF_IN_APP_JS_ENABLED = "com.blueshift.config.in_app_javascript_enabled";
    private static final String BLUESHIFT_PREF_IN_APP_INTERVAL = "com.blueshift.config.in_app_interval_seconds";
    private static final String BLUESHIFT_PREF_IN_APP_BACKGROUND_FETCH_ENABLED = "com.blueshift.config.in_app_background_fetch_enabled";
    private static final String BLUESHIFT_PREF_IN_APP_MANUAL_MODE_ENABLED = "com.blueshift.config.in_app_manual_mode_enabled";
    private static final String BLUESHIFT_PREF_NOTIFICATION_COLOR = "com.blueshift.config.notification_color";
    private static final String BLUESHIFT_PREF_NOTIFICATION_ICON_SMALL = "com.blueshift.config.notification_icon_small";
    private static final String BLUESHIFT_PREF_NOTIFICATION_ICON_LARGE = "com.blueshift.config.notification_icon_large";
    private static final String BLUESHIFT_PREF_NOTIFICATION_CHANNEL_ID = "com.blueshift.config.notification_channel_id";
    private static final String BLUESHIFT_PREF_NOTIFICATION_CHANNEL_NAME = "com.blueshift.config.notification_channel_name";
    private static final String BLUESHIFT_PREF_NOTIFICATION_CHANNEL_DESCRIPTION = "com.blueshift.config.notification_channel_description";
    private static final String BLUESHIFT_PREF_DEVICE_ID_SOURCE = "com.blueshift.config.device_id_source";
    private static final String BLUESHIFT_PREF_DEVICE_ID_CUSTOM_VALUE = "com.blueshift.config.device_id_custom_value";
    private static final String BLUESHIFT_PREF_BATCH_INTERVAL_SECONDS = "com.blueshift.config.batch_interval_seconds";
    private static final String BLUESHIFT_PREF_AUTO_APP_OPEN_ENABLED = "com.blueshift.config.auto_app_open_enabled";
    private static final String BLUESHIFT_PREF_AUTO_APP_OPEN_INTERVAL_SECONDS = "com.blueshift.config.auto_app_open_interval_seconds";
    private static final String BLUESHIFT_PREF_BULK_EVENT_JOB_ID = "com.blueshift.config.bulk_event_job_id";
    private static final String BLUESHIFT_PREF_NETWORK_CHANGE_JOB_ID = "com.blueshift.config.network_change_job_id";
    private static final String BLUESHIFT_PREF_LOGGING_ENABLED = "com.blueshift.config.debug_logs_enabled";
    private static final String BLUESHIFT_PREF_REGION = "com.blueshift.config.region";
    private static final String BLUESHIFT_PREF_USER_INFO_ENCRYPTION_ENABLED = "com.blueshift.config.user_info_encryption_enabled";

    // JS Event Names for DeepLink
    private static final String ON_BLUESHIFT_DEEP_LINK_REPLAY_START = "OnBlueshiftDeepLinkReplayStart";
    private static final String ON_BLUESHIFT_DEEP_LINK_REPLAY_SUCCESS = "OnBlueshiftDeepLinkSuccess";
    private static final String ON_BLUESHIFT_DEEP_LINK_REPLAY_FAIL = "OnBlueshiftDeepLinkReplayFail";

    // JS Event Params for DeepLink
    private static final String DEEP_LINK = "deepLink";
    private static final String ERROR = "error";

    // TODO: 18/08/22 Change this on each plugin release
    private static final String CDV_PLUGIN_VERSION = "0.1.0";

    private Context mAppContext = null;
    private Blueshift mBlueshift = null;
    private boolean mLoggingEnabled = false;

    private int getColorResourceId(String colorName) {
        return getResourceIdFromString(colorName, "color");
    }

    private int getDrawableResourceId(String drawableName) {
        return getResourceIdFromString(drawableName, "drawable");
    }

    private int getResourceIdFromString(String variableName, String resourceName) {
        return mAppContext.getResources().getIdentifier(
                variableName,
                resourceName,
                mAppContext.getPackageName());
    }

    private String documentEventJs(String event, String json) {
        log("fireDocumentEvent: event_name: " + event + ", extra_json:" + json);
        return "javascript:cordova.fireDocumentEvent('" + event + "'," + json + ");";
    }

    private void dispatchDeepLinkReplayStartEvent(CordovaWebView webView) {
        if (webView != null) {
            String jsCode = documentEventJs(ON_BLUESHIFT_DEEP_LINK_REPLAY_START, "{}");
            webView.getView().post(() -> webView.loadUrl(jsCode));
        }
    }

    private void dispatchDeepLinkReplaySuccessEvent(String deeplink, CordovaWebView webView) {
        if (webView != null) {
            String json = "{'" + DEEP_LINK + "':'" + deeplink + "'}";
            String jsCode = documentEventJs(ON_BLUESHIFT_DEEP_LINK_REPLAY_SUCCESS, json);
            webView.getView().post(() -> webView.loadUrl(jsCode));
        }
    }

    private void dispatchDeepLinkReplayFailEvent(String deeplink, String error, CordovaWebView webView) {
        if (webView != null) {
            String json = "{'" + DEEP_LINK + "':'" + deeplink + "', '" + ERROR + "':'" + error + "'}";
            String jsCode = documentEventJs(ON_BLUESHIFT_DEEP_LINK_REPLAY_FAIL, json);
            webView.getView().post(() -> webView.loadUrl(jsCode));
        }
    }

    private boolean handleBlueshiftPushDeepLinks(Activity activity, CordovaWebView appView) {
        if (activity != null && activity.getIntent() != null && appView != null) {
            Bundle bundle = activity.getIntent().getExtras();
            if (bundle != null) {
                String deeplink = bundle.getString(RichPushConstants.EXTRA_DEEP_LINK_URL, null);
                if (deeplink != null) {
                    dispatchDeepLinkReplaySuccessEvent(deeplink, appView);
                    return true;
                }
            }
        }

        return false;
    }

    private void handleDeepLinks(Intent intent) {
        if (intent != null) {
            new BlueshiftLinksHandler(mAppContext).handleBlueshiftUniversalLinks(
                    intent.getData(),
                    intent.getExtras(),
                    new BlueshiftLinksListener() {
                        @Override
                        public void onLinkProcessingStart() {
                            dispatchDeepLinkReplayStartEvent(webView);
                        }

                        @Override
                        public void onLinkProcessingComplete(Uri uri) {
                            String link = uri != null ? uri.toString() : null;
                            dispatchDeepLinkReplaySuccessEvent(link, webView);
                        }

                        @Override
                        public void onLinkProcessingError(Exception e, Uri uri) {
                            String link = uri != null ? uri.toString() : null;
                            String error = e != null ? e.getMessage() : null;
                            dispatchDeepLinkReplayFailEvent(link, error, webView);
                        }
                    });
        }
    }

    @Override
    public void onNewIntent(Intent intent) {
        if (intent == null) return;

        if (Intent.ACTION_VIEW.equals(intent.getAction())) {
            handleDeepLinks(intent);
        }
    }

    @Override
    protected void pluginInitialize() {
        mAppContext = this.cordova.getContext().getApplicationContext();

        mBlueshift = Blueshift.getInstance(mAppContext);

        setLoggingStatus();

        initBlueshiftWithConfig();

        Activity cdvActivity = this.cordova.getActivity();

        // check for the Blueshift deep links coming from push click
        boolean isPushDLAvailable = handleBlueshiftPushDeepLinks(cdvActivity, this.webView);

        if (!isPushDLAvailable) {
            // check and process any deep link available inside the intent other than push deeplink
            handleDeepLinks(cdvActivity != null ? cdvActivity.getIntent() : null);
        }
    }

    private void initBlueshiftWithConfig() {
        Configuration config = new Configuration();

        setApiKey(config);
        setBlueshiftRegion(config);
        setAppIcon(config);
        setPushEnabled(config);
        setInAppEnabled(config);
        setInAppJavascriptEnabled(config);
        setInAppInterval(config);
        setInAppBackgroundFetchEnabled(config);
        setInAppManualModeEnabled(config);
        setNotificationColor(config);
        setNotificationIconSmall(config);
        setNotificationIconLarge(config);
        setNotificationChannelId(config);
        setNotificationChannelName(config);
        setNotificationChannelDescription(config);
        setDeviceIdSource(config);
        setDeviceIdCustomValue(config);
        setBatchInterval(config);
        setAutoAppOpenEnabled(config);
        setAutoAppOpenInterval(config);
        setBulkEventJobId(config);
        setNetworkChangeJobId(config);
        setUserInfoEncryptionEnabled(config);

        mBlueshift.initialize(config);
    }

    private void logMissingPreference(String key) {
        log("Preference missing\t{ key: " + key + " }");
    }

    private void logPreferenceValue(String key, Object value) {
        log("Preference available\t{ key: " + key + ", value: " + value + " }");
    }

    private void setApiKey(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_API_KEY)) {
            String apiKey = this.preferences.getString(BLUESHIFT_PREF_API_KEY, null);
            if (apiKey != null) configuration.setApiKey(apiKey);

            logPreferenceValue(BLUESHIFT_PREF_API_KEY, apiKey);
        } else {
            logMissingPreference(BLUESHIFT_PREF_API_KEY);
        }
    }

    private void setAppIcon(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_APP_ICON)) {
            String drawableName = this.preferences.getString(BLUESHIFT_PREF_APP_ICON, null);
            if (drawableName != null) configuration.setAppIcon(getDrawableResourceId(drawableName));

            logPreferenceValue(BLUESHIFT_PREF_APP_ICON, drawableName);
        } else {
            logMissingPreference(BLUESHIFT_PREF_APP_ICON);
        }
    }

    private void setPushEnabled(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_PUSH_ENABLED)) {
            boolean isEnabled = this.preferences.getBoolean(BLUESHIFT_PREF_PUSH_ENABLED, true);
            configuration.setPushEnabled(isEnabled);

            logPreferenceValue(BLUESHIFT_PREF_PUSH_ENABLED, isEnabled);
        } else {
            logMissingPreference(BLUESHIFT_PREF_PUSH_ENABLED);
        }
    }

    private void setInAppEnabled(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_IN_APP_ENABLED)) {
            boolean isEnabled = this.preferences.getBoolean(BLUESHIFT_PREF_IN_APP_ENABLED, false);
            configuration.setInAppEnabled(isEnabled);

            logPreferenceValue(BLUESHIFT_PREF_IN_APP_ENABLED, isEnabled);
        } else {
            logMissingPreference(BLUESHIFT_PREF_IN_APP_ENABLED);
        }
    }

    private void setInAppJavascriptEnabled(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_IN_APP_JS_ENABLED)) {
            boolean isEnabled = this.preferences.getBoolean(BLUESHIFT_PREF_IN_APP_JS_ENABLED, false);
            configuration.setJavaScriptForInAppWebViewEnabled(isEnabled);

            logPreferenceValue(BLUESHIFT_PREF_IN_APP_JS_ENABLED, isEnabled);
        } else {
            logMissingPreference(BLUESHIFT_PREF_IN_APP_JS_ENABLED);
        }
    }

    private void setInAppInterval(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_IN_APP_INTERVAL)) {
            int interval = this.preferences.getInteger(BLUESHIFT_PREF_IN_APP_INTERVAL, -1);
            if (interval >= 0) configuration.setInAppInterval(interval);

            logPreferenceValue(BLUESHIFT_PREF_IN_APP_INTERVAL, interval);
        } else {
            logMissingPreference(BLUESHIFT_PREF_IN_APP_INTERVAL);
        }
    }

    private void setInAppBackgroundFetchEnabled(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_IN_APP_BACKGROUND_FETCH_ENABLED)) {
            boolean isEnabled = this.preferences.getBoolean(BLUESHIFT_PREF_IN_APP_BACKGROUND_FETCH_ENABLED, true);
            configuration.setInAppBackgroundFetchEnabled(isEnabled);

            logPreferenceValue(BLUESHIFT_PREF_IN_APP_BACKGROUND_FETCH_ENABLED, isEnabled);
        } else {
            logMissingPreference(BLUESHIFT_PREF_IN_APP_BACKGROUND_FETCH_ENABLED);
        }
    }

    private void setInAppManualModeEnabled(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_IN_APP_MANUAL_MODE_ENABLED)) {
            boolean isEnabled = this.preferences.getBoolean(BLUESHIFT_PREF_IN_APP_MANUAL_MODE_ENABLED, false);
            configuration.setInAppManualTriggerEnabled(isEnabled);

            logPreferenceValue(BLUESHIFT_PREF_IN_APP_MANUAL_MODE_ENABLED, isEnabled);
        } else {
            logMissingPreference(BLUESHIFT_PREF_IN_APP_MANUAL_MODE_ENABLED);
        }
    }

    private void setNotificationColor(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_NOTIFICATION_COLOR)) {
            String colorName = this.preferences.getString(BLUESHIFT_PREF_NOTIFICATION_COLOR, null);
            if (colorName != null) {
                try {
                    int colorResId = getColorResourceId(colorName);
                    int colorValue = mAppContext.getResources().getColor(colorResId);
                    configuration.setNotificationColor(colorValue);
                } catch (Exception e) {
                    if (e != null) log(e.getMessage());
                }
            }

            logPreferenceValue(BLUESHIFT_PREF_NOTIFICATION_COLOR, colorName);
        } else {
            logMissingPreference(BLUESHIFT_PREF_NOTIFICATION_COLOR);
        }
    }

    private void setNotificationIconSmall(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_NOTIFICATION_ICON_SMALL)) {
            String drawableName = this.preferences.getString(BLUESHIFT_PREF_NOTIFICATION_ICON_SMALL, null);
            if (drawableName != null)
                configuration.setSmallIconResId(getDrawableResourceId(drawableName));

            logPreferenceValue(BLUESHIFT_PREF_NOTIFICATION_ICON_SMALL, drawableName);
        } else {
            logMissingPreference(BLUESHIFT_PREF_NOTIFICATION_ICON_SMALL);
        }
    }

    private void setNotificationIconLarge(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_NOTIFICATION_ICON_LARGE)) {
            String drawableName = this.preferences.getString(BLUESHIFT_PREF_NOTIFICATION_ICON_LARGE, null);
            if (drawableName != null)
                configuration.setLargeIconResId(getDrawableResourceId(drawableName));

            logPreferenceValue(BLUESHIFT_PREF_NOTIFICATION_ICON_LARGE, drawableName);
        } else {
            logMissingPreference(BLUESHIFT_PREF_NOTIFICATION_ICON_LARGE);
        }
    }

    private void setNotificationChannelId(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_NOTIFICATION_CHANNEL_ID)) {
            String channelId = this.preferences.getString(BLUESHIFT_PREF_NOTIFICATION_CHANNEL_ID, null);
            if (channelId != null) configuration.setDefaultNotificationChannelId(channelId);

            logPreferenceValue(BLUESHIFT_PREF_NOTIFICATION_CHANNEL_ID, channelId);
        } else {
            logMissingPreference(BLUESHIFT_PREF_NOTIFICATION_CHANNEL_ID);
        }
    }

    private void setNotificationChannelName(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_NOTIFICATION_CHANNEL_NAME)) {
            String channelName = this.preferences.getString(BLUESHIFT_PREF_NOTIFICATION_CHANNEL_NAME, null);
            if (channelName != null) configuration.setDefaultNotificationChannelName(channelName);

            logPreferenceValue(BLUESHIFT_PREF_NOTIFICATION_CHANNEL_NAME, channelName);
        } else {
            logMissingPreference(BLUESHIFT_PREF_NOTIFICATION_CHANNEL_NAME);
        }
    }

    private void setNotificationChannelDescription(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_NOTIFICATION_CHANNEL_DESCRIPTION)) {
            String channelDescription = this.preferences.getString(BLUESHIFT_PREF_NOTIFICATION_CHANNEL_DESCRIPTION, null);
            if (channelDescription != null)
                configuration.setDefaultNotificationChannelName(channelDescription);

            logPreferenceValue(BLUESHIFT_PREF_NOTIFICATION_CHANNEL_DESCRIPTION, channelDescription);
        } else {
            logMissingPreference(BLUESHIFT_PREF_NOTIFICATION_CHANNEL_DESCRIPTION);
        }
    }

    private void setDeviceIdSource(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_DEVICE_ID_SOURCE)) {
            String deviceIdSource = this.preferences.getString(BLUESHIFT_PREF_DEVICE_ID_SOURCE, null);
            if (deviceIdSource != null) {
                Blueshift.DeviceIdSource source = null;
                try {
                    source = Blueshift.DeviceIdSource.valueOf(deviceIdSource);
                } catch (Exception e) {
                    log("Invalid device id source provided: " + deviceIdSource);
                }

                if (source != null) {
                    configuration.setDeviceIdSource(source);
                }
            }

            logPreferenceValue(BLUESHIFT_PREF_DEVICE_ID_SOURCE, deviceIdSource);
        } else {
            logMissingPreference(BLUESHIFT_PREF_DEVICE_ID_SOURCE);
        }
    }

    private void setDeviceIdCustomValue(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_DEVICE_ID_CUSTOM_VALUE)) {
            String deviceId = this.preferences.getString(BLUESHIFT_PREF_DEVICE_ID_CUSTOM_VALUE, null);
            if (deviceId != null) configuration.setCustomDeviceId(deviceId);

            logPreferenceValue(BLUESHIFT_PREF_DEVICE_ID_CUSTOM_VALUE, deviceId);
        } else {
            logMissingPreference(BLUESHIFT_PREF_DEVICE_ID_CUSTOM_VALUE);
        }
    }

    private void setBatchInterval(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_BATCH_INTERVAL_SECONDS)) {
            int interval = this.preferences.getInteger(BLUESHIFT_PREF_BATCH_INTERVAL_SECONDS, -1);
            if (interval >= 0) configuration.setBatchInterval(interval * 1000);

            logPreferenceValue(BLUESHIFT_PREF_BATCH_INTERVAL_SECONDS, interval);
        } else {
            logMissingPreference(BLUESHIFT_PREF_BATCH_INTERVAL_SECONDS);
        }
    }

    private void setAutoAppOpenEnabled(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_AUTO_APP_OPEN_ENABLED)) {
            boolean isEnabled = this.preferences.getBoolean(BLUESHIFT_PREF_AUTO_APP_OPEN_ENABLED, false);
            configuration.setEnableAutoAppOpenFiring(isEnabled);

            logPreferenceValue(BLUESHIFT_PREF_AUTO_APP_OPEN_ENABLED, isEnabled);
        } else {
            logMissingPreference(BLUESHIFT_PREF_AUTO_APP_OPEN_ENABLED);
        }
    }

    private void setAutoAppOpenInterval(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_AUTO_APP_OPEN_INTERVAL_SECONDS)) {
            int interval = this.preferences.getInteger(BLUESHIFT_PREF_AUTO_APP_OPEN_INTERVAL_SECONDS, -1);
            if (interval >= 0) configuration.setAutoAppOpenInterval(interval);

            logPreferenceValue(BLUESHIFT_PREF_AUTO_APP_OPEN_INTERVAL_SECONDS, interval);
        } else {
            logMissingPreference(BLUESHIFT_PREF_AUTO_APP_OPEN_INTERVAL_SECONDS);
        }
    }

    private void setBulkEventJobId(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_BULK_EVENT_JOB_ID)) {
            int jobId = this.preferences.getInteger(BLUESHIFT_PREF_BULK_EVENT_JOB_ID, -1);
            if (jobId >= 0) configuration.setBulkEventsJobId(jobId);

            logPreferenceValue(BLUESHIFT_PREF_BULK_EVENT_JOB_ID, jobId);
        } else {
            logMissingPreference(BLUESHIFT_PREF_BULK_EVENT_JOB_ID);
        }
    }

    private void setNetworkChangeJobId(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_NETWORK_CHANGE_JOB_ID)) {
            int jobId = this.preferences.getInteger(BLUESHIFT_PREF_NETWORK_CHANGE_JOB_ID, -1);
            if (jobId >= 0) configuration.setNetworkChangeListenerJobId(jobId);

            logPreferenceValue(BLUESHIFT_PREF_NETWORK_CHANGE_JOB_ID, jobId);
        } else {
            logMissingPreference(BLUESHIFT_PREF_NETWORK_CHANGE_JOB_ID);
        }
    }

    private void setUserInfoEncryptionEnabled(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_USER_INFO_ENCRYPTION_ENABLED)) {
            boolean status = this.preferences.getBoolean(BLUESHIFT_PREF_USER_INFO_ENCRYPTION_ENABLED, false);
            configuration.setSaveUserInfoAsEncrypted(status);

            logPreferenceValue(BLUESHIFT_PREF_USER_INFO_ENCRYPTION_ENABLED, status);
        } else {
            logMissingPreference(BLUESHIFT_PREF_USER_INFO_ENCRYPTION_ENABLED);
        }
    }

    private void setBlueshiftRegion(Configuration configuration) {
        if (this.preferences.contains(BLUESHIFT_PREF_REGION)) {
            String region = this.preferences.getString(BLUESHIFT_PREF_REGION, "US");
            if (region != null) {
                if (region.isEmpty()) {
                    log("Empty region name provided. Using the default value: US.");
                } else {
                    try {
                        BlueshiftRegion bsftRegion = BlueshiftRegion.valueOf(region);
                        configuration.setRegion(bsftRegion);
                    } catch (Exception e) {
                        log("Invalid region name provided: " + region + ". Supported values are: US, EU.");
                    }
                }
            }

            logPreferenceValue(BLUESHIFT_PREF_REGION, region);
        } else {
            logMissingPreference(BLUESHIFT_PREF_REGION);
        }
    }

    private void setLoggingStatus() {
        if (this.preferences.contains(BLUESHIFT_PREF_LOGGING_ENABLED)) {
            mLoggingEnabled = this.preferences.getBoolean(BLUESHIFT_PREF_LOGGING_ENABLED, false);
            if (mLoggingEnabled) BlueshiftLogger.setLogLevel(BlueshiftLogger.VERBOSE);

            logPreferenceValue(BLUESHIFT_PREF_LOGGING_ENABLED, mLoggingEnabled);
        } else {
            logMissingPreference(BLUESHIFT_PREF_LOGGING_ENABLED);
        }
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action != null) {
            switch (action) {
                // IN-APP
                case "registerForInAppMessages":
                    return registerForInAppMessages(args);
                case "unregisterForInAppMessages":
                    return unregisterForInAppMessages();
                case "fetchInAppMessages":
                    return fetchInAppMessages(callbackContext);
                case "displayInAppMessages":
                    return displayInAppMessages();

                // EVENTS
                case "trackCustomEvent":
                    return trackCustomEvent(args);
                case "identify":
                    return identify(args);

                // USER INFO SETTERS
                case "setUserInfoEmailID":
                    return setUserInfoEmailID(args);
                case "setUserInfoCustomerID":
                    return setUserInfoCustomerID(args);
                case "setUserInfoFirstName":
                    return setUserInfoFirstName(args);
                case "setUserInfoLastName":
                    return setUserInfoLastName(args);
                case "setUserInfoExtras":
                    return setUserInfoExtras(args);
                case "removeUserInfo":
                    return removeUserInfo();

                // LIVE CONTENT
                case "getLiveContentByEmail":
                    return getLiveContentByEmail(args, callbackContext);
                case "getLiveContentByCustomerID":
                    return getLiveContentByCustomerID(args, callbackContext);
                case "getLiveContentByDeviceID":
                    return getLiveContentByDeviceID(args, callbackContext);

                // OPT IN/OUT SETTERS
                case "enableTracking":
                    return enableTracking(args);
                case "enablePush":
                    return enablePush(args);
                case "enableInApp":
                    return enableInApp(args);

                // USER INFO GETTERS
                case "getUserInfoEmailID":
                    return getUserInfoEmailID(callbackContext);
                case "getUserInfoCustomerID":
                    return getUserInfoCustomerID(callbackContext);
                case "getUserInfoFirstName":
                    return getUserInfoFirstName(callbackContext);
                case "getUserInfoLastName":
                    return getUserInfoLastName(callbackContext);
                case "getUserInfoExtras":
                    return getUserInfoExtras(callbackContext);

                // OPT IN/OUT GETTERS
                case "getEnableInAppStatus":
                    return getEnableInAppStatus(callbackContext);
                case "getEnablePushStatus":
                    return getEnablePushStatus(callbackContext);
                case "getEnableTrackingStatus":
                    return getEnableTrackingStatus(callbackContext);

                // DEVICE ID
                case "getCurrentDeviceId":
                    return getCurrentDeviceId(callbackContext);
                case "resetDeviceId":
                    return resetDeviceId();

                // PUSH
                case "registerForRemoteNotification":
                    return requestPushNotificationPermission();

                default:
                    log("Unknown action. " + action);
            }
        }

        return false;
    }

    private boolean getUserInfoEmailID(CallbackContext callbackContext) {
        if (callbackContext != null) {
            UserInfo userInfo = UserInfo.getInstance(mAppContext);
            String email = userInfo != null ? userInfo.getEmail() : "";
            callbackContext.success(email);

            log("getUserInfoEmailID: " + email);
        }

        return true;
    }

    private boolean getUserInfoCustomerID(CallbackContext callbackContext) {
        if (callbackContext != null) {
            UserInfo userInfo = UserInfo.getInstance(mAppContext);
            String customerId = userInfo != null ? userInfo.getRetailerCustomerId() : "";
            callbackContext.success(customerId);

            log("getUserInfoCustomerID: " + customerId);
        }

        return true;
    }

    private boolean getUserInfoFirstName(CallbackContext callbackContext) {
        if (callbackContext != null) {
            UserInfo userInfo = UserInfo.getInstance(mAppContext);
            String firstName = userInfo != null ? userInfo.getFirstname() : "";
            callbackContext.success(firstName);

            log("getUserInfoFirstName: " + firstName);
        }

        return true;
    }

    private boolean getUserInfoLastName(CallbackContext callbackContext) {
        if (callbackContext != null) {
            UserInfo userInfo = UserInfo.getInstance(mAppContext);
            String lastName = userInfo != null ? userInfo.getLastname() : "";
            callbackContext.success(lastName);

            log("getUserInfoLastName: " + lastName);
        }

        return true;
    }


    private boolean getUserInfoExtras(CallbackContext callbackContext) {
        if (callbackContext != null) {
            UserInfo userInfo = UserInfo.getInstance(mAppContext);
            if (userInfo != null) {
                HashMap<String, Object> extraMap = userInfo.getDetails();
                JSONObject jsonObject = getJSONObject(extraMap);
                callbackContext.success(jsonObject);

                log("getUserInfoExtras: " + jsonObject.toString());
            } else {
                callbackContext.success(new JSONObject());

                log("getUserInfoExtras: {}");
            }
        }

        return true;
    }

    private boolean getEnableInAppStatus(CallbackContext callbackContext) {
        if (callbackContext != null) {
            boolean isEnabled = BlueshiftAppPreferences.getInstance(mAppContext).getEnableInApp();
            callbackContext.success(isEnabled ? 1 : 0);

            log("getEnableInAppStatus: " + isEnabled);
        }

        return true;
    }

    private boolean getEnablePushStatus(CallbackContext callbackContext) {
        if (callbackContext != null) {
            boolean isEnabled = BlueshiftAppPreferences.getInstance(mAppContext).getEnablePush();
            callbackContext.success(isEnabled ? 1 : 0);

            log("getEnablePushStatus: " + isEnabled);
        }

        return true;
    }

    private boolean getEnableTrackingStatus(CallbackContext callbackContext) {
        if (callbackContext != null) {
            boolean isEnabled = Blueshift.isTrackingEnabled(mAppContext);
            callbackContext.success(isEnabled ? 1 : 0);

            log("getEnableTrackingStatus: " + isEnabled);
        }

        return true;
    }

    private boolean getCurrentDeviceId(CallbackContext callbackContext) {
        if (callbackContext != null) {
            String deviceId = DeviceUtils.getDeviceId(mAppContext);
            callbackContext.success(deviceId);

            log("getCurrentDeviceId: " + deviceId);
        }

        return true;
    }

    private boolean resetDeviceId() {
        log("resetDeviceId: ");

        Blueshift.resetDeviceId(mAppContext);

        return true;
    }

    private boolean registerForInAppMessages(JSONArray args) throws JSONException {
        String screenName = args.getString(0);
        mBlueshift.registerForInAppMessages(cordova.getActivity(), screenName);
        log("registerForInAppMessages: { \"screenName\" : \"" + screenName + "\"}");

        return true;
    }

    private boolean unregisterForInAppMessages() {
        log("unregisterForInAppMessages: ");

        mBlueshift.unregisterForInAppMessages(cordova.getActivity());

        return true;
    }

    private boolean fetchInAppMessages(CallbackContext callbackContext) {
        log("fetchInAppMessages: ");

        mBlueshift.fetchInAppMessages(new InAppApiCallback() {
            @Override
            public void onSuccess() {
                callbackContext.success();
            }

            @Override
            public void onFailure(int i, String s) {
                callbackContext.error(s);
            }
        });

        return true;
    }

    private boolean displayInAppMessages() {
        log("displayInAppMessages: ");

        mBlueshift.displayInAppMessages();

        return true;
    }

    private JSONObject appendVersion(JSONObject jsonObject) {
        if (jsonObject == null) jsonObject = new JSONObject();
        String version = BuildConfig.SDK_VERSION + "-CD-" + CDV_PLUGIN_VERSION;
        try {
            jsonObject.put(BlueshiftConstants.KEY_SDK_VERSION, version);
        } catch (JSONException ignore) {
        }

        return jsonObject;
    }

    private boolean trackCustomEvent(JSONArray args) throws JSONException {
        String eventName = args.getString(0);
        JSONObject extras = appendVersion(getJSONObject(args, 1));
        boolean canBatch = args.getBoolean(2);

        log("trackCustomEvent: {\"event\":\"" + eventName + "\", \"extras\": " + extras + ", \"canBatch\": " + canBatch + "}");

        mBlueshift.trackEvent(eventName, getMap(extras), canBatch);

        return true;
    }

    private boolean identify(JSONArray args) throws JSONException {
        String eventName = "identify";
        JSONObject extras = appendVersion(getJSONObject(args, 0));
        boolean canBatch = args.getBoolean(1);

        HashMap<String, Object> additionalArgs = new HashMap<>();

        HashMap<String, Object> extrasMap = getMap(extras);
        if (extrasMap != null) additionalArgs.putAll(extrasMap);

        UserInfo user = UserInfo.getInstance(mAppContext);
        HashMap<String, Object> userMap = user != null ? user.toHashMap() : null;
        if (userMap != null) additionalArgs.putAll(userMap);

        log("identify: {\"event\":\"" + eventName + "\", \"extras\": " + additionalArgs + ", \"canBatch\": " + canBatch + "}");

        mBlueshift.trackEvent(eventName, additionalArgs, canBatch);

        return true;
    }

    private boolean setUserInfoEmailID(JSONArray args) throws JSONException {
        String email = args.getString(0);

        log("setUserInfoEmailID: " + email);

        UserInfo userInfo = UserInfo.getInstance(cordova.getContext());
        if (userInfo != null) {
            userInfo.setEmail(email);
            userInfo.save(cordova.getContext());
        }

        return true;
    }

    private boolean setUserInfoCustomerID(JSONArray args) throws JSONException {
        String customerID = args.getString(0);

        log("setUserInfoCustomerID: " + customerID);

        UserInfo userInfo = UserInfo.getInstance(cordova.getContext());
        if (userInfo != null) {
            userInfo.setRetailerCustomerId(customerID);
            userInfo.save(cordova.getContext());
        }

        return true;
    }

    private boolean setUserInfoFirstName(JSONArray args) throws JSONException {
        String firstName = args.getString(0);

        log("setUserInfoFirstName: " + firstName);

        UserInfo userInfo = UserInfo.getInstance(cordova.getContext());
        if (userInfo != null) {
            userInfo.setFirstname(firstName);
            userInfo.save(cordova.getContext());
        }

        return true;
    }

    private boolean setUserInfoLastName(JSONArray args) throws JSONException {
        String lastName = args.getString(0);

        log("setUserInfoLastName: " + lastName);

        UserInfo userInfo = UserInfo.getInstance(cordova.getContext());
        if (userInfo != null) {
            userInfo.setLastname(lastName);
            userInfo.save(cordova.getContext());
        }

        return true;
    }

    private boolean setUserInfoExtras(JSONArray args) {
        JSONObject extras = getJSONObject(args, 0);

        log("setUserInfoExtras: " + extras);

        cordova.getThreadPool().submit(() -> {
            UserInfo userInfo = UserInfo.getInstance(cordova.getContext());
            if (userInfo != null) {
                userInfo.setDetails(getMap(extras));
                userInfo.save(cordova.getContext());
            }
        });

        return true;
    }

    private boolean removeUserInfo() {
        log("removeUserInfo: ");

        cordova.getThreadPool().submit(() -> {
            UserInfo userInfo = UserInfo.getInstance(cordova.getContext());
            if (userInfo != null) userInfo.clear(cordova.getContext());
        });

        return true;
    }

    private boolean getLiveContentByEmail(JSONArray args, CallbackContext callbackContext) throws JSONException {
        String slotName = args.getString(0);
        JSONObject liveContentContext = getJSONObject(args, 1);

        log("getLiveContentByEmail: {\"slot\":\"" + slotName + "\", \"live_context\":" + liveContentContext + "}");

        mBlueshift.getLiveContentByEmail(slotName, getMap(liveContentContext), callbackContext::success);

        return true;
    }

    private boolean getLiveContentByCustomerID(JSONArray args, CallbackContext callbackContext) throws JSONException {
        String slotName = args.getString(0);
        JSONObject liveContentContext = getJSONObject(args, 1);

        log("getLiveContentByCustomerID: {\"slot\":\"" + slotName + "\", \"live_context\":" + liveContentContext + "}");

        mBlueshift.getLiveContentByCustomerId(slotName, getMap(liveContentContext), callbackContext::success);

        return true;
    }

    private boolean getLiveContentByDeviceID(JSONArray args, CallbackContext callbackContext) throws JSONException {
        String slotName = args.getString(0);
        JSONObject liveContentContext = getJSONObject(args, 1);

        log("getLiveContentByDeviceID: {\"slot\":\"" + slotName + "\", \"live_context\":" + liveContentContext + "}");

        mBlueshift.getLiveContentByDeviceId(slotName, getMap(liveContentContext), callbackContext::success);

        return true;
    }

    private boolean enableTracking(JSONArray args) throws JSONException {
        boolean isEnabled = args.getBoolean(0);
        if (args.length() == 1) {
            log("enableTracking: {\"enabled\":" + isEnabled + "}");

            Blueshift.setTrackingEnabled(mAppContext, isEnabled);
        } else if (args.length() == 2) {
            boolean wipeData = args.getBoolean(1);
            log("enableTracking: {\"enabled\":" + isEnabled + ", \"wipeData\":" + wipeData + "}");

            Blueshift.setTrackingEnabled(mAppContext, isEnabled, wipeData);
        }

        return true;
    }

    private boolean enablePush(JSONArray args) throws JSONException {
        boolean isEnabled = args.getBoolean(0);
        log("enablePush: {\"enabled\":" + isEnabled + "}");
        BlueshiftAppPreferences.getInstance(cordova.getContext()).setEnablePush(isEnabled);
        BlueshiftAppPreferences.getInstance(cordova.getContext()).save(cordova.getContext());

        return true;
    }

    private boolean enableInApp(JSONArray args) throws JSONException {
        boolean isEnabled = args.getBoolean(0);
        log("enableInApp: {\"enabled\":" + isEnabled + "}");
        BlueshiftAppPreferences.getInstance(cordova.getContext()).setEnableInApp(isEnabled);
        BlueshiftAppPreferences.getInstance(cordova.getContext()).save(cordova.getContext());

        return true;
    }

    private boolean requestPushNotificationPermission() {
        Blueshift.requestPushNotificationPermission(cordova.getActivity());

        return true;
    }

    JSONObject getJSONObject(JSONArray jsonArray, int index) {
        if (jsonArray != null && index >= 0) {
            try {
                return jsonArray.getJSONObject(index);
            } catch (Exception e) {
                // do nothing
            }
        }

        return null;
    }

    HashMap<String, Object> getMap(JSONObject jsonObject) {
        if (jsonObject != null) {
            HashMap<String, Object> map = new HashMap<>();

            Iterator<String> keys = jsonObject.keys();
            while (keys.hasNext()) {
                try {
                    String key = keys.next();
                    Object val = jsonObject.get(key);
                    map.put(key, val);
                } catch (JSONException ignored) {
                }
            }

            return map;
        }

        return null;
    }

    JSONObject getJSONObject(HashMap<String, Object> map) {
        JSONObject jsonObject = new JSONObject();

        if (map != null) {
            for (Map.Entry<String, Object> e : map.entrySet()) {
                try {
                    jsonObject.put(e.getKey(), e.getValue());
                } catch (JSONException jsonException) {
                    Log.e(TAG, "getJson: ", jsonException);
                }
            }
        }

        return jsonObject;
    }

    private void log(String message) {
        if (mLoggingEnabled && message != null) {
            Log.d(TAG, message);
        }
    }
}
