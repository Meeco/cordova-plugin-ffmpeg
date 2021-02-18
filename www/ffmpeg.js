/*global cordova, module*/

module.exports = {
    exec: function (cmd, statusCallback, errorCallback) {
        cordova.exec(statusCallback, errorCallback, "FFMpeg", "exec", [cmd]);
    }
};
