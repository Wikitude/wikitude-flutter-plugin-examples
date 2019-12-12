//
//  WikitudePlugin.m
//  wikitude_plugin
//
//  Created by Damian Bermejo on 22/03/2019.
//  Copyright (c) 2019 Wikitude. All rights reserved.
//

#import "WikitudePlugin.h"

#import "ArchitectWidgetFactory.h"
#import "WikitudePluginResponse.h"

typedef NS_ENUM(NSUInteger, WTFlutterMethodCall) {
    WTFlutterMethodCall_GetSDKVersion,
    WTFlutterMethodCall_GetSDKBuildInformation,
    WTFlutterMethodCall_IsDeviceSupporting,
    WTFlutterMethodCall_RequestARPermissions,
    WTFlutterMethodCall_OpenAppSettings
};

//------------ Required Features - begin -------

NSString * const kWTWikitudePlugin_requiredFeature_ImageTracking = @"image_tracking";
NSString * const kWTWikitudePlugin_requiredFeature_ObjectTracking = @"object_tracking";
NSString * const kWTWikitudePlugin_requiredFeature_InstantTracking = @"instant_tracking";
NSString * const kWTWikitudePlugin_requiredFeature_Geo = @"geo";
NSString * const kWTWikitudePlugin_requiredFeature_PhotoLibraryScreenshotImport = @"photo_library_screenshot_import";

//------------ Required Features - begin -------

//------------ Start-up Configuration - begin -------

NSString * const kWTWikitudePlugin_ArgumentIOSConfiguration         = @"iOS";

NSString * const kWTWikitudePlugin_ArgumentCaptureDeviceResolution  = @"camera_resolution";
NSString * const kWTWikitudePlugin_captureDeviceResolution_SD_640x480 = @"sd_640x480";
NSString * const kWTWikitudePlugin_captureDeviceResolution_HD_1280x720 = @"hd_1280x720";
NSString * const kWTWikitudePlugin_captureDeviceResolution_FULL_HD_1920x1080 = @"full_hd_1920x1080";
NSString * const kWTWikitudePlugin_captureDeviceResolution_AUTO     = @"auto";

NSString * const kWTWikitudePlugin_ArgumentCameraPosition           = @"camera_position";
NSString * const kWTWikitudePlugin_cameraPosition_Undefined         = @"undefined";
NSString * const kWTWikitudePlugin_cameraPosition_Front             = @"front";
NSString * const kWTWikitudePlugin_cameraPosition_Back              = @"back";

NSString * const kWTWikitudePlugin_ArgumentCameraFocusMode          = @"camera_focus_mode";
NSString * const kWTWikitudePlugin_cameraFocusMode_Locked           = @"off";
NSString * const kWTWikitudePlugin_cameraFocusMode_AutoFocus        = @"once";
NSString * const kWTWikitudePlugin_cameraFocusMode_ContinuousAutoFocus = @"continuous";

NSString * const kWTWikitudePlugin_ArgumentCaptureDeviceFocusDistance = @"camera_focus_distance";

NSString * const kWTWikitudePlugin_ArgumentCaptureDeviceFocusRangeRestriction = @"camera_focus_range_restriction";
NSString * const kWTWikitudePlugin_cameraFocusRange_None            = @"none";
NSString * const kWTWikitudePlugin_cameraFocusRange_Near            = @"near";
NSString * const kWTWikitudePlugin_cameraFocusRange_Far             = @"far";

NSString * const kWTWikitudePlugin_ArgumentSystemDeviceSensorCalibrationDisplay     = @"should_use_system_device_sensor_calibration_display";
NSString * const kWTWikitudePlugin_useSystemDeviceSensorCalibrationDisplay_NO       = @"NO";
NSString * const kWTWikitudePlugin_useSystemDeviceSensorCalibrationDisplay_YES      = @"YES";

//------------ Start-up Configuration - end ---------

@interface WikitudePlugin()

@property (nonatomic, strong) NSArray *flutterMethodCallsArray;
@property (nonatomic, strong) WTAuthorizationRequestManager *augmentedRealityAuthenticationRequestManager;

