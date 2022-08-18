document.addEventListener('deviceready', onDeviceReady, false);

document.addEventListener('OnBlueshiftDeepLinkReplayStart', function(e) {
    showLoader();
  });

document.addEventListener('OnBlueshiftDeepLinkSuccess',  function(e){
//    alert("Deep link - "+e.deepLink);
    localStorage.setItem("deepLink", e.deepLink);
    hideLoader();
    window.open("deepLink.html");
  });

document.addEventListener('OnBlueshiftDeepLinkReplayFail',  function(e){
//    alert("Deep link - "+e.deepLink);
    hideLoader();
    localStorage.setItem("deepLink", e.deepLink);
    window.open("deepLink.html");
  });

function onDeviceReady() {
    setTimeout(refreshData, 500)
    registerForInApp()
}

function refreshData() {
    getEnableInAppStatus((status) => {
        $('#flip-checkbox-enableInApp').prop('checked',status);
        $("#flip-checkbox-enableInApp").checkboxradio();
        $("#flip-checkbox-enableInApp").checkboxradio("refresh");
    });
    getEnablePushStatus((status) => {
        $('#flip-checkbox-enablePush').prop('checked',status);
        $("#flip-checkbox-enablePush").checkboxradio();
        $("#flip-checkbox-enablePush").checkboxradio("refresh");
    });
    getEnableTrackingStatus((status) => {
        $('#flip-checkbox-enableTracking').prop('checked',status);
        $("#flip-checkbox-enableTracking").checkboxradio();
        $("#flip-checkbox-enableTracking").checkboxradio("refresh");
    });
    getCurrentDeviceId((deviceId) => {
        $("#text-0").val(deviceId);
    });
    getUserInfoEmailID((emailId) => {
        $("#text-1").val(emailId);
    });
    getUserInfoCustomerID((customerId) => {
        $("#text-2").val(customerId);
    });
    getUserInfoFirstName((firstName) => {
        $("#text-3").val(firstName);
    });
    getUserInfoLastName((lastName) => {
        $("#text-4").val(lastName);
    });
    getUserInfoExtras((extras) => {
        $("#text-5").val(JSON.stringify(extras));
    });
}
function saveEmail(){
    var emailid = $("#text-1").val();
    Blueshift.setUserInfoEmailID(emailid);
}
function saveCustomerId(){
    var customerId = $("#text-2").val();
    Blueshift.setUserInfoCustomerID(customerId);
}
function saveFirstName(){
    var firstName = $("#text-3").val();
    Blueshift.setUserInfoFirstName(firstName);
}
function saveLastName(){
    var lastName = $("#text-4").val();
    Blueshift.setUserInfoLastName(lastName);
}
function saveExtras(){
    var extras = JSON.parse($("#text-5").val());
    Blueshift.setUserInfoExtras(extras);
}
function removeUserInfo(){
    Blueshift.removeUserInfo();
    refreshData()
}
function fireIdentify(){
    Blueshift.identify({"phone_number":"+919999999999","profession":"software engineer","platform":"cordova"}, false);
}
function fireCustomEvent(){
    var eventName = $("#text-6").val();
    Blueshift.trackCustomEvent(eventName,{"platform":"cordova"}, false);
}
function fireSelectedEvent(){
    var eventName = $("#eventDropDown").val();
    Blueshift.trackCustomEvent(eventName,{"platform":"cordova"}, false);
}
function registerForPush(){
    Blueshift.registerForRemoteNotification();
}
function resetDeviceId() {
    Blueshift.resetDeviceId();
}
function enablePush(){
    var val = $("#flip-checkbox-enablePush").is(":checked");
    Blueshift.enablePush(val);
}
function enableInApp(){
    var val = $("#flip-checkbox-enableInApp").is(":checked");
    Blueshift.enableInApp(val);
}
function enableTracking() {
    var isEnabled = $("#flip-checkbox-enableTracking").is(":checked");
    Blueshift.enableTracking(isEnabled, true);
}
function registerForInApp(){
    Blueshift.registerForInAppMessages("indexCordova");
}
function unregisterForInApp(){
    Blueshift.unregisterForInAppMessages();
}
function fetchInApp(){
    showLoader();
    Blueshift.fetchInAppMessages((json) => {
        hideLoader();
        console.log(json);
    }, (error) => {
        console.log(error);
        hideLoader();
    });
}
function displayInApp(){
    Blueshift.displayInAppMessages();
}
function setCurrentLocation() {
    Blueshift.setCurrentLocation(16.7050, 74.2433);
}
function getLiveContent() {
    $('#liveContent').text("");
    showLoader();
    $("input[name*=radio-choice]:checked").each(function() {
        var identifier = $(this).val();
        if (identifier == "emailId") {
            Blueshift.getLiveContentByEmail('careinappmessagingslot',{}, (content) => {
                hideLoader();
                $('#liveContent').append(JSON.stringify(content.content));
                $("#liveContent").popup("open");
            }, (e)=>{
                hideLoader();
                alert(e);
            });
        } else if(identifier == "customerId") {
            Blueshift.getLiveContentByCustomerID('careinappmessagingslot',{}, (content) => {
                hideLoader();
                $('#liveContent').append(JSON.stringify(content.content));
                $("#liveContent").popup("open");
            }, (e)=>{
                hideLoader();
                alert(e);
            });
        } else {
            Blueshift.getLiveContentByDeviceID('careinappmessagingslot',{}, (content) => {
                hideLoader();
                $('#liveContent').append(JSON.stringify(content.content));
                $("#liveContent").popup("open");
            }, ()=>{
                hideLoader();
            });
        }
    });
}

function getEnableInAppStatus(success) {
    Blueshift.getEnableInAppStatus(success);
}

function getEnablePushStatus(success) {
    Blueshift.getEnablePushStatus(success);
}

function getEnableTrackingStatus(success) {
    Blueshift.getEnableTrackingStatus(success);
}

function getUserInfoEmailID(success) {
    Blueshift.getUserInfoEmailID(success);
}

function getUserInfoCustomerID(success) {
    Blueshift.getUserInfoCustomerID(success);
}

function getUserInfoFirstName(success) {
    Blueshift.getUserInfoFirstName(success);
}

function getUserInfoLastName(success) {
    Blueshift.getUserInfoLastName(success);
}

function getUserInfoExtras(success) {
    Blueshift.getUserInfoExtras(success);
}

function getCurrentDeviceId(success) {
    Blueshift.getCurrentDeviceId(success);
}

function showLoader() {
    $.mobile.loading("show",{text: "Loading", textVisible: true, theme:"b"});
}
function hideLoader() {
    $.mobile.loading("hide");
}

