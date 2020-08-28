# Augmented Reality Flutter Sample App by Wikitude

by Wikitude GmbH - [www.wikitude.com](https://www.wikitude.com)

Sample projects for Android and iOS demoing the most common use-cases.

# Documentation & Samples  

* To make this project work, the first step is to import all the packages on it by using the following command where the `.yaml` file is located:

	```
	$ flutter pub get
	```

    It could be possible that the `augmented\_reality\_plugin_wikitude` plugin also requires to call the same command inside its folder `plugin/augmented\_reality\_plugin_wikitude`.

### iOS development

* Open the `ios/Runner.xcodeproj` project with Xcode. Select the `Runner` target, open the `Signing & Capabilities` tab and input your signing settings.

* Navigate into the root project of the example app in your terminal, and input the following command:

    ```
    $ flutter run
    ```

    This will generate and configure the `ios/Runner.xcworkspace` and run the app on your device.

### Known issues

* It is a known issue (https://github.com/flutter/flutter/issues/32756) that when trying to generate a release Android apk in Flutter, the following error can happen:

    ```
    AndroidRuntime: java.lang.UnsatisfiedLinkError: dalvik.system.PathClassLoader[DexPathList[[zip file "/data/app/com.wikitude.fluttersamples/base.apk"],nativeLibraryDirectories=[/data/app/com.wikitude.fluttersamples/lib/arm, /data/app/com.wikitude.fluttersamples/base.apk!/lib/armeabi-v7a, /vendor/lib, /system/lib]]] couldn't find "libflutter.so"
    ```

    It means that the flutter library for the armeabi-v7a architecture is missing. Because of that, if you build the application in release mode, you will have to put the following code inside `wikitude\_flutter_app/android/app/build.gradle` at the end of the `defaultConfig` section to make sure that the app won't crash in any device:

    ```
    ndk {
        abiFilters 'armeabi-v7a'
    }
    ```

    Nevertheless, if you are developing for Android with Visual Studio Code the abiFilter has to be removed.

* Windows can't handle long paths. In case you open the project in Windows and you get the following error:

    ```
    FileSystemException: FileSystemException: Cannot open file, path = 'C:\Users\username\Desktop\Wikitude_Flutter_ExampleApp_8-10-0_2019-10-24_04-00-43\build\app\intermediates\flutter\debug\android-arm64/flutter_assets\samples/04_CloudRecognition_3_UsingMetainformationInTheResponse/jquery/jquery-mobile-transparent-ui-overlay.css'
    ```

    You will have to unzip the project trying to keep the name of the folder as short as possible to avoid this problem.

* Please find details about plugin installation and samples at [Wikitude Developer Section](https://www.wikitude.com/documentation/).

# LICENSE

The Wikitude Plugin is under Apache 2.0 license (see below), where the Wikitude SDK library (pre-bundled) itself follows a proprietary license scheme (see [LICENSE.MD](LICENSE.md) for details).

```
   Copyright 2018-2019 Wikitude GmbH, https://www.wikitude.com

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```
