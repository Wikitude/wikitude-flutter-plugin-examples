package com.wikitude.wikitude_plugin;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.provider.Settings;

import com.google.gson.Gson;
import com.wikitude.architect.ArchitectView;
import com.wikitude.common.CallStatus;
import com.wikitude.common.permission.PermissionManager;
import com.wikitude.common.util.SDKBuildInformation;

import java.util.ArrayList;
import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;

/** WikitudePlugin */
public class WikitudePlugin implements MethodCallHandler, RequestPermissionsResultListener {

  private static Activity activity;
  private static ArchitectFactory architectFactory;

  private Result permissionResult;

  private final PermissionManager permissionManager = ArchitectView.getPermissionManager();

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    activity = registrar.activity();
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "wikitude_plugin");
    WikitudePlugin wikitudePlugin = new WikitudePlugin();
    channel.setMethodCallHandler(wikitudePlugin);

    registrar.addRequestPermissionsResultListener(wikitudePlugin);

    if (activity != null) {
      architectFactory = new ArchitectFactory(registrar, activity);
      registrar
              .platformViewRegistry()
              .registerViewFactory(
                      "architectwidget", architectFactory);
    }
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    switch (call.method) {
      case "isDeviceSupporting":
        result.success(isDeviceSupporting((List<String>)call.arguments));
        break;
      case "requestARPermissions":
        permissionRequest(result, (List<String>)call.arguments);
        break;
      case "openAppSettings":
        openAppSettings();
        break;
      case "getSDKVersion":
        result.success(getSDKVersion());
        break;
      case "getSDKBuildInformation":
        result.success(getSDKBuildInformation());
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private String isDeviceSupporting(List<String> features) {
    final CallStatus callStatus = ArchitectView.isDeviceSupporting(activity.getApplicationContext(), FeaturesHelper.convertArFeatures(features));
    Response response;
    if(callStatus.isSuccess()) {
      response = new Response(callStatus.isSuccess(), "");
    }
    else {
      response = new Response(callStatus.isSuccess(), callStatus.getError().getMessage());
    }
    return new Gson().toJson(response);
  }

  private void permissionRequest(final Result result, List<String> features) {
    permissionResult = result;
    final String[] permissions = PermissionUtil.getPermissionsForArFeatures(FeaturesHelper.convertArFeatures(features));
    permissionManager.checkPermissions(activity, permissions, PermissionManager.WIKITUDE_PERMISSION_REQUEST, new PermissionManager.PermissionManagerCallback() {
      @Override
      public void permissionsGranted(int i) {
        Response response = new Response(true, "");
        result.success(new Gson().toJson(response));
      }

      @Override
      public void permissionsDenied(String[] strings) {
        Response response = new Response(false, PermissionUtil.getPermissionErrorText(strings).toString());
        result.success(new Gson().toJson(response));
      }

      @Override
      public void showPermissionRationale(int i, String[] strings) {
        Response response = new Response(false, PermissionUtil.getPermissionErrorText(strings).toString());
        result.success(new Gson().toJson(response));
      }
    });
  }

  private void openAppSettings() {
    final Intent i = new Intent();
    i.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
    i.addCategory(Intent.CATEGORY_DEFAULT);
    i.setData(Uri.parse("package:" + activity.getPackageName()));
    i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    i.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY);
    i.addFlags(Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS);
    activity.startActivity(i);
  }

  private String getSDKVersion() {
    return ArchitectView.getSDKVersion();
  }

  private String getSDKBuildInformation() {
    final SDKBuildInformation info = ArchitectView.getSDKBuildInformation();
    BuildInformationResponse buildInformationResponse = new BuildInformationResponse(info.getBuildConfiguration(), info.getBuildNumber(), info.getBuildDate());
    return new Gson().toJson(buildInformationResponse);
  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    ArrayList<String> deniedPermissions = new ArrayList<>();
    for (int i = 0; i < permissions.length; i++) {
      if (grantResults.length > 0 && grantResults[i] != PackageManager.PERMISSION_GRANTED) {
        deniedPermissions.add(permissions[i]);
      }
    }

    if (deniedPermissions.size() > 0) {
      String[] deniedPermissionsArray = new String[deniedPermissions.size()];
      deniedPermissionsArray = deniedPermissions.toArray(deniedPermissionsArray);

      if (permissionResult != null && requestCode == PermissionManager.WIKITUDE_PERMISSION_REQUEST) {
        Response response = new Response(false, PermissionUtil.getPermissionErrorText(deniedPermissionsArray).toString());
        permissionResult.success(new Gson().toJson(response));
      } else if (requestCode == architectFactory.getExternalStoragePermissionRequestCode()) {
        architectFactory.captureScreenError(PermissionUtil.getPermissionErrorText(deniedPermissionsArray).toString());
      }
    } else {
      if (permissionResult != null && requestCode == PermissionManager.WIKITUDE_PERMISSION_REQUEST) {
        Response response = new Response(true, "");
        permissionResult.success(new Gson().toJson(response));
      } else if (requestCode == architectFactory.getExternalStoragePermissionRequestCode()) {
        architectFactory.captureScreen();
      }
    }

    return true;
  }
}
