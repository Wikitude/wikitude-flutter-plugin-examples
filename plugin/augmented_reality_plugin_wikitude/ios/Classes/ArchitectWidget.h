//
//  ArchitectWidget.h
//  wikitude_plugin
//
//  Created by Damian Bermejo on 22/03/2019.
//  Copyright (c) 2019 Wikitude. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Flutter/Flutter.h>
#import <WikitudeSDK/WikitudeSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ArchitectWidget : NSObject <FlutterPlatformView, WTArchitectViewDelegate>

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
                    registrar:(NSObject<FlutterPluginRegistrar>*)registrar;

- (UIView*)view;

@end

NS_ASSUME_NONNULL_END
