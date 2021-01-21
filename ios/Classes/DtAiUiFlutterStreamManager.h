//
//  DtAiUiFlutterStreamManager.h
//  Pods
//
//  Created by 马博 on 2021/1/10.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@class DtAiUiFlutterStreamHandler;

@interface DtAiUiFlutterStreamManager : NSObject

+ (instancetype)sharedInstance;
@property (nonatomic, strong) DtAiUiFlutterStreamHandler* streamHandler;

@end

@interface DtAiUiFlutterStreamHandler : NSObject<FlutterStreamHandler>

@property (nonatomic, strong,nullable) FlutterEventSink eventSink;

@end



NS_ASSUME_NONNULL_END
