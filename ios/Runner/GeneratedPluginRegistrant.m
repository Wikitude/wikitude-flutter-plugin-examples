//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"

#if __has_include(<location/LocationPlugin.h>)
#import <location/LocationPlugin.h>
#else
@import location;
#endif

#if __has_include(<path_provider/FLTPathProviderPlugin.h>)
#import <path_provider/FLTPathProviderPlugin.h>
#else
@import path_provider;
#endif

#if __has_include(<wakelock/WakelockPlugin.h>)
#import <wakelock/WakelockPlugin.h>
#else
@import wakelock;
#endif

#if __has_include(<augmented_reality_plugin_wikitude/WikitudePlugin.h>)
#import <augmented_reality_plugin_wikitude/WikitudePlugin.h>
#else
@import augmented_reality_plugin_wikitude;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [LocationPlugin registerWithRegistrar:[registry registrarForPlugin:@"LocationPlugin"]];
  [FLTPathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPathProviderPlugin"]];
  [WakelockPlugin registerWithRegistrar:[registry registrarForPlugin:@"WakelockPlugin"]];
  [WikitudePlugin registerWithRegistrar:[registry registrarForPlugin:@"WikitudePlugin"]];
}

@end
