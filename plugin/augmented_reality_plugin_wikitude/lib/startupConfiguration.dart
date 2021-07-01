enum CameraPosition { BACK, FRONT, DEFAULT }
enum CameraFocusMode { ONCE, CONTINUOUS, OFF }
enum CameraResolution { SD_640x480, HD_1280x720, FULL_HD_1920x1080, AUTO }

class StartupConfiguration {

  CameraPosition? cameraPosition = CameraPosition.BACK;
  CameraFocusMode? cameraFocusMode = CameraFocusMode.CONTINUOUS;
  CameraResolution? cameraResolution = CameraResolution.AUTO;

  StartupConfiguration({this.cameraPosition, this.cameraFocusMode, this.cameraResolution});
}