import 'dart:io';

import 'package:flutter/material.dart';

import 'arview.dart';
import 'sample.dart';

import 'package:augmented_reality_plugin_wikitude/wikitude_plugin.dart';
import 'package:augmented_reality_plugin_wikitude/wikitude_response.dart';
import 'package:augmented_reality_plugin_wikitude/startupConfiguration.dart';

class CustomUrl extends StatefulWidget {
  @override
  _CustomUrlState createState() => _CustomUrlState();
}

class _CustomUrlState extends State<CustomUrl> {

  final customWorldUrlText = TextEditingController();

  AppBar? get appBar {
    if (!Platform.isIOS) {
      return null;
    }
    return new AppBar(
      title: Text("Custom URL Launcher"),
    );
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    if (Platform.isIOS) statusBarHeight = 0;

    return Scaffold(
      appBar: this.appBar,
      body: Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: statusBarHeight),
        child: Column (
          children: <Widget>[
            TextField(
              controller: customWorldUrlText,
              decoration: InputDecoration(
                labelText: "World URL:"
              ),
            ),
            ButtonTheme(
              minWidth: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  if(customWorldUrlText.text.isEmpty) {
                    _showDialog("Error with URL", "Cannot load an empty url", context);
                    return;
                  }
                      
                  if(!customWorldUrlText.text.contains("http://") && !customWorldUrlText.text.contains("https://")) {
                    _showDialog("Error with URL", "The URL should start with http:// or https://", context);
                    return;
                  }

                  StartupConfiguration customUrlStartupConfiguration = new StartupConfiguration();
                  customUrlStartupConfiguration.cameraPosition = CameraPosition.BACK;

                  List<String> customUrlRequiredFeatures = [];
                  customUrlRequiredFeatures.add("image_tracking");
                  customUrlRequiredFeatures.add("geo");

                  WikitudeResponse response = await _isDeviceSupporting(customUrlRequiredFeatures);

                  if(!response.success) {
                    _showDialog("Device missing features", response.message, context);
                    return;
                  }

                  Sample sample = new Sample(requiredExtensions: [], name: "Custom URL", path: customWorldUrlText.text, requiredFeatures: customUrlRequiredFeatures, startupConfiguration: customUrlStartupConfiguration);

                  _pushArView(sample, context);
                },
                child: Text('Go to URL'),
              ),
            ),
          ]
        )
      ),
    );
  }

  Future<WikitudeResponse> _isDeviceSupporting(List<String> features) async {
    return await WikitudePlugin.isDeviceSupporting(features);
  }

  Future<WikitudeResponse> _requestARPermissions(List<String> features) async {
    return await WikitudePlugin.requestARPermissions(features);
  }

  Future<void> _pushArView(Sample sample, BuildContext context) async {
    WikitudeResponse permissionsResponse = await _requestARPermissions(sample.requiredFeatures);
    if(permissionsResponse.success) {
       Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ArViewWidget(sample: sample)),
      );
    } else {
      _showPermissionError(permissionsResponse.message, context);
    }
  }

  void _showDialog(String title, String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  void _showPermissionError(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permissions required"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open settings'),
              onPressed: () {
                Navigator.of(context).pop();
                WikitudePlugin.openAppSettings();
              },
            )
          ],
        );
      }
    );
  }
}