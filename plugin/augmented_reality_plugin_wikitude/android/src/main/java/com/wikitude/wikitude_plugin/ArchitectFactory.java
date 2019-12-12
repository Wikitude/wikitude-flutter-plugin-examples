package com.wikitude.wikitude_plugin;

import android.app.Activity;
import android.content.Context;

import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

import static io.flutter.plugin.common.PluginRegistry.Registrar;

public class ArchitectFactory extends PlatformViewFactory {

    private final Registrar mPluginRegistrar;
    private final Activity activity;

    private ArchitectWidget architectWidget;

    public ArchitectFactory(Registrar registrar, Activity activity) {
        super(StandardMessageCodec.INSTANCE);
        mPluginRegistrar = registrar;
        this.activity = activity;
    }

    @Override
    public PlatformView create(Context context, int i, Object o) {
        architectWidget = new ArchitectWidget(activity, mPluginRegistrar, i, o);
        return architectWidget;
    }

    void captureScreen() {
        architectWidget.captureScreen();
    }

    void captureScreenError(String error) {
        architectWidget.captureScreenError(error);
    }

    int getExternalStoragePermissionRequestCode() {
        return architectWidget.getExternalStoragePermissionRequestCode();
    }

}