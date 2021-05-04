document.addEventListener('deviceready', onDeviceReady, false);

document.addEventListener('OnBlueshiftDeepLinkReplayStart', function(e) {
    showLoader();
});
document.addEventListener('OnBlueshiftDeepLinkSuccess',  function(e){
//    alert("Deep link - "+e.deepLink);
    localStorage.setItem("deepLink", e.deepLink);
    hideLoader();
    refreshPage();
  });
document.addEventListener('OnBlueshiftDeepLinkReplayFail',  function(e){
//    alert("Deep link - "+e.deepLink);
    hideLoader();
    localStorage.setItem("deepLink", e.deepLink);
    refreshPage();
  });
function onDeviceReady() {
    refreshPage();
}

function refreshPage() {
    $('#deepLink').text(localStorage.getItem("deepLink"));
}

function showLoader() {
    $.mobile.loading("show",{text: "Loading", textVisible: true, theme:"b"});
}
function hideLoader() {
    $.mobile.loading("hide");
}

