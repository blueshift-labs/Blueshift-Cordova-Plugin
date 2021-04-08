var exec = require('cordova/exec');

/**
* Registers a page for showing in-app message.
*
* @param {String} screenName    Name of the screen.
*/
exports.registerForInAppMessages = function (screenName) {
    exec(null, null, 'Blueshift', 'registerForInAppMessages', [screenName]);
};

/**
* Unregisters a page from showing in-app message.
*/
exports.unregisterForInAppMessages = function () {
    exec(null, null, 'Blueshift', 'unregisterForInAppMessages', []);
};

/**
* Fetches in-app messages from the Blueshift API and provides them in the callbacks.
* 
* @param {function} success    Success callback with the in-app API response.
* @param {function} error      Error callback with an error message.
*/
exports.fetchInAppMessages = function (success, error) {
    exec(success, error, 'Blueshift', 'fetchInAppMessages', []);
};

/**
* Display in-app message if the current page is registered for in-app messages.
*/
exports.displayInAppMessages = function () {
    exec(null, null, 'Blueshift', 'displayInAppMessages', []);
};

/**
* Send any custom event to Blueshift.
* 
* @param {String} eventName    Name of the custom event.
* @param {Object} extras       Additional params (if any).
* @param {Boolean} canBatch    Tells if this event can be batched or not.
*/
exports.trackCustomEvent = function (eventName, extras, canBatch) {
    exec(null, null, 'Blueshift', 'trackCustomEvent', [eventName, extras, canBatch]);
};

/**
* Sends an identify event with the details available.
* 
* @param {Object} extras   Additional params (if any)
* @param {String} canBatch Tells if this event can be batched or not.
*/
exports.identify = function (extras, canBatch) {
    exec(null, null, 'Blueshift', 'identify', [extras, canBatch]);
};

/**
* Save email in the SDK.
* 
* @param {String} email email of the customer.
*/
exports.setUserInfoEmailID = function (email) {
    exec(null, null, 'Blueshift', 'setUserInfoEmailID', [email]);
};

/**
* Save customerId in the SDK.
* 
* @param {String} customerId customerId of the customer.
*/
exports.setUserInfoCustomerID = function (customerId) {
    exec(null, null, 'Blueshift', 'setUserInfoCustomerID', [customerId]);
};

/**
* Save firstname in the SDK.
* 
* @param {String} firstname firstname of the customer.
*/
exports.setUserInfoFirstName = function (firstname) {
    exec(null, null, 'Blueshift', 'setUserInfoFirstName', [firstname]);
};

/**
* Save lastname in the SDK.
* 
* @param {String} lastname lastname of the customer.
*/
exports.setUserInfoLastName = function (lastname) {
    exec(null, null, 'Blueshift', 'setUserInfoLastName', [lastname]);
};

/**
* Save additional user info in the SDK.
* 
* @param {Object} extras additional user info.
*/
exports.setUserInfoExtras = function (extras) {
    exec(null, null, 'Blueshift', 'setUserInfoExtras', [extras]);
};

/**
* Remove all the saved user info from the SDK.
*/
exports.removeUserInfo = function () {
    exec(null, null, 'Blueshift', 'removeUserInfo', []);
};

/**
* Calls Blueshift's live content API with email and given slot name and live content context.
* 
* @param {String} slot slot name of the live content.
* @param {Object} lcContext live content context.
* @param {function} success success callback.
* @param {function} error error callback.
*/
exports.getLiveContentByEmail = function (slot, lcContext, success, error) {
    exec(success, error, 'Blueshift', 'getLiveContentByEmail', [slot, lcContext]);
};

/**
* Calls Blueshift's live content API with customer id and given slot name and live content context.
* 
* @param {String} slot slot name of the live content.
* @param {Object} lcContext live content context.
* @param {function} success success callback.
* @param {function} error error callback.
*/
exports.getLiveContentByCustomerID = function (slot, lcContext, success, error) {
    exec(success, error, 'Blueshift', 'getLiveContentByCustomerID', [slot, lcContext]);
};

/**
* Calls Blueshift's live content API with device id and given slot name and live content context.
* 
* @param {String} slot slot name of the live content.
* @param {Object} lcContext live content context.
* @param {function} success success callback.
* @param {function} error error callback.
*/
exports.getLiveContentByDeviceID = function (slot, lcContext, success, error) {
    exec(success, error, 'Blueshift', 'getLiveContentByDeviceID', [slot, lcContext]);
};

