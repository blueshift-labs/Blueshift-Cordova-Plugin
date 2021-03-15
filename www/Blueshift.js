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

// exports.coolMethod = function (arg0, success, error) {
//     exec(success, error, 'Blueshift', 'coolMethod', [arg0]);
// };
