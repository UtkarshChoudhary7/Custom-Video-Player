package com.example.custom_video_player;

import android.os.Bundle;
import android.view.WindowManager;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

  private static final String CHANNEL = "fullscreen";


  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

//    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
////            new MethodChannel.MethodCallHandler() {
////              @Override
////              public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
////                if(methodCall.method.equals("goFullscreen")) {
////                    WindowManager.LayoutParams lp = getWindow().getAttributes();
////                    lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
////                  getWindow().setAttributes(lp);
////                  result.success(lp.layoutInDisplayCutoutMode);
////                } else if(methodCall.method.equals("goNormal")){
////                    WindowManager.LayoutParams lp = getWindow().getAttributes();
////                    lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT;
////                    getWindow().setAttributes(lp);
////                    result.success(lp.layoutInDisplayCutoutMode);
////                } else {
////                  result.notImplemented();
////                }
////              }
////            }
////    );
  }
}
