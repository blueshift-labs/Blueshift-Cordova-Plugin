package com.blueshift.cordova;

import android.util.Log;

import com.blueshift.Blueshift;
import com.blueshift.BlueshiftAppPreferences;
import com.blueshift.inappmessage.InAppApiCallback;
import com.blueshift.model.UserInfo;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;

/**
 * This class echoes a string called from JavaScript.
 */
public class BlueshiftPlugin extends CordovaPlugin {
    private static final String TAG = "BlueshiftPlugin";

    private Blueshift getBlueshiftInstance() {
        return Blueshift.getInstance(cordova.getContext());
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        Log.d(TAG, "{\"action\":\"" + action +"\"}");

        // IN APP MESSAGES
        if (action.equals("registerForInAppMessages")) return registerForInAppMessages(args);
        if (action.equals("unregisterForInAppMessages")) return unregisterForInAppMessages();
        if (action.equals("fetchInAppMessages")) return fetchInAppMessages(callbackContext);
        if (action.equals("displayInAppMessages")) return displayInAppMessages();

        // EVENTS
        if (action.equals("trackCustomEvent")) return trackCustomEvent(args);
        if (action.equals("identify")) return identify(args);

        // USER INFO
        if (action.equals("setUserInfoEmailID")) return setUserInfoEmailID(args);
        if (action.equals("setUserInfoCustomerID")) return setUserInfoCustomerID(args);
        if (action.equals("setUserInfoFirstName")) return setUserInfoFirstName(args);
        if (action.equals("setUserInfoLastName")) return setUserInfoLastName(args);
        if (action.equals("setUserInfoExtras")) return setUserInfoExtras(args);
        if (action.equals("removeUserInfo")) return removeUserInfo();

        // LIVE CONTENT
        if (action.equals("getLiveContentByEmail"))
            return getLiveContentByEmail(args, callbackContext);
        if (action.equals("getLiveContentByCustomerID"))
            return getLiveContentByCustomerID(args, callbackContext);
        if (action.equals("getLiveContentByDeviceID"))
            return getLiveContentByDeviceID(args, callbackContext);

        // OPT IN/OUT
        if (action.equals("enableTracking")) return enableTracking(args);
        if (action.equals("enablePush")) return enablePush(args);
        if (action.equals("enableInApp")) return enableInApp(args);

        return false;
    }

    private boolean registerForInAppMessages(JSONArray args) throws JSONException {
        String screenName = args.getString(0);
        // blueshift.registerForInAppMessages(cordova.getActivity(), screenName);
        Log.d(TAG, "registerForInAppMessages: { \"screenName\" : \"" + screenName + "\"}");

        getBlueshiftInstance().registerForInAppMessages(cordova.getActivity());

        return true;
    }

    private boolean unregisterForInAppMessages() {
        Log.d(TAG, "unregisterForInAppMessages: ");

        getBlueshiftInstance().unregisterForInAppMessages(cordova.getActivity());

        return true;
    }