@end

@implementation WikitudePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar
{
    FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"wikitude_plugin"
            binaryMessenger:[registrar messenger]];
    WikitudePlugin* instance = [[WikitudePlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    ArchitectWidgetFactory* architectViewFactory =
    [[ArchitectWidgetFactory alloc] initWithRegistrar:registrar];
    [registrar registerViewFactory:architectViewFactory withId:@"architectwidget"];
}

- (instancetype)init
{
    self = [super init];

    if ( self )
    {
        _flutterMethodCallsArray = @[@"getSDKVersion", @"getSDKBuildInformation", @"isDeviceSupporting", @"requestARPermissions", @"openAppSettings"];
        _augmentedRealityAuthenticationRequestManager = [[WTAuthorizationRequestManager alloc] init];
    }

    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result
{
    NSUInteger methodCallIndex = [self.flutterMethodCallsArray indexOfObject:call.method];

    switch (methodCallIndex) {
        case WTFlutterMethodCall_GetSDKVersion:
            result([self getSDKVersion]);
            break;
        case WTFlutterMethodCall_GetSDKBuildInformation:
            result([self getSDKBuildInformation]);
            break;
        case WTFlutterMethodCall_IsDeviceSupporting:
            result([self isDeviceSupportingFeatures:call.arguments]);
            break;
        case WTFlutterMethodCall_RequestARPermissions:
            [self requestARPermissions:call.arguments forFlutterResult:result];
            break;
        case WTFlutterMethodCall_OpenAppSettings:
            [self openAppSettings];
            break;

        default:
            result(FlutterMethodNotImplemented);
            break;
    }
}

- (NSString*)getSDKVersion
{
    return [WTArchitectView sdkVersion];
}

- (NSString*)getSDKBuildInformation
{
    WTSDKBuildInformation *buildInformation = [WTArchitectView SDKBuildInformation];

    NSDictionary *responseDictionary = @{ @"buildConfiguration": buildInformation.buildConfiguration,
                                        @"buildNumber": buildInformation.buildNumber,
                                        @"buildDate": buildInformation.buildDate
                                        };

    NSString *response = [WikitudePluginResponse createJSONStringFromDictionary:responseDictionary];
    return response;
}

- (NSString*)isDeviceSupportingFeatures:(id)requiredFeaturesArray
{
    WTFeatures requiredFeatures = [WikitudePlugin featuresFromArray:requiredFeaturesArray];

    NSError *error;
    NSDictionary *responseDictionary;
    if ( ![WTArchitectView isDeviceSupportingFeatures:requiredFeatures error:&error] )
    {
        NSNumber *success = @(NO);
        NSString *errorMessage = @"";

        if (error)
        {
            errorMessage = error.localizedDescription;
        }

        responseDictionary = @{ @"success":success, @"message":errorMessage };
    }
    else
    {
        NSNumber *success = @(YES);
        responseDictionary = @{ @"success":success, @"message":@"" };
    }

    NSString *response = [WikitudePluginResponse createJSONStringFromDictionary:responseDictionary];
    return response;
}

- (void)requestARPermissions:(id)requiredFeaturesArray forFlutterResult:(FlutterResult)result
{
    if ( !self.augmentedRealityAuthenticationRequestManager.isRequestingRestrictedAppleiOSSDKAPIAuthorization )
    {
        WTFeatures requiredFeatures = [WikitudePlugin featuresFromArray:requiredFeaturesArray];
        NSOrderedSet<NSNumber *> *restrictedAppleiOSSDKAPIs = [WTAuthorizationRequestManager restrictedAppleiOSSDKAPIAuthorizationsForRequiredFeatures:requiredFeatures];

        [self.augmentedRealityAuthenticationRequestManager requestRestrictedAppleiOSSDKAPIAuthorization:restrictedAppleiOSSDKAPIs completion:^(BOOL callSuccess, NSError * _Nonnull error) {
            NSNumber *success;
            NSDictionary *responseDictionary;

            if ( !callSuccess )
            {
                NSDictionary *unauthorizedAPIInfo = [[error userInfo] objectForKey:kWTUnauthorizedAppleiOSSDKAPIsKey];

                NSMutableString *detailedAuthorizationErrorLogMessage = [[NSMutableString alloc] initWithFormat:@"The following authorization states do not meet the requirements:"];
                NSMutableString *missingAuthorizations = [[NSMutableString alloc] initWithFormat:@"In order to use the Wikitude SDK, please grant access to the following:"];
                for (NSString *unauthorizedAPIKey in [unauthorizedAPIInfo allKeys])
                {
                    [missingAuthorizations appendFormat:@"\n* %@", [WTAuthorizationRequestManager humanReadableDescriptionForUnauthorizedAppleiOSSDKAPI:unauthorizedAPIKey]];

                    [detailedAuthorizationErrorLogMessage appendFormat:@"\n%@ = %@", unauthorizedAPIKey, [WTAuthorizationRequestManager stringFromAuthorizationStatus:[[unauthorizedAPIInfo objectForKey:unauthorizedAPIKey] integerValue] forUnauthorizedAppleiOSSDKAPI:unauthorizedAPIKey]];
                }

                NSLog(@"%@", detailedAuthorizationErrorLogMessage);

                success = @(NO);
                responseDictionary = @{ @"success":success, @"message":missingAuthorizations };
            }
            else
            {
                success = @(YES);
                responseDictionary = @{ @"success":success, @"message":@"" };
            }

            NSString *response = [WikitudePluginResponse createJSONStringFromDictionary:responseDictionary];
            result(response);
        }];
    }
}

- (void)openAppSettings
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
}

#pragma mark - Static methods
+ (WTFeatures)featuresFromArray:(id)featuresArray
{
    WTFeatures features = 0;
    if ( featuresArray )
    {
        if ( [featuresArray isKindOfClass:[NSArray class]] )
        {
            for ( NSString *featureString in featuresArray )
            {
                if ( [featureString isEqualToString:kWTWikitudePlugin_requiredFeature_ImageTracking] )
                {
                    features |= WTFeature_ImageTracking;
                }
                else if ( [featureString isEqualToString:kWTWikitudePlugin_requiredFeature_InstantTracking] )
                {
                    features |= WTFeature_InstantTracking;
                }
                else if ( [featureString isEqualToString:kWTWikitudePlugin_requiredFeature_ObjectTracking] )
                {
                    features |= WTFeature_ObjectTracking;
                }
                else if ( [featureString isEqualToString:kWTWikitudePlugin_requiredFeature_Geo] )
                {
                    features |= WTFeature_Geo;
                }
                else if ( [featureString isEqualToString:kWTWikitudePlugin_requiredFeature_PhotoLibraryScreenshotImport] )
                {
                    features |= WTFeature_PhotoLibraryScreenshotImport;
                }
                else
                {
                    NSLog(@"Unknown or unsupported feature definition found!");
                }
            }
        }
        else
        {
            NSLog(@"Required features are not an array. Unable to parse non array feature definitions.");
        }
    }
    else
    {
        NSLog(@"Unable to access required features for example");
    }

    return features;
}

+ (void)readStartupConfigurationFrom:(NSDictionary *)arguments andApplyTo:(WTStartupConfiguration *)configuration
{
    if ( arguments && configuration )
    {
        NSString* captureDeviceResolution = [arguments objectForKey:kWTWikitudePlugin_ArgumentCaptureDeviceResolution];
        if ( captureDeviceResolution )
        {
            if ( [kWTWikitudePlugin_captureDeviceResolution_SD_640x480 isEqualToString:captureDeviceResolution] )
            {
                configuration.captureDeviceResolution = WTCaptureDeviceResolution_SD_640x480;
            }
            else if ( [kWTWikitudePlugin_captureDeviceResolution_HD_1280x720 isEqualToString:captureDeviceResolution] )
            {
                configuration.captureDeviceResolution = WTCaptureDeviceResolution_HD_1280x720;
            }
            else if ( [kWTWikitudePlugin_captureDeviceResolution_FULL_HD_1920x1080 isEqualToString:captureDeviceResolution] )
            {
                configuration.captureDeviceResolution = WTCaptureDeviceResolution_FULL_HD_1920x1080;
            }
            else if ( [kWTWikitudePlugin_captureDeviceResolution_AUTO isEqualToString:captureDeviceResolution] )
            {
                configuration.captureDeviceResolution = WTCaptureDeviceResolution_AUTO;
            }
        }

        NSString *cameraPosition = [arguments objectForKey:kWTWikitudePlugin_ArgumentCameraPosition];
        if ( cameraPosition )
        {
            if ( [kWTWikitudePlugin_cameraPosition_Front isEqualToString:cameraPosition] )
            {
                configuration.captureDevicePosition = AVCaptureDevicePositionFront;
            }
            else if ( [kWTWikitudePlugin_cameraPosition_Back isEqualToString:cameraPosition] )
            {
                configuration.captureDevicePosition = AVCaptureDevicePositionBack;
            }
            else
            {
                configuration.captureDevicePosition = AVCaptureDevicePositionUnspecified;
            }
        }

        NSString *cameraFocusMode = [arguments objectForKey:kWTWikitudePlugin_ArgumentCameraFocusMode];
        if ( cameraFocusMode )
        {
            if ( [kWTWikitudePlugin_cameraFocusMode_Locked isEqualToString:cameraFocusMode] )
            {
                configuration.captureDeviceFocusMode = AVCaptureFocusModeLocked;
            }
            else if ( [kWTWikitudePlugin_cameraFocusMode_AutoFocus isEqualToString:cameraFocusMode] )
            {
                configuration.captureDeviceFocusMode = AVCaptureFocusModeAutoFocus;
            }
            else if ( [kWTWikitudePlugin_cameraFocusMode_ContinuousAutoFocus isEqualToString:cameraFocusMode] )
            {
                configuration.captureDeviceFocusMode = AVCaptureFocusModeContinuousAutoFocus;
            }
        }

        NSNumber *captureDeviceFocusDistance = [arguments objectForKey:kWTWikitudePlugin_ArgumentCaptureDeviceFocusDistance];
        if ( captureDeviceFocusDistance )
        {
            configuration.captureDeviceFocusDistance = captureDeviceFocusDistance.floatValue;
        }

        NSDictionary* iOSConfiguration = [arguments objectForKey:kWTWikitudePlugin_ArgumentIOSConfiguration];
        if ( iOSConfiguration )
        {
            NSString *captureDeviceFocusRestriction = [iOSConfiguration objectForKey:kWTWikitudePlugin_ArgumentCaptureDeviceFocusRangeRestriction];
            if ( captureDeviceFocusRestriction )
            {
                if ( [kWTWikitudePlugin_cameraFocusRange_None isEqualToString:captureDeviceFocusRestriction] )
                {
                    configuration.captureDeviceFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNone;
                }
                else if ( [kWTWikitudePlugin_cameraFocusRange_Near isEqualToString:captureDeviceFocusRestriction] )
                {
                    configuration.captureDeviceFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;
                }
                else if ( [kWTWikitudePlugin_cameraFocusRange_Far isEqualToString:captureDeviceFocusRestriction] )
                {
                    configuration.captureDeviceFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionFar;
                }
            }

            NSString *systemDeviceSensorCalibrationSetting = [iOSConfiguration objectForKey:kWTWikitudePlugin_ArgumentSystemDeviceSensorCalibrationDisplay];
            if ( systemDeviceSensorCalibrationSetting )
            {
                if ( [kWTWikitudePlugin_useSystemDeviceSensorCalibrationDisplay_NO isEqualToString:systemDeviceSensorCalibrationSetting] )
                {
                    configuration.shouldUseSystemDeviceSensorCalibrationDisplay = NO;
                }
                else if ( [kWTWikitudePlugin_useSystemDeviceSensorCalibrationDisplay_YES isEqualToString:systemDeviceSensorCalibrationSetting] )
                {
                    configuration.shouldUseSystemDeviceSensorCalibrationDisplay = YES;
                }
            }
        }
    }
}
@end
