package com.marin.plugin;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.arthenica.mobileffmpeg.ExecuteCallback;
import com.arthenica.mobileffmpeg.FFmpeg;
import com.arthenica.mobileffmpeg.Config;
import com.arthenica.mobileffmpeg.FFprobe;
import com.arthenica.mobileffmpeg.MediaInformation;
import com.arthenica.mobileffmpeg.Statistics;
import com.arthenica.mobileffmpeg.StatisticsCallback;

import java.util.HashMap;

import static com.arthenica.mobileffmpeg.Config.RETURN_CODE_SUCCESS;
 // ref: https://github.com/tanersener/mobile-ffmpeg/wiki/Android
public class FFMpeg extends CordovaPlugin {

    boolean statisticsCallbackEnabled = false;

    HashMap<String, CallbackContext> callbackForExecution = new HashMap<String, CallbackContext>();

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        if(!statisticsCallbackEnabled) {
            FFMpeg self = this;
            Config.enableStatisticsCallback(new StatisticsCallback() {
                @Override
                public void apply(Statistics statistics) {
                    CallbackContext context = self.callbackForExecution.get(""+ statistics.getExecutionId());
                    try {
                        JSONObject update = new JSONObject();
                        update.put("complete", false);
                        update.put("videoFrameNumber", statistics.getVideoFrameNumber());
                        update.put("videoFps", statistics.getVideoFps());
                        update.put("size", statistics.getSize());
                        update.put("time", statistics.getTime());
                        update.put("bitrate", statistics.getBitrate());
                        update.put("speed", statistics.getSpeed());

                        PluginResult result = new PluginResult(PluginResult.Status.OK, update);
                        result.setKeepCallback(true);
                        context.sendPluginResult(result);
                    } catch(JSONException e) {

                    }
                }
            });
        }

        if (action.equals("exec")) {
            long executionId = FFmpeg.executeAsync(data.getString(0), new ExecuteCallback() {
                @Override
                public void apply(long executionId, int returnCode) {
                    String result = String.format("Done out=%s", Config.getLastCommandOutput());
                    if (returnCode == RETURN_CODE_SUCCESS) {
                        try {
                            JSONObject update = new JSONObject();
                            update.put("complete", true);
                            update.put("result", result);
                            callbackContext.success(update);
                        } catch(JSONException e) {
                            callbackContext.success(result);
                        }
                    }
                    else
                        callbackContext.error("Error Code: " + returnCode);
                }
            });
            this.callbackForExecution.put("" + executionId , callbackContext);
            return true;
        } else if(action.equals("probe")) {
            MediaInformation info = FFprobe.getMediaInformation(data.getString(0));
            int returnCode = Config.getLastReturnCode();
            if(returnCode == RETURN_CODE_SUCCESS) {
                callbackContext.success(info.getAllProperties());
            } else {
                callbackContext.error(Config.getLastCommandOutput());
            }
            return true;
        } else return false;
    }
}
