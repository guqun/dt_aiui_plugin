#import "DtAiuiPlugin.h"
#if __has_include(<dt_aiui_plugin/dt_aiui_plugin-Swift.h>)
#import <dt_aiui_plugin/dt_aiui_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "dt_aiui_plugin-Swift.h"
#endif

@implementation DtAiuiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDtAiuiPlugin registerWithRegistrar:registrar];
}
@end
