import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';

import 'package:tencent_cloud_chat_sdk/enum/message_elem_type.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimConversationListener.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_draft.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_filter.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_text_elem.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/native_im/adapter/tim_manager.dart';
import 'package:tencent_cloud_chat_sdk/native_im/bindings/native_imsdk_bindings_generated.dart';
import 'package:tencent_cloud_chat_sdk/native_im/bindings/native_library_manager.dart';
import 'package:tencent_cloud_chat_sdk/native_im/tools.dart';

class TIMConversationManager {
  static TIMConversationManager instance = TIMConversationManager();
  late V2TimConversationListener _conversationListener;
  List<V2TimConversationListener> v2TimConversationListenerList = List.empty(growable: true);

  TIMConversationManager();

  void init() {
    _initInternalConversationListener();
  }

  void setConversationListener({
    required V2TimConversationListener listener,
  }) {
    addConversationListener(listener: listener);
  }

  void addConversationListener({V2TimConversationListener? listener}) {
    if (listener == null || v2TimConversationListenerList.contains(listener)) {
      return;
    }

    v2TimConversationListenerList.add(listener);
  }

  void removeConversationListener({V2TimConversationListener? listener}) {
    if (listener == null) {
      v2TimConversationListenerList.clear();
    } else {
      v2TimConversationListenerList.remove(listener);
    }
  }

