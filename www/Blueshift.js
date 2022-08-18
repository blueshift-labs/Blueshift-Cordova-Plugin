var Blueshift = function () {
}
/**
* Registers a page for showing in-app message.
*
* @param {String} screenName    Name of the screen.
*/
Blueshift.prototype.registerForInAppMessages = function (screenName) {
    cordova.exec(null, null, 'Blueshift', 'registerForInAppMessages', [screenName]);
};

/**
* Unregisters a page from showing in-app message.
*/
Blueshift.prototype.unregisterForInAppMessages = function () {
    cordova.exec(null, null, 'Blueshift', 'unregisterForInAppMessages', []);
};

/**
* Fetches in-app messages from the Blueshift API and provides them in the callbacks.
* 
* @param {function} success    Success callback with the in-app API response.
* @param {function} error      Error callback with an error message.
*/
Blueshift.prototype.fetchInAppMessages = function (success, error) {
    cordova.exec(success, error, 'Blueshift', 'fetchInAppMessages', []);
};

/**
* Display in-app message if the current page is registered for in-app messages.
*/
Blueshift.prototype.displayInAppMessages = function () {
    cordova.exec(null, null, 'Blueshift', 'displayInAppMessages', []);
};

/**
* Send any custom event to Blueshift.
* 
* @param {String} eventName    Name of the custom event.
* @param {Object} extras       Additional params (if any).
* @param {Boolean} canBatch    Tells if this event can be batched or not.
*/
Blueshift.prototype.trackCustomEvent = function (eventName, extras, canBatch) {
    cordova.exec(null, null, 'Blueshift', 'trackCustomEvent', [eventName, extras, canBatch]);
};

/**
* Sends an identify event with the details available.
* 
* @param {Object} extras   Additional params (if any)
* @param {String} canBatch Tells if this event can be batched or not.
*/
Blueshift.prototype.identify = function (extras, canBatch) {
    cordova.exec(null, null, 'Blueshift', 'identify', [extras, canBatch]);
};

/**
* Save email in the SDK.
* 
* @param {String} email email of the customer.
*/
Blueshift.prototype.setUserInfoEmailID = function (email) {
    cordova.exec(null, null, 'Blueshift', 'setUserInfoEmailID', [email]);
};

/**
* Save customerId in the SDK.
* 
* @param {String} customerId customerId of the customer.
*/
Blueshift.prototype.setUserInfoCustomerID = function (customerId) {
    cordova.exec(null, null, 'Blueshift', 'setUserInfoCustomerID', [customerId]);
};

/**
* Save firstname in the SDK.
* 
* @param {String} firstname firstname of the customer.
*/
Blueshift.prototype.setUserInfoFirstName = function (firstname) {
    cordova.exec(null, null, 'Blueshift', 'setUserInfoFirstName', [firstname]);
};

/**
* Save lastname in the SDK.
* 
* @param {String} lastname lastname of the customer.
*/
Blueshift.prototype.setUserInfoLastName = function (lastname) {
    cordova.exec(null, null, 'Blueshift', 'setUserInfoLastName', [lastname]);
};

/**
* Save additional user info in the SDK.
* 
* @param {Object} extras additional user info.
*/
Blueshift.prototype.setUserInfoExtras = function (extras) {
    cordova.exec(null, null, 'Blueshift', 'setUserInfoExtras', [extras]);
};

/**
* Remove all the saved user info from the SDK.
*/
Blueshift.prototype.removeUserInfo = function () {
    cordova.exec(null, null, 'Blueshift', 'removeUserInfo', []);
};

/**
* Reset the UUID type of  device id. 
* This method will only work if the device id type is set as UUID for iOS and GUID for Android. 
* It will not work for other device id types.
*/
Blueshift.prototype.resetDeviceId = function () {
    cordova.exec(null, null, 'Blueshift', 'resetDeviceId', []);
};

/**
* Calls Blueshift's live content API with email and given slot name and live content context.
* 
* @param {String} slot slot name of the live content.
* @param {Object} lcContext live content context.
* @param {function} success success callback.
* @param {function} error error callback.
*/
Blueshift.prototype.getLiveContentByEmail = function (slot, lcContext, success, error) {
    cordova.exec(success, error, 'Blueshift', 'getLiveContentByEmail', [slot, lcContext]);
};

/**
* Calls Blueshift's live content API with customer id and given slot name and live content context.
* 
* @param {String} slot slot name of the live content.
* @param {Object} lcContext live content context.
* @param {function} success success callback.
* @param {function} error error callback.
*/
Blueshift.prototype.getLiveContentByCustomerID = function (slot, lcContext, success, error) {
    cordova.exec(success, error, 'Blueshift', 'getLiveContentByCustomerID', [slot, lcContext]);
};

