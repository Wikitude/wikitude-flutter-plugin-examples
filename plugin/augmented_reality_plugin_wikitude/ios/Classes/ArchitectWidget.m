//
//  ArchitectWidget.m
//  wikitude_plugin
//
//  Created by Damian Bermejo on 22/03/2019.
//  Copyright (c) 2019 Wikitude. All rights reserved.
//

#import "ArchitectWidget.h"

#import "WikitudePlugin.h"
#import "WikitudePluginResponse.h"

typedef NS_ENUM(NSUInteger, WTFlutterMethodCall) {
    WTFlutterMethodCall_Load,
    WTFlutterMethodCall_OnPause,
    WTFlutterMethodCall_OnResume,
    WTFlutterMethodCall_OnDestroy,
    WTFlutterMethodCall_SetLocation,
    WTFlutterMethodCall_CallJavaScript,
    WTFlutterMethodCall_AddArchitectJavaScriptInterfaceListener,
    WTFlutterMethodCall_CaptureScreen
};

NSString * const kWTArchitectWidget_ArgumentLicenseKey               = @"license_key";
NSString * const kWTArchitectWidget_ArgumentFeatures                 = @"features";

@interface ArchitectWidget()

@property (nonatomic) int64_t viewId;
@property (nonatomic, strong) NSArray *flutterMethodCallsArray;
@property (nonatomic, strong) NSDictionary *startupConfiguration;

@property (nonatomic) WTFeatures features;
@property (nonatomic, strong) WTArchitectView *architectView;
@property (nonatomic, strong) WTNavigation *loadingArchitectWorldNavigation;
@property (nonatomic, strong) WTNavigation *loadedArchitectWorldNavigation;

@property (nonatomic, strong) FlutterMethodChannel *channel;
@property (nonatomic, strong) NSObject<FlutterPluginRegistrar> *registrar;
@property (nonatomic, strong) FlutterResult captureScreenResult;

@end

@implementation ArchitectWidget

- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args registrar:(NSObject<FlutterPluginRegistrar> *)registrar
{
    if ([super init])
    {
        _viewId = viewId;
        _flutterMethodCallsArray = @[@"load",@"onPause", @"onResume", @"onDestroy", @"setLocation", @"callJavascript",
                                     @"addArchitectJavaScriptInterfaceListener", @"captureScreen"];

        if ( args && [args isKindOfClass:[NSDictionary class]] )
        {
            _startupConfiguration = [[NSDictionary alloc] initWithDictionary:args];

            _features = 0;
            if ( args[kWTArchitectWidget_ArgumentFeatures] )
            {
                _features = [WikitudePlugin featuresFromArray:args[kWTArchitectWidget_ArgumentFeatures]];
            }
        }

        _architectView = [[WTArchitectView alloc] initWithFrame:frame];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ( [_architectView respondsToSelector:@selector(setSDKOrigin:)] ) {
            [_architectView performSelector:@selector(setSDKOrigin:) withObject:@"ORIGIN_FLUTTER"];
        }
#pragma clang diagnostic pop

        NSString *licenseKey = @"";
        if ( _startupConfiguration[kWTArchitectWidget_ArgumentLicenseKey] )
        {
            licenseKey = _startupConfiguration[kWTArchitectWidget_ArgumentLicenseKey];
        }
        [_architectView setLicenseKey:licenseKey];
        [_architectView setDelegate:self];

        NSString* channelName = [NSString stringWithFormat:@"architectwidget_%lld", viewId];
        _registrar = registrar;
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:_registrar.messenger];
        _captureScreenResult = nil;

        __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
            [weakSelf handleMethodCall:call result:result];
        }];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveApplicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIView*)view
{
    return _architectView;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result
{
    NSUInteger methodCallIndex = [self.flutterMethodCallsArray indexOfObject:call.method];

    switch (methodCallIndex) {
        case WTFlutterMethodCall_Load:
            [self onLoad:call result:result];
            break;
        case WTFlutterMethodCall_OnPause:
            [self onPause:call result:result];
            break;
        case WTFlutterMethodCall_OnResume:
            [self onResume:call result:result];
            break;
        case WTFlutterMethodCall_OnDestroy:
            [self onDestroy:call result:result];
            break;
        case WTFlutterMethodCall_SetLocation:
            [self setLocation:call result:result];
            break;
        case WTFlutterMethodCall_CallJavaScript:
            [self callJavascript:call result:result];
            break;
        case WTFlutterMethodCall_AddArchitectJavaScriptInterfaceListener:
            [self addArchitectJavaScriptInterfaceListener:call result:result];
            break;
        case WTFlutterMethodCall_CaptureScreen:
            [self captureScreen:call result:result];
            break;

        default:
            result(FlutterMethodNotImplemented);
            break;
    }
}

#pragma mark - Flutter methods
- (void)onLoad:(FlutterMethodCall*)call result:(FlutterResult)result
{
    NSString* url = [call arguments];
    [self loadArchitectWorld:url];
}

- (void)onPause:(FlutterMethodCall*)call result:(FlutterResult)result
{
    [self stopRendering];
}

- (void)onResume:(FlutterMethodCall*)call result:(FlutterResult)result
{
    [self startRendering];
}

- (void)onDestroy:(FlutterMethodCall*)call result:(FlutterResult)result
{
    [self.architectView removeFromSuperview];
    self.architectView = nil;
    self.captureScreenResult = nil;
}

- (void)setLocation:(FlutterMethodCall*)call result:(FlutterResult)result
{
    if ( [call.arguments isKindOfClass:[NSMutableDictionary class]] )
    {
        NSDictionary *locationDictionary = call.arguments;
        double lat = [locationDictionary[@"lat"] doubleValue];
        double lon = [locationDictionary[@"lon"] doubleValue];
        double alt = [locationDictionary[@"alt"] doubleValue];
        double accuracy = [locationDictionary[@"accuracy"] doubleValue];

        [self.architectView setUseInjectedLocation:YES];

        if (alt <= 0)
        {
            [self.architectView injectLocationWithLatitude:lat longitude:lon accuracy:accuracy];
        }
        else
        {
            [self.architectView injectLocationWithLatitude:lat longitude:lon altitude:alt accuracy:accuracy];
        }
    }
    else
    {
        NSLog(@"Invalid Flutter input for method %@", call.method);
    }
}

- (void)callJavascript:(FlutterMethodCall*)call result:(FlutterResult)result
{
    [self.architectView callJavaScript:call.arguments];
}

- (void)addArchitectJavaScriptInterfaceListener:(FlutterMethodCall*)call result:(FlutterResult)result
{
    /*
    Required for Android, not for iOS.
    In iOS, JavaScript callbacks are handled through receivedJSONObject: from WTArchitectViewDelegate.
    Method intentionally left blank.
    */
}

- (void)captureScreen:(FlutterMethodCall*)call result:(FlutterResult)result
{
    /* Save Flutter context to respond from the proper execution point */
    self.captureScreenResult = result;

    WTScreenshotCaptureMode captureMode = WTScreenshotCaptureMode_CamAndWebView;
    if ( ![call.arguments[@"mode"] boolValue] )
    {
        captureMode = WTScreenshotCaptureMode_Cam;
    }

    NSString *screenshotName = @"";
    if ( [call.arguments[@"name"] isKindOfClass:[NSString class]] )
    {
        screenshotName = [NSString stringWithFormat:@"%@", call.arguments[@"name"]];
    }

    NSDictionary *context = nil;
    WTScreenshotSaveMode saveMode = WTScreenshotSaveMode_PhotoLibrary;
    if ( [screenshotName length] > 0 )
    {
        saveMode = WTScreenshotSaveMode_BundleDirectory;
        context = @{kWTScreenshotBundleDirectoryKey: screenshotName};
    }

    WTScreenshotSaveOptions saveOptions = WTScreenshotSaveOption_CallDelegateOnSuccess;

    [self.architectView captureScreenWithMode:captureMode usingSaveMode:saveMode saveOptions:saveOptions context:context];
}

#pragma mark - ArchitectView handling
- (void)loadArchitectWorld:(NSString*)urlString
{
    /* Escape special characters in the URL */
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSURL *architectWorldURL = [NSURL URLWithString:urlString];

    /* If the URL has no scheme, look for the AR world in the local resources */
    if ( ![architectWorldURL scheme] )
    {
        NSString *worldName = [urlString lastPathComponent];
        NSString *architectWorldDirectoryPath;

        /* If the URL comes from internal storage, search for the AR world in the Application Support directory */
        if ( [urlString containsString:NSHomeDirectory()])
        {
            NSURL *applicationSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] firstObject];
            NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]
                                                 enumeratorAtURL:applicationSupportURL
                                                 includingPropertiesForKeys:nil
                                                 options:(NSDirectoryEnumerationSkipsPackageDescendants |
                                                          NSDirectoryEnumerationSkipsHiddenFiles)
                                                 errorHandler:nil];

            for (NSURL *url in enumerator) {
                if ([[url absoluteString] containsString:worldName]) {
                    architectWorldURL = url;
                    break;
                }
            }
        }
        /* Otherwise, search for the AR world in the bundle resources */
        else
        {
            worldName = [worldName stringByDeletingPathExtension];
            NSString *worldNameExtension = [urlString pathExtension];

            NSString *assetKey = [_registrar lookupKeyForAsset:urlString];
            architectWorldDirectoryPath = [assetKey stringByDeletingLastPathComponent];

            architectWorldURL = [[NSBundle mainBundle] URLForResource:worldName withExtension:worldNameExtension subdirectory:architectWorldDirectoryPath];
        }
    }

    self.loadingArchitectWorldNavigation = [_architectView loadArchitectWorldFromURL:architectWorldURL];
}