/**
 * Enable/disable SDK's event tracking.
 * 
 * @param {Boolean} enabled When true, tracking is enabled. When false, disabled.
 */
exports.enableTracking = function (enabled) {
    exec(null, null, 'Blueshift', 'enableTracking', [enabled]);
};

/**
 * Enable/disable SDK's event tracking.
 * 
 * @param {Boolean} enabled When true, tracking is enabled. When false, disabled.
 * @param {Boolean} wipeData When true, events will be wiped. When false, nothing happens.
 */
exports.enableTracking = function (enabled, wipeData) {
    exec(null, null, 'Blueshift', 'enableTracking', [enabled, wipeData]);
};

/**
 * Opt-in or opt-out of push notifications sent from Blueshift.
 * 
 * @param {Boolean} enabled When true, opt-in else opt-out.
 */
exports.enablePush = function (enabled) {
    exec(null, null, 'Blueshift', 'enablePush', [enabled]);
};

/**
 * Opt-in or opt-out of in-app notifications sent from Blueshift.
 * 
 * @param {Boolean} enabled When true, opt-in else opt-out.
 */
exports.enableInApp = function (enabled) {
    exec(null, null, 'Blueshift', 'enableInApp', [enabled]);
};

/**
 * Register for remote notifications using SDK. Calling this method will show push permission dialogue to the user.
 * Note - This is only applicable for the iOS devices.
 */
exports.registerForRemoteNotification = function () {
    exec(null, null, 'Blueshift', 'registerForRemoteNotification', []);
};

/**
 * Set current location of the device in the Blueshift SDK.
 * Note - This is only applicable for the iOS devices.
 *
 * @param {double} latitude location latitude value.
 * @param {double} longitude location longitude value.
 */
exports.setCurrentLocation = function (latitude, longitude) {
    exec(null, null, 'Blueshift', 'setCurrentLocation', [latitude,longitude]);
};

/**
 * Get opt-in or opt-out status of in-app notifications set in the SDK.
 *
 * @param {function} success success callback.
 */
exports.getEnableInAppStatus = function (success) {
    exec(success, null, 'Blueshift', 'getEnableInAppStatus', []);
};

/**
 * Get opt-in or opt-out status of push notifications set in the SDK.
 *
 * @param {function} success success callback.
 */
exports.getEnablePushStatus = function (success) {
    exec(success, null, 'Blueshift', 'getEnablePushStatus', []);
};

/**
 * Get status of event tracking set in the SDK.
 *
 * @param {function} success success callback.
 */
exports.getEnableTrackingStatus = function (success) {
    exec(success, null, 'Blueshift', 'getEnableTrackingStatus', []);
};

/**
 * Get email id string set in the SDK.
 *
 * @param {function} success success callback.
 */
exports.getUserInfoEmailID = function (success) {
    exec(success, null, 'Blueshift', 'getUserInfoEmailID', []);
};

/**
 * Get customer id string set in the SDK.
 *
 * @param {function} success success callback.
 */
exports.getUserInfoCustomerID = function (success) {
    exec(success, null, 'Blueshift', 'getUserInfoCustomerID', []);
};

/**
 * Get first name string set in the SDK.
 *
 * @param {function} success success callback.
 */
exports.getUserInfoFirstName = function (success) {
    exec(success, null, 'Blueshift', 'getUserInfoFirstName', []);
};

/**
 * Get last name string set in the SDK.
 *
 * @param {function} success success callback.
 */
exports.getUserInfoLastName = function (success) {
    exec(success, null, 'Blueshift', 'getUserInfoLastName', []);
};

/**
 * Get extras JSON data set in the SDK.
 *
 * @param {function} success success callback.
 */
exports.getUserInfoExtras = function (success) {
    exec(success, null, 'Blueshift', 'getUserInfoExtras', []);
};

/**
 * Get current device id string used by the SDK.
 *
 * @param {function} success success callback.
 */
exports.getCurrentDeviceId = function (success) {
    exec(success, null, 'Blueshift', 'getCurrentDeviceId', []);
};

