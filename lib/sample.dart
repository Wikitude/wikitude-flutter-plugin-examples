import 'package:augmented_reality_plugin_wikitude/startupConfiguration.dart';

class Sample {

  List<String> requiredExtensions;
  String name;
  String path;
  List<String> requiredFeatures;
  StartupConfiguration startupConfiguration;
  
  Sample({this.requiredExtensions, this.name, this.path, this.requiredFeatures, this.startupConfiguration});

  factory Sample.fromJson(Map<String, dynamic> jsonMap){
    var requiredExtensionsFromJson = jsonMap['required_extensions'];
    List<String> requiredExtensionsList = new List();
    if(requiredExtensionsFromJson != null) {
      requiredExtensionsList = new List<String>.from(requiredExtensionsFromJson);
    }

    var requiredFeaturesFromJson = jsonMap['requiredFeatures'];
    List<String> requiredFeaturesList = new List();
    if(requiredFeaturesFromJson != null) {
      requiredFeaturesList = new List<String>.from(requiredFeaturesFromJson);
    }

    var exampleStartupConfiguration = jsonMap['startupConfiguration'];
    StartupConfiguration startupConfigurationItem;
    if(exampleStartupConfiguration != null) {
      CameraPosition cameraPosition;
      switch(exampleStartupConfiguration["camera_position"]) {
        case "back": cameraPosition = CameraPosition.BACK;
          break;
        case "front": cameraPosition = CameraPosition.FRONT;
          break;
        case "default": cameraPosition = CameraPosition.DEFAULT;
          break;
      }

      CameraResolution cameraResolution;
      switch(exampleStartupConfiguration["camera_resolution"]) {
        case "sd_640x480": cameraResolution = CameraResolution.SD_640x480;
          break;
        case "hd_1280x720": cameraResolution = CameraResolution.HD_1280x720;
          break;
        case "full_hd_1920x1080": cameraResolution = CameraResolution.FULL_HD_1920x1080;
          break;
        case "auto": cameraResolution = CameraResolution.AUTO;
          break;
      }

      CameraFocusMode cameraFocusMode;
      switch(exampleStartupConfiguration["camera_focus_mode"]) {
        case "once": cameraFocusMode = CameraFocusMode.ONCE;
          break;
        case "continuous": cameraFocusMode = CameraFocusMode.CONTINUOUS;
          break;
        case "off": cameraFocusMode = CameraFocusMode.OFF;
          break;
      }

      startupConfigurationItem = new StartupConfiguration(
        cameraPosition: cameraPosition,
        cameraResolution: cameraResolution,
        cameraFocusMode: cameraFocusMode
      );
    }

    return new Sample(
      requiredExtensions: requiredExtensionsList,
      name: jsonMap["name"],
      path: jsonMap["path"],
      requiredFeatures: requiredFeaturesList,
      startupConfiguration: startupConfigurationItem
    );
  }
}