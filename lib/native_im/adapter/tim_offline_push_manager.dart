import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:tencent_cloud_chat_sdk/models/v2_tim_offline_push_config.dart';
import 'package:tencent_cloud_chat_sdk/native_im/adapter/tim_manager.dart';
import 'package:tencent_cloud_chat_sdk/native_im/bindings/native_library_manager.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/native_im/bindings/native_imsdk_bindings_generated.dart';
import 'package:tencent_cloud_chat_sdk/native_im/tools.dart';

class TIMOfflinePushManager {
  static TIMOfflinePushManager instance = TIMOfflinePushManager();

  TIMOfflinePushManager();

  void init() {}

  Future<V2TimCallback> setOfflinePushConfig({
    required double businessID,
    required String token,
    bool isTPNSToken = false,
    bool isVoip = false,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('setOfflinePushConfig');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    V2TimOfflinePushConfig config = V2TimOfflinePushConfig(businessID: businessID.toInt(), token: token, isTPNSToken: isTPNSToken, isVoip: isVoip);

    Pointer<Char> pConfig = Tools.string2PointerChar(json.encode(config.toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartSetOfflinePushToken(pConfig, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> doBackground({
    required int unreadCount,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('doBackground');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartDoBackground(unreadCount, pUserData);
    return completer.future;
  }

  Future<V2TimCallback> doForeground() async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('doForeground');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartDoForeground(pUserData);

    return completer.future;
  }

}