    private boolean fetchInAppMessages(CallbackContext callbackContext) {
        Log.d(TAG, "fetchInAppMessages: ");

        getBlueshiftInstance().fetchInAppMessages(new InAppApiCallback() {
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
        Log.d(TAG, "displayInAppMessages: ");

        getBlueshiftInstance().displayInAppMessages();

        return true;
    }

    private boolean trackCustomEvent(JSONArray args) throws JSONException {
        String eventName = args.getString(0);
        JSONObject extras = args.getJSONObject(1);
        boolean canBatch = args.getBoolean(2);

        Log.d(TAG, "trackCustomEvent: {\"event\":\"" + eventName + "\", \"extras\": " + extras + ", \"canBatch\": " + canBatch + "}");

        getBlueshiftInstance().trackEvent(eventName, getMap(extras), canBatch);

        return true;
    }

    private boolean identify(JSONArray args) throws JSONException {
        String eventName = "identify";
        JSONObject extras = args.getJSONObject(0);
        boolean canBatch = args.getBoolean(1);

        Log.d(TAG, "identify: {\"event\":\"" + eventName + "\", \"extras\": " + extras + ", \"canBatch\": " + canBatch + "}");

        getBlueshiftInstance().trackEvent(eventName, getMap(extras), canBatch);

        return true;
    }

    private boolean setUserInfoEmailID(JSONArray args) throws JSONException {
        String email = args.getString(0);

        Log.d(TAG, "setUserInfoEmailID: " + email);

        UserInfo userInfo = UserInfo.getInstance(cordova.getContext());
        if (userInfo != null) {
            userInfo.setEmail(email);
            userInfo.save(cordova.getContext());
        }

        return true;
    }

    private boolean setUserInfoCustomerID(JSONArray args) throws JSONException {
        String customerID = args.getString(0);

        Log.d(TAG, "setUserInfoCustomerID: " + customerID);

        UserInfo userInfo = UserInfo.getInstance(cordova.getContext());
        if (userInfo != null) {
            userInfo.setRetailerCustomerId(customerID);
            userInfo.save(cordova.getContext());
        }

        return true;
    }

    private boolean setUserInfoFirstName(JSONArray args) throws JSONException {
        String firstName = args.getString(0);

        Log.d(TAG, "setUserInfoFirstname: " + firstName);

        UserInfo userInfo = UserInfo.getInstance(cordova.getContext());
        if (userInfo != null) {
            userInfo.setFirstname(firstName);
            userInfo.save(cordova.getContext());
        }

        return true;
    }

    private boolean setUserInfoLastName(JSONArray args) throws JSONException {
        String lastName = args.getString(0);

        Log.d(TAG, "setUserInfoLastname: " + lastName);

        UserInfo userInfo = UserInfo.getInstance(cordova.getContext());
        if (userInfo != null) {
            userInfo.setLastname(lastName);
            userInfo.save(cordova.getContext());
        }

        return true;
    }

    private boolean setUserInfoExtras(JSONArray args) throws JSONException {
        JSONObject extras = args.getJSONObject(0);

        Log.d(TAG, "setUserInfoExtras: " + extras);

        UserInfo userInfo = UserInfo.getInstance(cordova.getContext());
        if (userInfo != null) {
            userInfo.setDetails(getMap(extras));
            userInfo.save(cordova.getContext());
        }

        return true;
    }

    private boolean removeUserInfo() {
        Log.d(TAG, "removeUserInfo: ");

        UserInfo userInfo = UserInfo.getInstance(cordova.getContext());
        if (userInfo != null) {
            // TODO clear user info
            userInfo.save(cordova.getContext());
        }

        return true;
    }

    private boolean getLiveContentByEmail(JSONArray args, CallbackContext callbackContext) throws JSONException {
        String slotName = args.getString(0);
        JSONObject liveContentContext = args.getJSONObject(1);

        Log.d(TAG, "getLiveContentByEmail: {\"slot\":\"" + slotName + "\", \"live_context\":" + liveContentContext + "}");

        getBlueshiftInstance().getLiveContentByEmail(slotName, getMap(liveContentContext), callbackContext::success);

        return true;
    }

    private boolean getLiveContentByCustomerID(JSONArray args, CallbackContext callbackContext) throws JSONException {
        String slotName = args.getString(0);
        JSONObject liveContentContext = args.getJSONObject(1);

        Log.d(TAG, "getLiveContentByCustomerID: {\"slot\":\"" + slotName + "\", \"live_context\":" + liveContentContext + "}");

        getBlueshiftInstance().getLiveContentByCustomerId(slotName, getMap(liveContentContext), callbackContext::success);

        return true;
    }

    private boolean getLiveContentByDeviceID(JSONArray args, CallbackContext callbackContext) throws JSONException {
        String slotName = args.getString(0);
        JSONObject liveContentContext = args.getJSONObject(1);

        Log.d(TAG, "getLiveContentByDeviceID: {\"slot\":\"" + slotName + "\", \"live_context\":" + liveContentContext + "}");

        getBlueshiftInstance().getLiveContentByDeviceId(slotName, getMap(liveContentContext), callbackContext::success);

        return true;
    }

    private boolean enableTracking(JSONArray args) throws JSONException {
        boolean isEnabled = args.getBoolean(0);
        if (args.length() == 1) {
            Log.d(TAG, "enableTracking: {\"enabled\":" + isEnabled + "}");

            Blueshift.setTrackingEnabled(cordova.getContext(), isEnabled);
        } else if (args.length() == 2) {
            boolean wipeData = args.getBoolean(1);
            Log.d(TAG, "enableTracking: {\"enabled\":" + isEnabled + ", \"wipeData\":" + wipeData + "}");

            Blueshift.setTrackingEnabled(cordova.getContext(), isEnabled, wipeData);
        }

        return true;
    }

    private boolean enablePush(JSONArray args) throws JSONException {
        boolean isEnabled = args.getBoolean(0);
        Log.d(TAG, "enablePush: {\"enabled\":" + isEnabled + "}");
        BlueshiftAppPreferences.getInstance(cordova.getContext()).setEnablePush(isEnabled);
        BlueshiftAppPreferences.getInstance(cordova.getContext()).save(cordova.getContext());

        return true;
    }

    private boolean enableInApp(JSONArray args) throws JSONException {
        boolean isEnabled = args.getBoolean(0);
        Log.d(TAG, "enableInApp: {\"enabled\":" + isEnabled + "}");
        // TODO implement this

        return true;
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
}
