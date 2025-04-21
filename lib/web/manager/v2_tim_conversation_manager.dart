// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:js_util';

import 'package:flutter/foundation.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimConversationListener.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_conversation.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_conversation_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_conversation_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/web/enum/event_enum.dart';
import 'package:tencent_cloud_chat_sdk/web/manager/im_sdk_plugin_js.dart';
import 'package:tencent_cloud_chat_sdk/web/models/v2_tim_delete_conversation.dart';
import 'package:tencent_cloud_chat_sdk/web/models/v2_tim_get_conversation_list.dart';
import 'package:tencent_cloud_chat_sdk/web/models/v2_tim_pin_conversation.dart';
import 'package:tencent_cloud_chat_sdk/web/utils/utils.dart';

class V2TIMConversationManager {
  late TencentCloudChat? timeweb;
  static final Map<String, V2TimConversationListener> _conversationListener =
      {};

  V2TIMConversationManager() {
    timeweb = V2TIMManagerWeb.timWeb;
  }

  static final _conversationListenerWeb = allowInterop((res) async {
    List<dynamic> conversationList =
        await GetConversationList.formateConversationList(jsToMap(res)['data']);
    final convList =
        conversationList.map((e) => V2TimConversation.fromJson(e)).toList();
    for (var listener in _conversationListener.values) {
      listener.onConversationChanged(convList);
    }
  });

/*
  注意：web只有一个update回调(新增也在里面)，这个回调不做初始化磨平操作，native有新的会话
  即会在初始化时调用这个监听
*/
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      deleteConversationList({
    required List<String> conversationIDList,
    required bool clearMessage,
  }) async {
    print("deleteConversationList $conversationIDList");
    await wrappedPromiseToFuture(
      timeweb!.deleteConversation(
        mapToJSObj({
          "conversationIDList": conversationIDList,
          "clearHistoryMessage": clearMessage,
        }),
      ),
    );
    return V2TimValueCallback<List<V2TimConversationOperationResult>>.fromJson({
      "code": 0,
      "data": [],
    });
  }

  void setConversationListener(
      V2TimConversationListener listener, String? listenerUuid) async {
    if (_conversationListener.isNotEmpty) {
      _conversationListener[listenerUuid!] = (listener);
      return;
    }
    _conversationListener[listenerUuid!] = (listener);
    timeweb!.on(EventType.CONVERSATION_LIST_UPDATED, _conversationListenerWeb);
  }

  void makeConversationListenerEventData(_channel, String type, data) {
    CommonUtils.emitEvent(_channel, "conversationListener", type, data);
  }

  // web 中参数无法传递分页信息
  Future<V2TimValueCallback<V2TimConversationResult>>
      getConversationList() async {
    // try {
    final res = await wrappedPromiseToFuture(timeweb!.getConversationList());
    debugPrint("orginal list: $res");
    log(res);
    List<dynamic> conversationList =
        await GetConversationList.formateConversationList(
            jsToMap(res.data)['conversationList']);
    return CommonUtils.returnSuccess<V2TimConversationResult>(
        GetConversationList.formatReturn(conversationList));
    // } catch (error) {
    //   return CommonUtils.returnErrorForValueCb<V2TimConversationResult>(
    //       error.toString());
    // }
  }

  // 和getConversationList 调用的是相同的方法, 此项接口返回的数据没有getConversationProfile全
  Future<dynamic> getConversationListByConversaionIds(param) async {
    try {
      var res = await wrappedPromiseToFuture(
          timeweb!.getConversationList(param["conversationIDList"]));
      var conversationList = await GetConversationList.formateConversationList(
          jsToMap(res.data)['conversationList']);
      return CommonUtils.returnSuccess<List<V2TimConversation>>(
          conversationList);
    } catch (err) {
      return CommonUtils.returnErrorForValueCb<List<V2TimConversation>>(err);
    }
  }

  // web中的方法名字是： getConversationProfile
  Future<V2TimValueCallback<V2TimConversation>> getConversation({
    required String conversationID,
  }) async {
    try {
      var res = await wrappedPromiseToFuture(
          timeweb!.getConversationProfile(conversationID));

      return CommonUtils.returnSuccess<V2TimConversation>(
          await GetConversationList.formateConversationListItem(
              jsToMap(jsToMap(res.data)['conversation'])));
    } catch (err) {
      return CommonUtils.returnErrorForValueCb<V2TimConversation>(err);
    }
  }

  Future<dynamic> deleteConversation(conversationParams) async {
    try {
      await promiseToFuture(timeweb!.deleteConversation(
          DeleteConversation.formateParams(conversationParams)));

      return CommonUtils.returnSuccessWithDesc('ok');
    } catch (err) {
      return CommonUtils.returnError(err.toString());
    }
  }

  Future<dynamic> pinConversation(params) async {
    try {
      final formatedParams = PinConversation.formateParams(params);
      final res =
          await promiseToFuture(timeweb!.pinConversation(formatedParams));
      return CommonUtils.returnSuccessForCb(jsToMap(res)['conversationID']);
    } catch (err) {
      return CommonUtils.returnError(err);
    }
  }

  // web不存在添加草稿功能
  Future<dynamic> setConversationDraft() async {
    debugPrint("web不支持添加草稿功能");
    return CommonUtils.returnError(
        "setConversationDraft feature does not exist on the web");
  }

  // web不存在获得未读消息总数此功能
  Future<dynamic> getTotalUnreadMessageCount() async {
    debugPrint("web不支持获得未读消息总数此功能");
    return CommonUtils.returnErrorForValueCb<int>(
        "getTotalUnreadMessageCount feature does not exist on the web");
  }

  Future<void> removeConversationListener({
    String? listenerUuid,
    required bool hasListener,
  }) async {
    if (listenerUuid != null && listenerUuid.isNotEmpty) {
      _conversationListener.remove(listenerUuid);
      if (_conversationListener.isNotEmpty) {
        return;
      }
    }
    if (!hasListener) {
      _conversationListener.clear();
    }
    if (_conversationListener.isEmpty) {
      timeweb!
          .off(EventType.CONVERSATION_LIST_UPDATED, _conversationListenerWeb);
    }
  }
}
