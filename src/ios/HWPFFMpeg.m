#import "HWPFFMpeg.h"
#import <mobileffmpeg/MobileFFmpeg.h>
#import <mobileffmpeg/MobileFFmpegConfig.h>

@implementation HWPFFMpeg

NSMutableDictionary *mappings;


- (void)exec:(CDVInvokedUrlCommand*)command {

    if (mappings == nil){
        mappings = [NSMutableDictionary new];
        
        
        [MobileFFmpegConfig setStatisticsDelegate:self];
        // Note statistics delegate does NOT WORK without being log delegate
        // https://github.com/tanersener/mobile-ffmpeg/issues/271#issuecomment-557102757
        [MobileFFmpegConfig setLogDelegate:self];
    }
    
    //https://github.com/tanersener/mobile-ffmpeg/wiki/IOS
    NSString* cmd = [[command arguments] objectAtIndex:0];
    long executionId = [MobileFFmpeg executeAsync:cmd withCallback:self];
    [mappings setValue:command.callbackId forKey:[NSString stringWithFormat:@"%li", executionId]];

}

- (void)probe:(CDVInvokedUrlCommand*)command {
    NSString* filePath = [[command arguments] objectAtIndex:0];
    MediaInformation *mediaInformation = [MobileFFprobe getMediaInformation:filePath];
    int returnCode = [MobileFFmpegConfig getLastReturnCode];

    if(returnCode == RETURN_CODE_SUCCESS) {
        CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsDictionary:[mediaInformation getAllProperties]];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else {
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_ERROR
                                   messageAsString:[MobileFFmpegConfig getLastCommandOutput]];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}


- (void)executeCallback:(long)executionId :(int)returnCode {
    NSString *responseToUser;
    NSString *output = [MobileFFmpegConfig getLastCommandOutput];
    CDVCommandStatus resultStatus = CDVCommandStatus_OK;
    
    if (returnCode == RETURN_CODE_SUCCESS) {
        responseToUser = [NSString stringWithFormat: @"success out=%@", output];

    } else if (returnCode == RETURN_CODE_CANCEL) {
        responseToUser = [NSString stringWithFormat: @"canceld"];
        resultStatus = CDVCommandStatus_ERROR;

    } else {
        responseToUser = [NSString stringWithFormat: @"failure code=%d out=%@", returnCode, output];
        resultStatus = CDVCommandStatus_ERROR;
    }

    NSMutableDictionary *message = [NSMutableDictionary new];
    [message setValue:[NSNumber numberWithBool:YES] forKey:@"complete"];
    [message setValue:responseToUser forKey:@"result"];

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:resultStatus
                               messageAsDictionary:message];

    [self.commandDelegate sendPluginResult:result callbackId:[mappings valueForKey:[NSString stringWithFormat:@"%li", executionId]]];
    [mappings removeObjectForKey:[NSString stringWithFormat:@"%li", executionId]];
}

- (void)logCallback:(long)executionId :(int)level :(NSString*)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@", message);
    });
}

- (void)statisticsCallback:(Statistics *)newStatistics {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary *message = [NSMutableDictionary new];
        [message setValue:[NSNumber numberWithBool:NO] forKey:@"complete"];
        [message setValue:[NSNumber numberWithInt:[newStatistics getVideoFrameNumber]] forKey:@"videoFrameNumber"];
        [message setValue:[NSNumber numberWithInt: [newStatistics getVideoFps]] forKey:@"videoFps"];
        [message setValue:[NSNumber numberWithLong: [newStatistics getSize]] forKey:@"size"];
        [message setValue:[NSNumber numberWithInt: [newStatistics getTime]] forKey:@"time"];
        [message setValue:[NSNumber numberWithInt: [newStatistics getBitrate]] forKey:@"bitrate"];
        [message setValue:[NSNumber numberWithInt: [newStatistics getSpeed]] forKey:@"speed"];
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_OK
                                   messageAsDictionary:message];
        [result setKeepCallbackAsBool:YES];

        [self.commandDelegate sendPluginResult:result callbackId:[mappings valueForKey:[NSString stringWithFormat:@"%li", newStatistics.getExecutionId]]];
    });
}

@end
