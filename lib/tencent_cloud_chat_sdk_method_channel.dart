import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimUIKitListener.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/utils/utils.dart';
import 'tencent_cloud_chat_sdk_platform_interface.dart';

/// An implementation of [TencentCloudChatSdkPlatform] that uses method channels.
class MethodChannelTencentCloudChatSdk extends TencentCloudChatSdkPlatform {
  /// The method channel used to interact with the native platform.
  static const _channel = MethodChannel('tencent_cloud_chat_sdk');
  static final Map<String, V2TimUIKitListener> uikitIKitListener = {};

  static bool needLog = true;

  log(
    String api,
    Map<dynamic, dynamic> param,
    String resp,
  ) {
    if (MethodChannelTencentCloudChatSdk.needLog) {
      Future.delayed(const Duration(seconds: 1), () {
        try {
          var logs = "【$api】${json.encode(param)}|$resp";
          uikitTrace(trace: logs);
        } catch (_) {}
      });
    }
  }

  @override
  Future<Map<String, dynamic>> getNetworkInfo() async {
    var res = formatJson(
      await _channel.invokeMethod(
        'getNetworkInfo',
        {},
      ),
    );

    return res;
  }

  @override
  Future setAPNSListener() {
    return _channel.invokeMethod("setAPNSListener", {});
  }

  @override
  String addUIKitListener({
    required V2TimUIKitListener listener,
  }) {
    final String uuid = Utils.generateUniqueString();
    uikitIKitListener[uuid] = listener;
    return uuid;
  }

  @override
  void removeUIKitListener({
    String? uuid,
  }) {
    if (uuid == null) {
      uikitIKitListener.clear();
    } else {
      if (uikitIKitListener.containsKey(uuid)) {
        uikitIKitListener.remove(uuid);
      }
    }
  }

  @override
  void emitUIKitListener({
    required Map<String, dynamic> data,
  }) {
    uikitIKitListener.forEach((key, value) {
      value.onUiKitEventEmit(data);
    });
  }

  @override
  Future<V2TimCallback> doBackground({
    required int unreadCount,
  }) async {
    Map<String, dynamic> param = {
      "ability": Utils.getAbility(),
      "unreadCount": unreadCount,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "doBackground",
          param,
        ),
      ),
    );
    log("doBackground", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> doForeground() async {
    Map<String, dynamic> param = {
      "ability": Utils.getAbility(),
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "doForeground",
          param,
        ),
      ),
    );
    log("doForeground", param, resp.toLogString());
    return resp;
  }

  Map<String, dynamic> formatJson(Map? jsonSrc) {
    if (jsonSrc != null) {
      return Map<String, dynamic>.from(jsonSrc);
    }
    return Map<String, dynamic>.from({});
  }
}
