#import "DtAiuiPlugin.h"
#if __has_include(<dt_aiui_plugin/dt_aiui_plugin-Swift.h>)
#import <dt_aiui_plugin/dt_aiui_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#endif

#import "DtAiUiFlutterStreamManager.h"
#import "IFlyAIUI/IFlyAIUI.h"

@interface DtAiuiPlugin ()

@property (nonatomic, copy) FlutterResult flutterResult;

@property IFlyAIUIAgent *aiuiAgent;

@end


@implementation DtAiuiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
//    [SwiftDtAiuiPlugin registerWithRegistrar:registrar];
    
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"dt_aiui_plugin"
                                     binaryMessenger:[registrar messenger]];
    DtAiuiPlugin* instance = [[DtAiuiPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];


    FlutterEventChannel *eventChanel = [FlutterEventChannel eventChannelWithName:@"dt_aiui_plugin_event" binaryMessenger:[registrar messenger]];
    
    [eventChanel setStreamHandler:[[DtAiUiFlutterStreamManager sharedInstance] streamHandler]];

}


- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        //APP的版本号
        result([@"iOS " stringByAppendingString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]);
        
    }else if ([@"initAIUIAgent" isEqualToString:call.method]){
        //初始化 , 注册appid
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        
        NSString *cachePath = [paths objectAtIndex:0];
        cachePath = [cachePath stringByAppendingString:@"/"];
        NSLog(@"cachePath=%@",cachePath);
        
        [IFlyAIUISetting setSaveDataLog:NO];
        [IFlyAIUISetting setLogLevel:LV_INFO];
        [IFlyAIUISetting setAIUIDir:cachePath];
        [IFlyAIUISetting setMscDir:cachePath];

        // 读取aiui.cfg配置文件
        NSString *cfgFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"aiui" ofType:@"cfg"];
        NSString *cfg = [NSString stringWithContentsOfFile:cfgFilePath encoding:NSUTF8StringEncoding error:nil];
            
        //创建AIUIAgent
        _aiuiAgent = [IFlyAIUIAgent createAgent:cfg withListener:self];
        
        if (_aiuiAgent == NULL) {
            result(@NO);
        }else{
            result(@YES);
        }

    }else if ([@"startVoiceNlp" isEqualToString:call.method]){

        //发送唤醒消息
        IFlyAIUIMessage *wakeuMsg = [[IFlyAIUIMessage alloc]init];
        wakeuMsg.msgType = CMD_WAKEUP;
        [_aiuiAgent sendMessage:wakeuMsg];
            
        //发送开始录音消息
        IFlyAIUIMessage *msg = [[IFlyAIUIMessage alloc] init];
        msg.msgType = CMD_START_RECORD;
        [_aiuiAgent sendMessage:msg];
        result(@YES);

        
    }else if ([@"stopVoiceNlp" isEqualToString:call.method]){

        //发送开始录音消息
        IFlyAIUIMessage *msg = [[IFlyAIUIMessage alloc] init];
        msg.msgType = CMD_RESET_WAKEUP;
        [_aiuiAgent sendMessage:msg];

        result(@YES);

    }else {
        result(FlutterMethodNotImplemented);
    }
}



