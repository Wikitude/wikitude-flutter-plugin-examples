//
//  ArchitectWidgetFactory.h
//  wikitude_plugin
//
//  Created by Damian Bermejo on 22/03/2019.
//  Copyright (c) 2019 Wikitude. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface ArchitectWidgetFactory : NSObject <FlutterPlatformViewFactory>

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;

@end

NS_ASSUME_NONNULL_END