- (void)startRendering {
    if ( ![self.architectView isRunning] )
    {
        __weak ArchitectWidget *weakSelf = self;
        [self.architectView start:^(WTArchitectStartupConfiguration * _Nonnull configuration) {
            [WikitudePlugin readStartupConfigurationFrom:weakSelf.startupConfiguration andApplyTo:configuration];
        } completion:^(BOOL isRunning, NSError * _Nonnull error) {
            if ( error )
            {
                NSLog(@"Unable to run AR experience. Error: %@", error.localizedDescription);
            }
        }];
    }
}

- (void)stopRendering
{
    if ( [_architectView isRunning] )
    {
        [_architectView stop];
    }
}

#pragma mark - Notifications
- (void)didReceiveApplicationWillResignActiveNotification:(NSNotification *)notification
{
    [self stopRendering];
}

- (void)didReceiveApplicationDidBecomeActiveNotification:(NSNotification *)notification
{
    [self startRendering];
}

#pragma mark - Delegation
#pragma mark WTArchitectView

/* This architect view delegate method is used to keep the currently loaded architect world url. Every time this view becomes visible again, the controller checks if the current url is not equal to the new one and then loads the architect world */
- (void)architectView:(WTArchitectView *)architectView didFinishLoadArchitectWorldNavigation:(WTNavigation *)navigation
{
    if ( [self.loadingArchitectWorldNavigation isEqual:navigation] )
    {
        self.loadedArchitectWorldNavigation = navigation;

        [self.channel invokeMethod:@"onWorldLoaded" arguments:@""];
    }
}

- (void)architectView:(WTArchitectView *)architectView didFailToLoadArchitectWorldNavigation:(WTNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"architect view '%@' \ndid fail to load navigation '%@' \nwith error '%@'", architectView, navigation, error);

    [self.channel invokeMethod:@"onWorldLoadFailed" arguments:error.localizedDescription];
}

- (void)architectView:(WTArchitectView *)architectView receivedJSONObject:(NSDictionary *)jsonObject
{
    NSError *serializationError;
    NSData *responseData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&serializationError];
    NSString* JSONString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

    [self.channel invokeMethod:@"jsonObjectReceived" arguments:JSONString];
}

- (void)architectView:(WTArchitectView *)architectView didCaptureScreenWithContext:(NSDictionary *)context
{
    WTScreenshotSaveMode saveMode = [context[@"kWTScreenshotSaveModeKey"] integerValue];
    NSNumber *success = @(YES);
    NSString *message = @"";

    if ( saveMode == WTScreenshotSaveMode_BundleDirectory )
    {
        message = [context objectForKey:kWTScreenshotBundleDirectoryKey];
    }
    else if ( saveMode == WTScreenshotSaveMode_PhotoLibrary )
    {
        NSError *error = context[@"kWTScreenshotSaveErrorKey"];
        if ( error )
        {
            success = @(NO);
            message = error.localizedDescription;
        }
        else
        {
            success = @(YES);
            message = @"Photo library";
        }
    }
    else
    {
        success = @(NO);
        message = @"Invalid save mode, captured screen could not be saved";
        NSLog(@"%@", message);
    }

    NSDictionary *responseDictionary = @{@"success":success, @"message":message};
    NSString *response = [WikitudePluginResponse createJSONStringFromDictionary:responseDictionary];

    if ( self.captureScreenResult )
    {
        self.captureScreenResult(response);
        self.captureScreenResult = nil;
    }
}

- (void)architectView:(WTArchitectView *)architectView didFailCaptureScreenWithError:(NSError *)error
{
    NSString *errorMessage = [NSString stringWithFormat:@"Internal error while capturing screen: %@", error.localizedDescription];
    NSLog(@"%@", errorMessage);

    NSDictionary *responseDictionary = @{@"success":@(NO), @"message":errorMessage};

    NSString *response = [WikitudePluginResponse createJSONStringFromDictionary:responseDictionary];

    if ( self.captureScreenResult )
    {
        self.captureScreenResult(response);
        self.captureScreenResult = nil;
    }
}

/* Use this method to implement/show your own custom device sensor calibration mechanism.
 *  You can also use the system calibration screen, but pls. read the WTStartupConfiguration documentation for more details.
 */
- (void)architectViewNeedsDeviceSensorCalibration:(WTArchitectView *)architectView
{
    NSLog(@"Device sensor calibration needed. Rotate the device 360 degree around it's Y-Axis");
}

/* When this method is called, the device sensors are calibrated enough to deliver accurate values again.
 * In case a custom calibration screen was shown, it can now be dismissed.
 */
- (void)architectViewFinishedDeviceSensorsCalibration:(WTArchitectView *)architectView
{
    NSLog(@"Device sensors calibrated");
}

@end

