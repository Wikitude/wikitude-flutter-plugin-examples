enum CameraPosition { BACK, FRONT, DEFAULT }
enum CameraFocusMode { ONCE, CONTINUOUS, OFF }
enum CameraResolution { SD_640x480, HD_1280x720, FULL_HD_1920x1080, AUTO }

class StartupConfiguration {

  CameraPosition cameraPosition;
  CameraFocusMode cameraFocusMode;
  CameraResolution cameraResolution;

  StartupConfiguration({this.cameraPosition, this.cameraFocusMode, this.cameraResolution});
}