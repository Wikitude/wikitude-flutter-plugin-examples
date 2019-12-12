//
//  WikitudePlugin.h
//  wikitude_plugin
//
//  Created by Damian Bermejo on 22/03/2019.
//  Copyright (c) 2019 Wikitude. All rights reserved.
//

#import <Flutter/Flutter.h>

#import <WikitudeSDK/WikitudeSDK.h>

@interface WikitudePlugin : NSObject<FlutterPlugin>

+ (WTFeatures)featuresFromArray:(id)featuresArray;
+ (void)readStartupConfigurationFrom:(NSDictionary *)arguments andApplyTo:(WTStartupConfiguration *)configuration;

@end
