import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:augmented_reality_plugin_wikitude/wikitude_response.dart';

import 'startupConfiguration.dart';

typedef void ArchitectWidgetCreatedCallback();
typedef void OnJSONObjectReceived(Map<String, dynamic> jsonObject);
typedef void OnWorldLoaded();
typedef void OnWorldLoadFailed(String error);

// ignore: must_be_immutable
class ArchitectWidget extends StatefulWidget {

  final ArchitectWidgetCreatedCallback onArchitectWidgetCreated;
  OnJSONObjectReceived? onJSONObjectReceived;
  OnWorldLoaded? onWorldLoaded;
  OnWorldLoadFailed? onWorldLoadFailed;
  _ArchitectWidgetState? _architectWidgetState;

  StartupConfiguration startupConfiguration;
  List<String> features;
  String licenseKey;

  ArchitectWidget({
    Key? key,
    required this.onArchitectWidgetCreated,
    required this.licenseKey,
    required this.startupConfiguration,
    required this.features
  });

  @override
  _ArchitectWidgetState createState() => _architectWidgetState = 
    new _ArchitectWidgetState(licenseKey, startupConfiguration, features);

  Future<void> load(String url, OnWorldLoaded? worldLoaded, OnWorldLoadFailed? worldLoadFailed) async {
    if (worldLoaded != null) onWorldLoaded = worldLoaded;
    if (worldLoadFailed != null) onWorldLoadFailed = worldLoadFailed;
    _architectWidgetState?.load(url);
  }

  Future<void> pause() async {
    _architectWidgetState?.pause();
  }

  Future<void> resume() async {
    _architectWidgetState?.resume();
  }

  Future<void> destroy() async {
    _architectWidgetState?.destroy();
  }
  
  Future<void> setLocation(double lat, double lon, double alt, double accuracy) async {
    _architectWidgetState?.setLocation(lat, lon, alt, accuracy);
  }

  Future<void> callJavascript(String jsCmd) async {
    _architectWidgetState?.callJavascript(jsCmd);
  }

  Future<void> setJSONObjectReceivedCallback(OnJSONObjectReceived jsonObjectReceived) async {
    onJSONObjectReceived = jsonObjectReceived;
    _architectWidgetState?.setJSONObjectReceivedCallback();
  }

  Future<WikitudeResponse> captureScreen(bool mode, String name) async {
    String captureScreenResponse = (await _architectWidgetState?.captureScreen(mode, name))!;
    Map<String, dynamic> captureScreenResponseMap = jsonDecode(captureScreenResponse);
    return new WikitudeResponse(
      success: captureScreenResponseMap["success"],
      message: captureScreenResponseMap["message"]
    );
  }

  Future<void> showAlert(String title, String message, [bool requestOpenSettings = false]) async {
    _architectWidgetState?.showAlert(title, message, requestOpenSettings);
  }

  Future<bool?> canWebViewGoBack() async {
    assert(defaultTargetPlatform == TargetPlatform.android, "CanWebViewGoBack() method is not available for $defaultTargetPlatform");
    return await _architectWidgetState?.canWebViewGoBack();
  }
}

class _ArchitectWidgetState extends State<ArchitectWidget> {
  MethodChannel? _channel;
  Map<String, dynamic> configuration = new Map();

  _ArchitectWidgetState(String licenseKey, StartupConfiguration startConfiguration, List<String> features) {
    switch(startConfiguration.cameraPosition) {
      case CameraPosition.BACK:
        this.configuration["camera_position"] = "back";
        break;
      case CameraPosition.FRONT:
        this.configuration["camera_position"] = "front";
        break;
      case CameraPosition.DEFAULT:
        this.configuration["camera_position"] = "default";
        break;
      default:
        this.configuration["camera_position"] = "default";
        break;
    }

    switch(startConfiguration.cameraResolution) {
      case CameraResolution.SD_640x480:
        this.configuration["camera_resolution"] = "sd_640x480";
        break;
      case CameraResolution.HD_1280x720:
        this.configuration["camera_resolution"] = "hd_1280x720";
        break;
      case CameraResolution.FULL_HD_1920x1080:
        this.configuration["camera_resolution"] = "full_hd_1920x1080";
        break;
      case CameraResolution.AUTO:
        this.configuration["camera_resolution"] = "auto";
        break;
      default:
        this.configuration["camera_resolution"] = "auto";
        break;
    }

    switch(startConfiguration.cameraFocusMode) {
      case CameraFocusMode.ONCE:
        this.configuration["camera_focus_mode"] = "once";
        break;
      case CameraFocusMode.CONTINUOUS:
        this.configuration["camera_focus_mode"] = "continuous";
        break;
      case CameraFocusMode.OFF:
        this.configuration["camera_focus_mode"] = "off";
        break;
      default:
        this.configuration["camera_focus_mode"] = "continuous";
        break;
    }

    this.configuration["license_key"] = licenseKey;
    this.configuration["features"] = features;
  }

  @override
  Widget build(BuildContext context) {
    if(defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'architectwidget',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: configuration,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if(defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'architectwidget',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: configuration,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return new Text('$defaultTargetPlatform is not yet supported by this plugin');
  }

  Future<void> onPlatformViewCreated(id) async {
    _channel =  new MethodChannel('architectwidget_$id');
    _channel?.setMethodCallHandler(_handleMethod);
    widget.onArchitectWidgetCreated();
  }

  Future<void> load(String url) async {
    assert(_channel != null);
    return _channel?.invokeMethod('load', url);
  }

  Future<void> pause() async {
    assert(_channel != null);
    return _channel?.invokeMethod('onPause');
  }

  Future<void> resume() async {
    assert(_channel != null);
    return _channel?.invokeMethod('onResume');
  }

  Future<void> destroy() async {
    assert(_channel != null);
    return _channel?.invokeMethod('onDestroy');
  }

  Future<void> setLocation(double lat, double lon, double alt, double accuracy) async {
    assert(_channel != null);
    return _channel?.invokeMethod('setLocation', {"lat": lat, "lon": lon, "alt": alt, "accuracy": accuracy});
  }

  Future<void> callJavascript(String jsCmd) async {
    assert(_channel != null);
    return _channel?.invokeMethod('callJavascript', jsCmd);
  }

  Future<void> setJSONObjectReceivedCallback() async {
    assert(_channel != null);
    return _channel?.invokeMethod('addArchitectJavaScriptInterfaceListener');
  }

  Future<String> captureScreen(bool mode, String name) async {
    assert(_channel != null);
    return await _channel?.invokeMethod('captureScreen', {"mode": mode, "name": name});
  }

  Future<String?> showAlert(String title, String message, [bool requestOpenSettings = false]) async {
    assert(_channel != null);
    return _channel?.invokeMethod('showAlert', {"title": title, "message": message, "requestOpenSettings": requestOpenSettings});
  }

  Future<bool?> canWebViewGoBack() async {
    assert(_channel != null);
    return _channel?.invokeMethod('canWebViewGoBack');
  }

  Future<void> _handleMethod(MethodCall call) async {
    switch(call.method) {
      case "jsonObjectReceived":
        if (widget.onJSONObjectReceived == null) {
          return;
        }
        widget.onJSONObjectReceived!(jsonDecode(call.arguments));
        break;
      case "onWorldLoaded":
        if (widget.onWorldLoaded == null) {
          return;
        }
        widget.onWorldLoaded!();
        break;
      case "onWorldLoadFailed":
        if (widget.onWorldLoadFailed == null) {
          return;
        }
        widget.onWorldLoadFailed!(call.arguments);
        break;
    }
  }
}