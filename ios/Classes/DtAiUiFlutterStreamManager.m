//
//  DtAiUiFlutterStreamManager.m
//  Pods
//
//  Created by 马博 on 2021/1/10.
//

#import "DtAiUiFlutterStreamManager.h"

@implementation DtAiUiFlutterStreamManager
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static DtAiUiFlutterStreamManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[DtAiUiFlutterStreamManager alloc] init];
        DtAiUiFlutterStreamHandler * streamHandler = [[DtAiUiFlutterStreamHandler alloc] init];
        manager.streamHandler = streamHandler;
    });
    return manager;
}

@end

@implementation DtAiUiFlutterStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink
{
    self.eventSink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments
{
    return nil;
}

@end