- (void) onEvent:(IFlyAIUIEvent *) event {

    switch (event.eventType) {
            
        case EVENT_CONNECTED_TO_SERVER:
        {
            //服务器连接成功事件
            NSLog(@"CONNECT TO SERVER");
        } break;
            
        case EVENT_SERVER_DISCONNECTED:
        {
            //服务器连接断开事件
            NSLog(@"DISCONNECT TO SERVER");
        } break;
        
        case EVENT_START_RECORD:
        {
            //开始录音事件
            NSLog(@"EVENT_START_RECORD");
            [self getResultJsonWithCode:EVENT_START_RECORD data:@""];
        } break;
            
        case EVENT_STOP_RECORD:
        {
            //停止录音事件
            NSLog(@"EVENT_STOP_RECORD");
            [self getResultJsonWithCode:EVENT_STOP_RECORD data:@""];
        } break;
            
        case EVENT_STATE:
        {
            //AIUI运行状态事件
            switch (event.arg1)
            {
                case STATE_IDLE:
                {
                    NSLog(@"EVENT_STATE: %s", "IDLE");
                    [self getResultJsonWithCode:EVENT_STATE data:@"STATE_IDLE"];
                } break;
                    
                case STATE_READY:
                {
                    NSLog(@"EVENT_STATE: %s", "READY");
                    [self getResultJsonWithCode:EVENT_STATE data:@"STATE_READY"];
                } break;
                    
                case STATE_WORKING:
                {
                    NSLog(@"EVENT_STATE: %s", "WORKING");
                    [self getResultJsonWithCode:EVENT_STATE data:@"STATE_WORKING"];
                } break;
            }
        } break;
            
        case EVENT_WAKEUP:
        {
            //唤醒事件
            NSLog(@"EVENT_WAKEUP");
            [self getResultJsonWithCode:EVENT_WAKEUP data:@""];
        } break;
            
        case EVENT_SLEEP:
        {
            //休眠事件
            NSLog(@"EVENT_SLEEP");
            [self getResultJsonWithCode:EVENT_SLEEP data:event.info];
        } break;
            
        case EVENT_VAD:
        {
            switch (event.arg1)
            {
                case VAD_BOS:
                {
                        //前端点事件
                    NSLog(@"EVENT_VAD_BOS");
                    [self getResultJsonWithCode:EVENT_VAD data:@"VAD_BOS"];
                } break;
                    
                case VAD_EOS:
                {
                    //后端点事件
                    NSLog(@"EVENT_VAD_EOS");
                    [self getResultJsonWithCode:EVENT_VAD data:@"VAD_EOS"];
                } break;
                    
//                case VAD_VOL:
//                {
//                        //音量事件
//                    NSLog(@"vol: %d", event.arg2);
//                    [self getResultJsonWithCode:EVENT_VAD data:@"VAD_VOL"];
//                } break;
            }
        } break;
            
        case EVENT_RESULT:
        {
            NSLog(@"EVENT_RESULT");
            [self processResult:event];
        } break;
            
        case EVENT_CMD_RETURN:
        {
            NSLog(@"EVENT_CMD_RETURN");
        } break;
            
        case EVENT_ERROR:
        {
            NSString *error = [[NSString alloc] initWithFormat:@"Error Message：%@\nError Code：%d",event.info,event.arg1];
            NSLog(@"EVENT_ERROR: %@",error);
            
            [self getResultJsonWithCode:EVENT_ERROR data:event.info];
        } break;
    }
}


//处理结果
- (void)processResult:(IFlyAIUIEvent *)event {
    
    NSString *info = event.info;
    NSData *infoData = [info dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *infoDic = [NSJSONSerialization JSONObjectWithData:infoData options:NSJSONReadingMutableContainers error:&err];
    if(!infoDic){
        NSLog(@"parse error! %@", info);
        return;
    }
    
    NSLog(@"infoDic = %@", infoDic);

    NSDictionary *data = [((NSArray *)[infoDic objectForKey:@"data"]) objectAtIndex:0];
    NSDictionary *params = [data objectForKey:@"params"];
    NSDictionary *content = [(NSArray *)[data objectForKey:@"content"] objectAtIndex:0];
    NSString *sub = [params objectForKey:@"sub"];
    
    if([sub isEqualToString:@"nlp"]){
        
        NSString *cnt_id = [content objectForKey:@"cnt_id"];
        if(!cnt_id){
            NSLog(@"Content Id is empty");
            return;
        }
        
        NSData *rltData = [event.data objectForKey:cnt_id];
        
        if(rltData){
            NSString *rltStr = [[NSString alloc]initWithData:rltData encoding:NSUTF8StringEncoding];
            
            
            NSDictionary *dic = [self dictionaryWithJsonString:[rltStr stringByReplacingOccurrencesOfString:@"\0" withString:@""]];
            
            if (dic != NULL) {
                if ([[dic allKeys] containsObject:@"intent"]) {
                    
                    [self getResultJsonWithCode:1 data:[self gs_jsonStringCompactFormatForDictionary:[dic objectForKey:@"intent"]]];

                }
            }
            
            NSLog(@"nlp result: %@", rltStr);
        }
    } else{
        
    }
}

//统一转成json字符串
- (void)getResultJsonWithCode:(NSInteger)code data:(NSString *)data {
    
    NSMutableDictionary *reDic = [NSMutableDictionary dictionary];
    
    [reDic setValue:@(code) forKey:@"code"];
    [reDic setValue:data forKey:@"data"];
 
    NSError*parseError =nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:reDic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    NSString *returnStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    [[DtAiUiFlutterStreamManager sharedInstance] streamHandler].eventSink(returnStr);

}


- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (NSString *)gs_jsonStringCompactFormatForDictionary:(NSDictionary *)dicJson {

    

    if (![dicJson isKindOfClass:[NSDictionary class]] || ![NSJSONSerialization isValidJSONObject:dicJson]) {

        return nil;

    }

    

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicJson options:0 error:nil];

    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    return strJson;

}



@end
