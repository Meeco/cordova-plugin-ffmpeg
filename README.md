# Cordova FFMPEG Plugin

Simple plugin that binds mobile ffmpeg to execute ffmpeg commands

## Using

Create a new Cordova Project

    $ cordova create hello com.example.helloapp Hello

make sure you have cocoapods **On MacOS**

> `sudo gem install cocoapods`

Install the plugin

    $ cd hello
    $ cordova plugin add https://github.com/adminy/cordova-plugin-ffmpeg.git

Edit `www/js/index.js` and add the following code inside `onDeviceReady`

```js
ffmpeg.exec(
  "-i someinput.mp4 -vn -c:a copy out.mp3",
  (status) => {
    if (status.complete) {
      console.log(status.result);
    } else {
      console.log("Progress:");
      console.log(status.videoFrameNumber);
      console.log(status.videoFps);
      console.log(status.size);
      console.log(status.time);
      console.log(status.bitrate);
      console.log(status.speed);
    }
  },
  (failure) => alert(failure)
);
```

Note, that the plugin callback is executed multiple times with status updates - you can tell if
the command result completed by checking `status.complete === true`

Make sure you have the files that will be required by ffmpeg

Install iOS or Android platform

    cordova platform add ios
    cordova platform add android

Run the code

    cordova run
