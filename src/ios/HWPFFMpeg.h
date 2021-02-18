#import <Cordova/CDV.h>
#import <mobileffmpeg/MobileFFmpeg.h>

@interface HWPFFMpeg : CDVPlugin<ExecuteDelegate,StatisticsDelegate,LogDelegate>

- (void) exec:(CDVInvokedUrlCommand*)command;
- (void) probe:(CDVInvokedUrlCommand*)command;

@end