  Future<V2TimValueCallback<V2TimConversationResult>> getConversationList({
    required String nextSeq,
    required int count,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<V2TimConversationResult>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('getConversationList');
    Completer<V2TimValueCallback<V2TimConversationResult>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<V2TimConversationResult>(userData, completer);

    Pointer<Char> pFilter = Tools.string2PointerChar(json.encode({}));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartGetConversationListByFilter(pFilter, int.tryParse(nextSeq) ?? 0, count, pUserData);

    return completer.future;
  }

  Future<LinkedHashMap<dynamic, dynamic>> getConversationListWithoutFormat({
    required String nextSeq,
    required int count,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return LinkedHashMap<dynamic, dynamic>();
    }

    String userData = Tools.generateUserData('getConversationListWithoutFormat');
    Completer<LinkedHashMap<dynamic, dynamic>> completer = Completer();
    void handleApiCallback (Map jsonResult) {
      V2TimValueCallback<List<V2TimConversation>> result = V2TimValueCallback.fromJson(jsonResult);
      V2TimConversationResult conversationResult = V2TimConversationResult(nextSeq: '', isFinished: true, conversationList: result.data);

      completer.complete(LinkedHashMap<dynamic, dynamic>.from(conversationResult.toJson()));
    }
    NativeLibraryManager.timApiValueCallback2Future(userData, handleApiCallback);

    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartGetConversationList(pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<V2TimConversation>> getConversation({
    required String conversationID,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<V2TimConversation>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String cConversationID = '';
    TIMConvType cConversationType = TIMConvType.kTIMConv_Group;
    if (conversationID.startsWith('c2c_')) {
      cConversationType = TIMConvType.kTIMConv_C2C;
      cConversationID = conversationID.substring(4);
    } else if (conversationID.startsWith('group_')) {
      cConversationType = TIMConvType.kTIMConv_Group;
      cConversationID = conversationID.substring(6);
    } else {
      print('invalid conversation id: $conversationID');
    }

    if (cConversationID.isEmpty) {
      return V2TimValueCallback<V2TimConversation>(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "invalid conversation id");
    }

    String userData = Tools.generateUserData('getConversation');
    Completer<V2TimValueCallback<V2TimConversation>> completer = Completer();
    void handleApiCallback (Map jsonResult) {
      V2TimValueCallback<List<V2TimConversation>> result = V2TimValueCallback.fromJson(jsonResult);
      V2TimConversation? conversation = result.data!.isNotEmpty ? result.data![0] : null;
      completer.complete(V2TimValueCallback<V2TimConversation>(code: result.code, desc: result.desc, data: conversation));
    }
    NativeLibraryManager.timApiValueCallback2Future(userData, handleApiCallback);

    List<Map<String, dynamic>> param = [{
      'get_conversation_list_param_conv_type' : cConversationType.value,
      'get_conversation_list_param_conv_id' : cConversationID,
    }];
    Pointer<Char> pParam= Tools.string2PointerChar(json.encode(param));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);

    NativeLibraryManager.bindings.DartGetConversation(pParam, pUserData);
    
    return completer.future;
  }

  Future<V2TimValueCallback<List<V2TimConversation>>>
      getConversationListByConversationIds({
    required List<String> conversationIDList,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<List<V2TimConversation>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('getConversationListByConversaionIds');
    Completer<V2TimValueCallback<List<V2TimConversation>>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<List<V2TimConversation>>(userData, completer);

    List<Map<String, dynamic>> param = [];
    for (String conversationID in conversationIDList) {
      Map<String, dynamic> convParamInfo = {}; 
      if (conversationID.startsWith('c2c_')) {
        convParamInfo['get_conversation_list_param_conv_type'] = TIMConvType.kTIMConv_C2C.value;
        convParamInfo['get_conversation_list_param_conv_id'] = conversationID.substring(4);

        param.add(convParamInfo);
      } else if (conversationID.startsWith('group_')) {
        convParamInfo['get_conversation_list_param_conv_type'] = TIMConvType.kTIMConv_Group.value;
        convParamInfo['get_conversation_list_param_conv_id'] = conversationID.substring(6);

        param.add(convParamInfo);
      } else {
        print('invalid conversation id: $conversationID');
      }
    }

    if (param.isEmpty) {
      return V2TimValueCallback<List<V2TimConversation>>(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "no valid conversation id");
    }

    Pointer<Char> pConversationList = Tools.string2PointerChar(json.encode(param));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartGetConversation(pConversationList, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<V2TimConversationResult>> getConversationListByFilter({
    required V2TimConversationFilter filter,
    required int nextSeq,
    required int count,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<V2TimConversationResult>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('getConversationListByFilter');
    Completer<V2TimValueCallback<V2TimConversationResult>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<V2TimConversationResult>(userData, completer);

    Pointer<Char> pFilter = Tools.string2PointerChar(json.encode(filter.toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartGetConversationListByFilter(pFilter, nextSeq, count, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> pinConversation({
    required String conversationID,
    required bool isPinned,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String cConversationID = '';
    TIMConvType cConversationType = TIMConvType.kTIMConv_Group;
    if (conversationID.startsWith('c2c_')) {
      cConversationType = TIMConvType.kTIMConv_C2C;
      cConversationID = conversationID.substring(4);
    } else if (conversationID.startsWith('group_')) {
      cConversationType = TIMConvType.kTIMConv_Group;
      cConversationID = conversationID.substring(6);
    } else {
      print('invalid conversation id: $conversationID');
    }

    if (cConversationID.isEmpty) {
      return V2TimCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "invalid conversation id");
    }

    String userData = Tools.generateUserData('pinConversation');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    Pointer<Char> pConversationID = Tools.string2PointerChar(cConversationID);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartPinConversation(pConversationID, cConversationType, isPinned, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<int>> getTotalUnreadMessageCount() async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<int>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('getTotalUnreadMessageCount');
    Completer<V2TimValueCallback<int>> completer = Completer();
    void handleApiCallback(Map jsonResult) {
      V2TimValueCallback<Map<String, int>> result = V2TimValueCallback<Map<String, int>>.fromJson(jsonResult);
      int count = result.data?['conv_get_total_unread_message_count_result_unread_count'] ?? 0;

      completer.complete(V2TimValueCallback<int>(code: result.code, desc: result.desc, data: count));
    }
    NativeLibraryManager.timApiValueCallback2Future(userData, handleApiCallback);

    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartGetTotalUnreadMessageCount(pUserData);

    return completer.future;
  }

  Future<V2TimCallback> deleteConversation({
    required String conversationID,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String cConversationID = '';
    TIMConvType cConversationType = TIMConvType.kTIMConv_Group;
    if (conversationID.startsWith('c2c_')) {
      cConversationType = TIMConvType.kTIMConv_C2C;
      cConversationID = conversationID.substring(4);
    } else if (conversationID.startsWith('group_')) {
      cConversationType = TIMConvType.kTIMConv_Group;
      cConversationID = conversationID.substring(6);
    } else {
      print('invalid conversation id: $conversationID');
    }

    if (cConversationID.isEmpty) {
      return V2TimCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "invalid conversation id");
    }

    String userData = Tools.generateUserData('deleteConversation');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    Pointer<Char> pConversationID = Tools.string2PointerChar(cConversationID);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartDeleteConversation(pConversationID, cConversationType, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      deleteConversationList({
    required List<String> conversationIDList,
    required bool clearMessage,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<List<V2TimConversationOperationResult>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('deleteConversationList');
    Completer<V2TimValueCallback<List<V2TimConversationOperationResult>>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<List<V2TimConversationOperationResult>>(userData, completer);

    Pointer<Char> pConversationList = Tools.string2PointerChar(json.encode(conversationIDList));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartDeleteConversationList(pConversationList, clearMessage, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> setConversationDraft({
    required String conversationID,
    String? draftText = "",
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String cConversationID = '';
    TIMConvType cConversationType = TIMConvType.kTIMConv_Group;
    if (conversationID.startsWith('c2c_')) {
      cConversationType = TIMConvType.kTIMConv_C2C;
      cConversationID = conversationID.substring(4);
    } else if (conversationID.startsWith('group_')) {
      cConversationType = TIMConvType.kTIMConv_Group;
      cConversationID = conversationID.substring(6);
    } else {
      print('invalid conversation id: $conversationID');
    }

    if (cConversationID.isEmpty) {
      return V2TimCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "invalid conversation id");
    }

    V2TimTextElem textElem = V2TimTextElem(text: draftText);
    V2TimMessage v2timMessage = V2TimMessage(elemType: MessageElemType.V2TIM_ELEM_TYPE_TEXT);
    v2timMessage.elemList.add(textElem);

    V2TimConversationDraft v2timConversationDraft = V2TimConversationDraft(message: v2timMessage, customData: draftText);

    Pointer<Char> pConversationID = Tools.string2PointerChar(cConversationID);
    Pointer<Char> pConversationDraft = Tools.string2PointerChar(json.encode(v2timConversationDraft.toJson()));
    NativeLibraryManager.bindings.DartSetConversationDraft(pConversationID, cConversationType, pConversationDraft);

    return V2TimCallback(code: 0, desc: 'success');
  }

  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      setConversationCustomData({
    required String customData,
    required List<String> conversationIDList,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<List<V2TimConversationOperationResult>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('setConversationCustomData');
    Completer<V2TimValueCallback<List<V2TimConversationOperationResult>>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<List<V2TimConversationOperationResult>>(userData, completer);

    Pointer<Char> pConversationIDList = Tools.string2PointerChar(json.encode(conversationIDList));
    Pointer<Char> pCustomData = Tools.string2PointerChar(customData);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartSetConversationCustomData(pConversationIDList, pCustomData, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      markConversation({
    required int markType,
    required bool enableMark,
    required List<String> conversationIDList,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<List<V2TimConversationOperationResult>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('markConversation');
    Completer<V2TimValueCallback<List<V2TimConversationOperationResult>>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<List<V2TimConversationOperationResult>>(userData, completer);

    Pointer<Char> pConversationIDList = Tools.string2PointerChar(json.encode(conversationIDList));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartMarkConversation(pConversationIDList, markType, enableMark, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      createConversationGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<List<V2TimConversationOperationResult>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('createConversationGroup');
    Completer<V2TimValueCallback<List<V2TimConversationOperationResult>>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<List<V2TimConversationOperationResult>>(userData, completer);

    Pointer<Char> pGroupName = Tools.string2PointerChar(groupName);
    Pointer<Char> pConversationIDList = Tools.string2PointerChar(json.encode(conversationIDList));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartCreateConversationGroup(pGroupName, pConversationIDList, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<List<String>>> getConversationGroupList() async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<List<String>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('getConversationGroupList');
    Completer<V2TimValueCallback<List<String>>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<List<String>>(userData, completer);

    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartGetConversationGroupList(pUserData);

    return completer.future;
  }

  Future<V2TimCallback> deleteConversationGroup({
    required String groupName,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('deleteConversationGroup');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    Pointer<Char> pGroupName = Tools.string2PointerChar(groupName);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartDeleteConversationGroup(pGroupName, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> renameConversationGroup({
    required String oldName,
    required String newName,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('renameConversationGroup');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    Pointer<Char> pOldName = Tools.string2PointerChar(oldName);
    Pointer<Char> pNewName = Tools.string2PointerChar(newName);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartRenameConversationGroup(pOldName, pNewName, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>> addConversationsToGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<List<V2TimConversationOperationResult>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('addConversationsToGroup');
    Completer<V2TimValueCallback<List<V2TimConversationOperationResult>>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<List<V2TimConversationOperationResult>>(userData, completer);

    Pointer<Char> pGroupName = Tools.string2PointerChar(groupName);
    Pointer<Char> pConversationIDList = Tools.string2PointerChar(json.encode(conversationIDList));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartAddConversationsToGroup(pGroupName, pConversationIDList, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>> deleteConversationsFromGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<List<V2TimConversationOperationResult>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('deleteConversationsFromGroup');
    Completer<V2TimValueCallback<List<V2TimConversationOperationResult>>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<List<V2TimConversationOperationResult>>(userData, completer);

    Pointer<Char> pGroupName = Tools.string2PointerChar(groupName);
    Pointer<Char> pConversationIDList = Tools.string2PointerChar(json.encode(conversationIDList));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartDeleteConversationsFromGroup(pGroupName, pConversationIDList, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<int>> getUnreadMessageCountByFilter({
    required V2TimConversationFilter filter,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<int>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('getUnreadMessageCountByFilter');
    Completer<V2TimValueCallback<int>> completer = Completer();
    void handleApiCallback(Map jsonResult) {
      V2TimValueCallback<Map<String, int>> result = V2TimValueCallback<Map<String, int>>.fromJson(jsonResult);
      int count = result.data?['conv_get_total_unread_message_count_result_unread_count'] ?? 0;

      completer.complete(V2TimValueCallback<int>(code: result.code, desc: result.desc, data: count));
    }
    NativeLibraryManager.timApiValueCallback2Future(userData, handleApiCallback);

    Pointer<Char> pFilter = Tools.string2PointerChar(json.encode(filter.toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartGetUnreadMessageCountByFilter(pFilter, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> subscribeUnreadMessageCountByFilter({
    required V2TimConversationFilter filter,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    Pointer<Char> pFilter = Tools.string2PointerChar(json.encode(filter.toJson()));
    NativeLibraryManager.bindings.DartSubscribeUnreadMessageCountByFilter(pFilter);

    return V2TimCallback(code: TIMErrCode.ERR_SUCC.value, desc: 'success');
  }

  Future<V2TimCallback> unsubscribeUnreadMessageCountByFilter({
    required V2TimConversationFilter filter,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    Pointer<Char> pFilter = Tools.string2PointerChar(json.encode(filter.toJson()));
    NativeLibraryManager.bindings.DartUnsubscribeUnreadMessageCountByFilter(pFilter);

    return V2TimCallback(code: TIMErrCode.ERR_SUCC.value, desc: 'success');
  }

  Future<V2TimCallback> cleanConversationUnreadMessageCount({
    required String conversationID,
    required int cleanTimestamp,
    required int cleanSequence,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('cleanConversationUnreadMessageCount');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    Pointer<Char> pConversationID = Tools.string2PointerChar(conversationID);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartCleanConversationUnreadMessageCount(pConversationID, cleanTimestamp, cleanSequence, pUserData);

    return completer.future;
  }

  void _initInternalConversationListener() {
    _conversationListener = V2TimConversationListener(
      onSyncServerStart: () {
        for (var listener in v2TimConversationListenerList) {
          listener.onSyncServerStart();
        }
      },

      onSyncServerFinish: () {
        for (var listener in v2TimConversationListenerList) {
          listener.onSyncServerFinish();
        }
      },

      onSyncServerFailed: () {
        for (var listener in v2TimConversationListenerList) {
          listener.onSyncServerFailed();
        }
      },

      onNewConversation: (List<V2TimConversation> conversationList) {
        for (var listener in v2TimConversationListenerList) {
          listener.onNewConversation(conversationList);
        }
      },

      onConversationChanged: (List<V2TimConversation> conversationList) {
        for (var listener in v2TimConversationListenerList) {
          listener.onConversationChanged(conversationList);
        }
      },

      onTotalUnreadMessageCountChanged: (int unreadCount) {
        for (var listener in v2TimConversationListenerList) {
          listener.onTotalUnreadMessageCountChanged(unreadCount);
        }
      },

      onConversationGroupCreated: (String groupName, List<V2TimConversation> conversationList) {
        for (var listener in v2TimConversationListenerList) {
          listener.onConversationGroupCreated(groupName, conversationList);
        }
      },

      onConversationGroupDeleted: (String groupName) {
        for (var listener in v2TimConversationListenerList) {
          listener.onConversationGroupDeleted(groupName);
        }
      },

      onConversationGroupNameChanged: (String oldName, String newName) {
        for (var listener in v2TimConversationListenerList) {
          listener.onConversationGroupNameChanged(oldName, newName);
        }
      },

      onConversationsAddedToGroup: (String groupName, List<V2TimConversation> conversationList) {
        for (var listener in v2TimConversationListenerList) {
          listener.onConversationsAddedToGroup(groupName, conversationList);
        }
      },

      onConversationsDeletedFromGroup: (String groupName, List<V2TimConversation> conversationList) {
        for (var listener in v2TimConversationListenerList) {
          listener.onConversationsDeletedFromGroup(groupName, conversationList);
        }
      },

      onConversationDeleted: (List<String> conversationIDList) {
        for (var listener in v2TimConversationListenerList) {
          listener.onConversationDeleted(conversationIDList);
        }
      },

      onUnreadMessageCountChangedByFilter: (V2TimConversationFilter filter, int totalUnreadCount) {
        for (var listener in v2TimConversationListenerList) {
          listener.onUnreadMessageCountChangedByFilter(filter, totalUnreadCount);
        }
      }
    );

    NativeLibraryManager.setConversationListener(_conversationListener);
  }
}