/**
* Calls Blueshift's live content API with device id and given slot name and live content context.
* 
* @param {String} slot slot name of the live content.
* @param {Object} lcContext live content context.
* @param {function} success success callback.
* @param {function} error error callback.
*/
Blueshift.prototype.getLiveContentByDeviceID = function (slot, lcContext, success, error) {
    cordova.exec(success, error, 'Blueshift', 'getLiveContentByDeviceID', [slot, lcContext]);
};

/**
 * Enable/disable SDK's event tracking.
 * 
 * @param {Boolean} enabled When true, tracking is enabled. When false, disabled.
 */
Blueshift.prototype.enableTracking = function (enabled) {
    cordova.exec(null, null, 'Blueshift', 'enableTracking', [enabled]);
};

/**
 * Enable/disable SDK's event tracking.
 * 
 * @param {Boolean} enabled When true, tracking is enabled. When false, disabled.
 * @param {Boolean} wipeData When true, events will be wiped. When false, nothing happens.
 */
Blueshift.prototype.enableTracking = function (enabled, wipeData) {
    cordova.exec(null, null, 'Blueshift', 'enableTracking', [enabled, wipeData]);
};

/**
 * Opt-in or opt-out of push notifications sent from Blueshift.
 * 
 * @param {Boolean} enabled When true, opt-in else opt-out.
 */
Blueshift.prototype.enablePush = function (enabled) {
    cordova.exec(null, null, 'Blueshift', 'enablePush', [enabled]);
};

/**
 * Opt-in or opt-out of in-app notifications sent from Blueshift.
 * 
 * @param {Boolean} enabled When true, opt-in else opt-out.
 */
Blueshift.prototype.enableInApp = function (enabled) {
    cordova.exec(null, null, 'Blueshift', 'enableInApp', [enabled]);
};

/**
 * Register for remote notifications using SDK. Calling this method will show push permission dialogue to the user.
 * 
 * Android: Requires Android 13 or above and the 'android.permission.POST_NOTIFICATIONS' permission added in the AndroidManifest.xml file.
*/
Blueshift.prototype.registerForRemoteNotification = function () {
    cordova.exec(null, null, 'Blueshift', 'registerForRemoteNotification', []);
};

/**
 * Set current location of the device in the Blueshift SDK.
 * Note - This is only applicable for the iOS devices.
 *
 * @param {double} latitude location latitude value.
 * @param {double} longitude location longitude value.
 */
Blueshift.prototype.setCurrentLocation = function (latitude, longitude) {
    cordova.exec(null, null, 'Blueshift', 'setCurrentLocation', [latitude,longitude]);
};

/**
 * Get opt-in or opt-out status of in-app notifications set in the SDK.
 *
 * @param {function} success success callback.
 */
Blueshift.prototype.getEnableInAppStatus = function (success) {
    cordova.exec(success, null, 'Blueshift', 'getEnableInAppStatus', []);
};

/**
 * Get opt-in or opt-out status of push notifications set in the SDK.
 *
 * @param {function} success success callback.
 */
Blueshift.prototype.getEnablePushStatus = function (success) {
    cordova.exec(success, null, 'Blueshift', 'getEnablePushStatus', []);
};

/**
 * Get status of event tracking set in the SDK.
 *
 * @param {function} success success callback.
 */
Blueshift.prototype.getEnableTrackingStatus = function (success) {
    cordova.exec(success, null, 'Blueshift', 'getEnableTrackingStatus', []);
};

/**
 * Get email id string set in the SDK.
 *
 * @param {function} success success callback.
 */
Blueshift.prototype.getUserInfoEmailID = function (success) {
    cordova.exec(success, null, 'Blueshift', 'getUserInfoEmailID', []);
};

/**
 * Get customer id string set in the SDK.
 *
 * @param {function} success success callback.
 */
Blueshift.prototype.getUserInfoCustomerID = function (success) {
    cordova.exec(success, null, 'Blueshift', 'getUserInfoCustomerID', []);
};

/**
 * Get first name string set in the SDK.
 *
 * @param {function} success success callback.
 */
Blueshift.prototype.getUserInfoFirstName = function (success) {
    cordova.exec(success, null, 'Blueshift', 'getUserInfoFirstName', []);
};

/**
 * Get last name string set in the SDK.
 *
 * @param {function} success success callback.
 */
Blueshift.prototype.getUserInfoLastName = function (success) {
    cordova.exec(success, null, 'Blueshift', 'getUserInfoLastName', []);
};

/**
 * Get extras JSON data set in the SDK.
 *
 * @param {function} success success callback.
 */
Blueshift.prototype.getUserInfoExtras = function (success) {
    cordova.exec(success, null, 'Blueshift', 'getUserInfoExtras', []);
};

/**
 * Get current device id string used by the SDK.
 *
 * @param {function} success success callback.
 */
Blueshift.prototype.getCurrentDeviceId = function (success) {
    cordova.exec(success, null, 'Blueshift', 'getCurrentDeviceId', []);
};

module.exports = new Blueshift();
