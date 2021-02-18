/*global cordova, module*/

module.exports = {
  exec: function (cmd, statusCallback, errorCallback) {
    cordova.exec(statusCallback, errorCallback, "FFMpeg", "exec", [cmd]);
  },
  probe: function (filePath, statusCallback, errorCallback) {
    cordova.exec(statusCallback, errorCallback, "FFMpeg", "probe", [filePath]);
  },
};
