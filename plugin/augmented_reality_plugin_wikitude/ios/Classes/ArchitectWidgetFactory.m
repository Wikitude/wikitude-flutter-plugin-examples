//
//  ArchitectWidgetFactory.m
//  wikitude_plugin
//
//  Created by Damian Bermejo on 22/03/2019.
//  Copyright (c) 2019 Wikitude. All rights reserved.
//

#import "ArchitectWidgetFactory.h"

#import "ArchitectWidget.h"

@interface ArchitectWidgetFactory()

    @property NSObject<FlutterPluginRegistrar> *registrar;

@end

@implementation ArchitectWidgetFactory

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar
{
    self = [super init];
    if (self)
    {
        _registrar = registrar;
    }
    return self;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec
{
    return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args
{
    return [[ArchitectWidget alloc] initWithFrame:frame viewIdentifier:viewId arguments:args registrar:self.registrar];
}

@end
