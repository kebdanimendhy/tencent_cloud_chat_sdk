import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:tencent_cloud_chat_sdk/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/get_group_message_read_member_list_filter.dart';
import 'package:tencent_cloud_chat_sdk/enum/history_msg_get_type_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_elem_type.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_status.dart';
import 'package:tencent_cloud_chat_sdk/models/common_utils.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_image.dart';
import 'package:tencent_cloud_chat_sdk/enum/offlinePushInfo.dart';
import 'package:tencent_cloud_chat_sdk/enum/receive_message_opt_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_custom_elem.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_elem.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_face_elem.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_file_elem.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_message_read_member_list.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_image_elem.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_location_elem.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_merger_elem.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_change_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_download_elem_param.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_download_progress.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_extension.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_extension_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_get_history_message_list_param.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_list_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_online_url.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_reaction_change_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_reaction_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_reaction_user_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_receipt.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_search_param.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_search_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_receive_message_opt_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_sound_elem.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_text_elem.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_full_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_video_elem.dart';
import 'package:tencent_cloud_chat_sdk/native_im/bindings/native_imsdk_bindings_generated.dart';
import 'package:tencent_cloud_chat_sdk/native_im/bindings/native_library_manager.dart';
import 'package:tencent_cloud_chat_sdk/native_im/tools.dart';

import 'tim_manager.dart';

class TIMMessageManager {
  static TIMMessageManager instance = TIMMessageManager();
  String TAG = "TIMMessageManager";
  static int _messageSeq = 0;
  final int _MAX_ABSTRACT_COUNT = 5;
  final int _MAX_ABSTRACT_LENGTH = 100;
  late V2TimAdvancedMsgListener _advancedMessageListener;
  List<V2TimAdvancedMsgListener> v2TimAdvancedMsgListenerList = List.empty(growable: true);
  // messageIDMap 为了兼容旧版本 sdk 的实现
  Map<String, V2TimMessage> messageIDMap = {};

  Map<String, V2TimMessage> _mergerMessageMap = {};

  Set<String> _downloadingMessageSet = {};

  TIMMessageManager();

  void init() {
    _internalInitMessageListener();
  }

  void addAdvancedMsgListener(V2TimAdvancedMsgListener? listener) {
    if (listener == null || v2TimAdvancedMsgListenerList.contains(listener)) {
      return;
    }

    v2TimAdvancedMsgListenerList.add(listener);
  }

  void removeAdvancedMsgListener({V2TimAdvancedMsgListener? listener}) {
    if (listener == null) {
      v2TimAdvancedMsgListenerList.clear();
    }

    v2TimAdvancedMsgListenerList.remove(listener);
  }

  V2TimMsgCreateInfoResult createTextMessage({required String text}) {
    V2TimTextElem textElem = V2TimTextElem(text: text);
    int elemType = MessageElemType.V2TIM_ELEM_TYPE_TEXT;
    V2TimMessage v2timMessage = V2TimMessage(elemType: elemType);
    v2timMessage.textElem = textElem;
    v2timMessage.elemList.add(textElem);

    String tempID = _createMessageTempID();
    v2timMessage.id = tempID;
    messageIDMap.addAll({tempID: v2timMessage});

    V2TimMsgCreateInfoResult result = V2TimMsgCreateInfoResult(id: tempID, messageInfo: v2timMessage);
    return result;
  }

  V2TimMsgCreateInfoResult createCustomMessage({required String data, String desc = "",  String extension = ""}) {
    V2TimCustomElem customElem = V2TimCustomElem(data: data, desc: desc, extension: extension);
    int elemType = MessageElemType.V2TIM_ELEM_TYPE_CUSTOM;
    V2TimMessage v2timMessage = V2TimMessage(elemType: elemType);
    v2timMessage.customElem = customElem;
    v2timMessage.elemList.add(customElem);

    String tempID = _createMessageTempID();
    v2timMessage.id = tempID;
    messageIDMap.addAll({tempID: v2timMessage});

    V2TimMsgCreateInfoResult result = V2TimMsgCreateInfoResult(id: tempID, messageInfo: v2timMessage);
    return result;
  }

  V2TimMsgCreateInfoResult createImageMessage({required String imagePath, String? imageName}) {
    V2TimImageElem imageElem = V2TimImageElem(path: imagePath);
    int elemType = MessageElemType.V2TIM_ELEM_TYPE_IMAGE;
    V2TimMessage v2timMessage = V2TimMessage(elemType: elemType);
    v2timMessage.imageElem = imageElem;
    v2timMessage.elemList.add(imageElem);

    String tempID = _createMessageTempID();
    v2timMessage.id = tempID;
    messageIDMap.addAll({tempID: v2timMessage});

    V2TimMsgCreateInfoResult result = V2TimMsgCreateInfoResult(id: tempID, messageInfo: v2timMessage);
    return result;
  }

  V2TimMsgCreateInfoResult createVideoMessage({required String videoFilePath, required String type, required int duration, required String snapshotPath}) {
    V2TimVideoElem videoElem = V2TimVideoElem(videoPath: videoFilePath, snapshotPath: snapshotPath, duration: duration);
    int elemType = MessageElemType.V2TIM_ELEM_TYPE_VIDEO;
    V2TimMessage v2timMessage = V2TimMessage(elemType: elemType);
    v2timMessage.videoElem = videoElem;
    v2timMessage.elemList.add(videoElem);

    String tempID = _createMessageTempID();
    v2timMessage.id = tempID;
    messageIDMap.addAll({tempID: v2timMessage});

    V2TimMsgCreateInfoResult result = V2TimMsgCreateInfoResult(id: tempID, messageInfo: v2timMessage);
    return result;
  }

  V2TimMsgCreateInfoResult createSoundMessage({required String soundPath, required int duration}) {
    V2TimSoundElem soundElem = V2TimSoundElem(path: soundPath, duration: duration);
    int elemType = MessageElemType.V2TIM_ELEM_TYPE_SOUND;
    V2TimMessage v2timMessage = V2TimMessage(elemType: elemType);
    v2timMessage.soundElem = soundElem;
    v2timMessage.elemList.add(soundElem);

    String tempID = _createMessageTempID();
    v2timMessage.id = tempID;
    messageIDMap.addAll({tempID: v2timMessage});

    V2TimMsgCreateInfoResult result = V2TimMsgCreateInfoResult(id: tempID, messageInfo: v2timMessage);
    return result;
  }

  V2TimMsgCreateInfoResult createFileMessage({required String filePath, required String fileName}) {
    V2TimFileElem fileElem = V2TimFileElem(path: filePath, fileName: fileName);
    int elemType = MessageElemType.V2TIM_ELEM_TYPE_FILE;
    V2TimMessage v2timMessage = V2TimMessage(elemType: elemType);
    v2timMessage.fileElem = fileElem;
    v2timMessage.elemList.add(fileElem);

    String tempID = _createMessageTempID();
    v2timMessage.id = tempID;
    messageIDMap.addAll({tempID: v2timMessage});

    V2TimMsgCreateInfoResult result = V2TimMsgCreateInfoResult(id: tempID, messageInfo: v2timMessage);
    return result;
  }

  V2TimMsgCreateInfoResult createFaceMessage({required int index, required String data}) {
    V2TimFaceElem faceElem = V2TimFaceElem(index: index, data: data);
    int elemType = MessageElemType.V2TIM_ELEM_TYPE_FACE;
    V2TimMessage v2timMessage = V2TimMessage(elemType: elemType);
    v2timMessage.faceElem = faceElem;
    v2timMessage.elemList.add(faceElem);

    String tempID = _createMessageTempID();
    v2timMessage.id = tempID;
    messageIDMap.addAll({tempID: v2timMessage});

    V2TimMsgCreateInfoResult result = V2TimMsgCreateInfoResult(id: tempID, messageInfo: v2timMessage);
    return result;
  }

  V2TimMsgCreateInfoResult createLocationMessage({required String desc, required double longitude, required double latitude}) {
    V2TimLocationElem locationElem = V2TimLocationElem(desc: desc, longitude: longitude, latitude: latitude);
    int elemType = MessageElemType.V2TIM_ELEM_TYPE_LOCATION;
    V2TimMessage v2timMessage = V2TimMessage(elemType: elemType);
    v2timMessage.locationElem = locationElem;
    v2timMessage.elemList.add(locationElem);

    String tempID = _createMessageTempID();
    v2timMessage.id = tempID;
    messageIDMap.addAll({tempID: v2timMessage});

    V2TimMsgCreateInfoResult result = V2TimMsgCreateInfoResult(id: tempID, messageInfo: v2timMessage);
    return result;
  }

// 截取完整的 utf8 字符串 
String _safeSubstring(String str, int byteLimit) {
  var bytes = utf8.encode(str);
  if (bytes.length <= byteLimit) {
    return str;
  }

  var truncatedBytes = bytes.take(byteLimit).toList();

  String result = '';
  while (truncatedBytes.isNotEmpty) {
    try {
      result = utf8.decode(truncatedBytes);
      break;
    } catch (e) {
      truncatedBytes.removeLast();
    }
  }

  return result;
}

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createMergerMessage({required List<String> msgIDList, required String title, required List<String> abstractList, required String compatibleText}) async {
    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList:  msgIDList);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      return V2TimValueCallback(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      return V2TimValueCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: 'message not found', data: V2TimMsgCreateInfoResult());
    }

    for (V2TimMessage msg in msgList) {
      if (msg.status != MessageStatus.V2TIM_MSG_STATUS_SEND_SUCC) {
        return V2TimValueCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: 'message status must be successful', data: V2TimMsgCreateInfoResult());
      }

      for (var elem in msg.elemList) {
        if (elem is V2TIMElem && elem.elemType == MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS) {
          return V2TimValueCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: 'group tips message is not support', data: V2TimMsgCreateInfoResult());
        }
      }
    }

    List<String> abstractListAdjust = abstractList.take(_MAX_ABSTRACT_COUNT).map((e) => _safeSubstring(e, _MAX_ABSTRACT_LENGTH)).toList();
    V2TimMergerElem mergerElem = V2TimMergerElem(title: title, abstractList: abstractListAdjust, compatibleText: compatibleText, messageList: msgList);
    int elemType = MessageElemType.V2TIM_ELEM_TYPE_MERGER;
    V2TimMessage v2timMessage = V2TimMessage(elemType: elemType);
    v2timMessage.mergerElem = mergerElem;
    v2timMessage.elemList.add(mergerElem);
    v2timMessage.isForwardMessage = true;

    String tempID = _createMessageTempID();
    v2timMessage.id = tempID;
    messageIDMap.addAll({tempID: v2timMessage});

    V2TimMsgCreateInfoResult result = V2TimMsgCreateInfoResult(id: tempID, messageInfo: v2timMessage);
    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromObject(result);
  }

  V2TimMsgCreateInfoResult? createMergerMessageWithMessageList({required List<V2TimMessage> msgList, required String title, required List<String> abstractList, required String compatibleText}) {
    List<String> abstractListAdjust = abstractList.take(_MAX_ABSTRACT_COUNT).map((e) => _safeSubstring(e, _MAX_ABSTRACT_LENGTH)).toList();

    for (var msg in msgList) {
      if (msg.status != MessageStatus.V2TIM_MSG_STATUS_SEND_SUCC) {
        print("createMergerMessageWithMessageList, message status must be V2TIM_MSG_STATUS_SEND_SUCC");
        return null;
      }

      if (msg.elemType == MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS) {
        print("createMergerMessageWithMessageList, group tips message is not support");
        return null;
      }
    }

    V2TimMergerElem mergerElem = V2TimMergerElem(title: title);
    int elemType = MessageElemType.V2TIM_ELEM_TYPE_MERGER;
    mergerElem.title = title;
    mergerElem.abstractList = abstractListAdjust;
    mergerElem.compatibleText = compatibleText;
    mergerElem.messageList = msgList;
    V2TimMessage v2timMessage = V2TimMessage(elemType: elemType);
    v2timMessage.mergerElem = mergerElem;
    v2timMessage.elemList.add(mergerElem);
    v2timMessage.isForwardMessage = true;

    String tempID = _createMessageTempID();
    v2timMessage.id = tempID;
    messageIDMap.addAll({tempID: v2timMessage});

    V2TimMsgCreateInfoResult result = V2TimMsgCreateInfoResult(id: tempID, messageInfo: v2timMessage);
    return result;
  }
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createForwardMessage({required String msgID}) async {
    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [msgID]);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      return V2TimValueCallback(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      return V2TimValueCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: 'message not found', data: V2TimMsgCreateInfoResult());
    }

    V2TimMessage message = msgList[0];
    if (message.status != MessageStatus.V2TIM_MSG_STATUS_SEND_SUCC) {
      return V2TimValueCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: 'message status must be successful', data: V2TimMsgCreateInfoResult());
    }

    for (var elem in message.elemList) {
      if (elem is V2TIMElem && elem.elemType == MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS) {
          return V2TimValueCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: 'group tips message is not support', data: V2TimMsgCreateInfoResult());
        }
    }

    V2TimMessage v2timMessage = V2TimMessage(elemType: message.elemType);
    v2timMessage.elemList = message.elemList;
    v2timMessage.isForwardMessage = true;

    String tempID = _createMessageTempID();
    v2timMessage.id = tempID;
    messageIDMap.addAll({tempID: v2timMessage});

    V2TimMsgCreateInfoResult result = V2TimMsgCreateInfoResult(id: tempID, messageInfo: v2timMessage);

    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromObject(result);
  }

  V2TimMsgCreateInfoResult? createForwardMessageWithMessage({required V2TimMessage message}) {
    if (message.status != MessageStatus.V2TIM_MSG_STATUS_SEND_SUCC) {
      print("createForwardMessageWithMessage, message status must be V2TIM_MSG_STATUS_SEND_SUCC");
      return null;
    }

    if (message.elemType == MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS) {
      print("createForwardMessageWithMessage, group tips message is not support");
      return null;
    }

    V2TimMessage v2timMessage = V2TimMessage(elemType: message.elemType);
    v2timMessage.elemList = message.elemList;
    v2timMessage.isForwardMessage = true;

    String tempID = _createMessageTempID();
    v2timMessage.id = tempID;
    messageIDMap.addAll({tempID: v2timMessage});

    V2TimMsgCreateInfoResult result = V2TimMsgCreateInfoResult(id: tempID, messageInfo: v2timMessage);
    return result;
  }

  V2TimMsgCreateInfoResult createTargetedGroupMessage({required String id, required List<String> receiverList}) {
    if (!messageIDMap.containsKey(id)) {
      print("createTargetedGroupMessage failed, created message id is not exist");
      return V2TimMsgCreateInfoResult();
    }

    if (receiverList.isEmpty) {
      print("createTargetedGroupMessageWithMessage failed, receiverList is empty");
      return V2TimMsgCreateInfoResult();
    }

    // 不支持群定向消息
    V2TimMessage message = messageIDMap[id]!;
    if (message.targetGroupMemberList != null && message.targetGroupMemberList!.isNotEmpty) {
      print("createTargetedGroupMessageWithMessage failed, targeted group message does not support at message");
      return V2TimMsgCreateInfoResult();
    }

    messageIDMap[id] = message;

    return V2TimMsgCreateInfoResult(id: id, messageInfo: message);
  }

  V2TimMsgCreateInfoResult createTargetedGroupMessageWithMessage({required V2TimMessage message, required List<String> receiverList}) {
    if (receiverList.isEmpty) {
      print("createTargetedGroupMessageWithMessage failed, receiverList is empty");
      return V2TimMsgCreateInfoResult();
    }

    // 不支持群定向消息
    if (message.targetGroupMemberList != null && message.targetGroupMemberList!.isNotEmpty) {
      print("createTargetedGroupMessageWithMessage failed, targeted group message does not support at message");
      return V2TimMsgCreateInfoResult();
    }

    message.targetGroupMemberList = receiverList;

    String tempID = _createMessageTempID();
    message.id = tempID;
    messageIDMap.addAll({tempID: message});

    V2TimMsgCreateInfoResult result = V2TimMsgCreateInfoResult(id: tempID, messageInfo: message);
    return result;
  }

  V2TimMsgCreateInfoResult createAtSignedGroupMessage({required String createdMsgID, required List<String> atUserList}) {
    if (!messageIDMap.containsKey(createdMsgID)) {
      print("createAtSignedGroupMessage failed, message id is not exist");
      return V2TimMsgCreateInfoResult();
    }

    V2TimMessage message = messageIDMap[createdMsgID]!;
    if (message.groupAtUserList != null && message.groupAtUserList!.isNotEmpty) {
      print("createAtSignedGroupMessage failed, at message does not support at message");
      return V2TimMsgCreateInfoResult();
    }

    message.groupAtUserList = atUserList;
    messageIDMap[createdMsgID] = message;

    return V2TimMsgCreateInfoResult(id: createdMsgID, messageInfo: message);
  }

  V2TimMsgCreateInfoResult? createAtSignedGroupMessageWithMessage({required V2TimMessage message, required List<String> atUserList}) {
    if (atUserList.isEmpty) {
      print("createAtSignedGroupMessageWithMessage failed, atUserList cannot be empty");
      return V2TimMsgCreateInfoResult();
    }

    if (message.groupAtUserList != null && message.groupAtUserList!.isNotEmpty) {
      print("createAtSignedGroupMessageWithMessage failed, at message does not support at message");
      return V2TimMsgCreateInfoResult();
    }

    message.groupAtUserList = atUserList;
    String tempID = _createMessageTempID();
    message.id = tempID;
    messageIDMap.addAll({tempID: message});

    V2TimMsgCreateInfoResult result = V2TimMsgCreateInfoResult(id: tempID, messageInfo: message);
    return result;
  }

  V2TimMessage appendMessage({
    required String createMessageBaseId,
    required String createMessageAppendId,
  }) {
    if (!messageIDMap.containsKey(createMessageBaseId) || !messageIDMap.containsKey(createMessageAppendId)) {
      print("appendMessage failed, createMessageBaseId or createMessageAppendId is not exist");
      return V2TimMessage(elemType: MessageElemType.V2TIM_ELEM_TYPE_NONE);
    }

    V2TimMessage baseMessage = messageIDMap[createMessageBaseId]!;
    V2TimMessage appendMessage = messageIDMap[createMessageAppendId]!;
    
    baseMessage.elemList.addAll(appendMessage.elemList);

    return baseMessage;
  }

  V2TimMsgCreateInfoResult createTextAtMessage({
    required String text,
    required List<String> atUserList,
  }) {
    V2TimTextElem textElem = V2TimTextElem(text: text);
    V2TimMessage v2timMessage = V2TimMessage(elemType: MessageElemType.V2TIM_ELEM_TYPE_TEXT);
    v2timMessage.textElem = textElem;
    v2timMessage.elemList.add(textElem);

    v2timMessage.groupAtUserList = atUserList;

    String tempID = _createMessageTempID();
    v2timMessage.id = tempID;
    messageIDMap.addAll({tempID: v2timMessage});

    V2TimMsgCreateInfoResult result = V2TimMsgCreateInfoResult(id: tempID, messageInfo: v2timMessage);
    return result;
  }

  Future<V2TimValueCallback<V2TimMessage>> sendMessage({
    required String id,
    required String? receiver,
    required String? groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    bool isExcludedFromLastMessage = false,
    bool? isSupportMessageExtension = false,
    bool? isExcludedFromContentModeration = false,
    bool needReadReceipt = false,
    OfflinePushInfo? offlinePushInfo,
    String? cloudCustomData,
    String? localCustomData,
    bool? isDisableCloudMessagePreHook = false,
    bool? isDisableCloudMessagePostHook = false,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<V2TimMessage>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimMessage? v2timMessage = messageIDMap[id];
    if (v2timMessage == null) {
      print('sendMessage, messageIDMap cannot find message');
      return V2TimValueCallback<V2TimMessage>.fromBool(false, 'messageIDMap cannot find message');
    }

    if ((receiver == null || receiver.isEmpty) && (groupID == null || groupID.isEmpty) ) {
      print('sendMessage, receiver and groupID cannot be empty at the same time');
      return V2TimValueCallback<V2TimMessage>.fromBool(false, 'sendMessage, receiver and groupID cannot be empty at the same time');
    }

    v2timMessage.priority = priority;
    v2timMessage.isOnlineOnly = onlineUserOnly;
    v2timMessage.isExcludedFromUnreadCount = isExcludedFromUnreadCount;
    v2timMessage.isExcludedFromLastMessage = isExcludedFromLastMessage;
    v2timMessage.isSupportMessageExtension = isSupportMessageExtension;
    v2timMessage.needReadReceipt = needReadReceipt;
    v2timMessage.isDisableCloudMessagePreHook = isDisableCloudMessagePreHook;
    v2timMessage.isDisableCloudMessagePostHook = isDisableCloudMessagePostHook;
    if (cloudCustomData != null) {
      v2timMessage.cloudCustomData = cloudCustomData;
    }

    if (localCustomData != null) {
      v2timMessage.localCustomData = localCustomData;
    }

    if (offlinePushInfo != null) {
      v2timMessage.offlinePushInfo = offlinePushInfo;
    }

    String convID = "";
    TIMConvType timConvType = TIMConvType.kTIMConv_Group;
    if (groupID != null && groupID.isNotEmpty) {
      convID = groupID;
      timConvType = TIMConvType.kTIMConv_Group;
    } else {
      convID = receiver!;
      timConvType = TIMConvType.kTIMConv_C2C;
    }

    String userData = Tools.generateUserData('sendMessage');
    Completer<V2TimValueCallback<V2TimMessage>> completer = Completer();
    void handleApiCallback(Map jsonResult) {
      V2TimValueCallback<V2TimMessage> callbackResult = V2TimValueCallback<V2TimMessage>.fromJson(jsonResult);
      if (callbackResult.data != null) {
        callbackResult.data!.id = id;
      }
      completer.complete(callbackResult);
    }

    NativeLibraryManager.timApiValueCallback2Future(userData, handleApiCallback);

    Pointer<Char> pConvID = Tools.string2PointerChar(convID);
    Pointer<Char> pMsgParam = Tools.string2PointerChar(json.encode(v2timMessage.toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartSendMessage(pConvID, timConvType, pMsgParam, pUserData);

    // 转发消息给多个人的时候，会重复使用一个 id
    // messageIDMap.remove(id);

    return completer.future;
  }

  Future<V2TimValueCallback<List<V2TimMessage>>> downloadMergerMessage({
    required String msgID
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<List<V2TimMessage>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [msgID]);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      return V2TimValueCallback(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      return V2TimValueCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: 'message not found');
    }

    String userData = Tools.generateUserData('downloadMergerMessage');
    Completer<V2TimValueCallback<List<V2TimMessage>>> completer = Completer();
    void handleApiCallback(Map jsonResult) {
      V2TimValueCallback<List<V2TimMessage>> callbackResult = V2TimValueCallback<List<V2TimMessage>>.fromJson(jsonResult);
      if (callbackResult.code == 0 && callbackResult.data != null && callbackResult.data!.isNotEmpty) {
        _mergerMessageMap.addAll({ for (var message in callbackResult.data!) message.msgID!: message }); 
      }

      completer.complete(callbackResult);
    }
    NativeLibraryManager.timApiValueCallback2Future(userData, handleApiCallback);

    Pointer<Char> pMessage = Tools.string2PointerChar(json.encode(msgList[0].toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartDownloadMergerMessage(pMessage, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<V2TimMessage>> reSendMessage({
    required String msgID,
    bool onlineUserOnly = false,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<V2TimMessage>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [msgID]);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      return V2TimValueCallback(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      return V2TimValueCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: 'message not found');
    }

    V2TimMessage message = msgList[0];
    if ((message.userID == null || message.userID!.isEmpty) && (message.groupID == null || message.groupID!.isEmpty) ) {
      return V2TimValueCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: 'invalid message');
    }

    message.isOnlineOnly = onlineUserOnly;

    String convID = "";
    TIMConvType timConvType = TIMConvType.kTIMConv_Group;
    if (message.groupID != null && message.groupID!.isNotEmpty) {
      convID = message.groupID!;
    } else {
      convID = message.userID!;
      timConvType = TIMConvType.kTIMConv_C2C;
    }

    String userData = Tools.generateUserData('reSendMessage');
    Completer<V2TimValueCallback<V2TimMessage>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future(userData, completer);

    Pointer<Char> pConvID = Tools.string2PointerChar(convID);
    Pointer<Char> pMessage = Tools.string2PointerChar(json.encode(msgList[0].toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartSendMessage(pConvID, timConvType, pMessage, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> setC2CReceiveMessageOpt({
    required List<String> userIDList,
    required ReceiveMsgOptEnum opt,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('setC2CReceiveMessageOpt');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    Pointer<Char> pUserIDList = Tools.string2PointerChar(json.encode(userIDList));
    TIMReceiveMessageOpt messageOpt = TIMReceiveMessageOpt.fromValue(opt.index);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartSetC2CReceiveMessageOpt(pUserIDList, messageOpt, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<List<V2TimReceiveMessageOptInfo>>> getC2CReceiveMessageOpt({
    required List<String> userIDList,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<List<V2TimReceiveMessageOptInfo>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('getC2CReceiveMessageOpt');
    Completer<V2TimValueCallback<List<V2TimReceiveMessageOptInfo>>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future(userData, completer);

    Pointer<Char> pUserIDList = Tools.string2PointerChar(json.encode(userIDList));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartGetC2CReceiveMessageOpt(pUserIDList, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> setGroupReceiveMessageOpt({
    required String groupID,
    required ReceiveMsgOptEnum opt,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('setGroupReceiveMessageOpt');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    Pointer<Char> pGroupID = Tools.string2PointerChar(groupID);
    TIMReceiveMessageOpt messageOpt = TIMReceiveMessageOpt.fromValue(opt.index);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartSetGroupReceiveMessageOpt(pGroupID, messageOpt, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> setLocalCustomData({
    required String msgID,
    required String localCustomData,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [msgID]);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      return V2TimCallback(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      return V2TimCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: 'message not found');
    }

    String userData = Tools.generateUserData('setLocalCustomData');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    V2TimMessage message = msgList[0];
    message.localCustomData = localCustomData;
    Pointer<Char> pMessage = Tools.string2PointerChar(json.encode(message.toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartSetLocalCustomData(pMessage, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> setLocalCustomInt({
    required String msgID,
    required int localCustomInt,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [msgID]);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      return V2TimCallback(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      return V2TimCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: 'message not found');
    }

    String userData = Tools.generateUserData('setLocalCustomInt');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    V2TimMessage message = msgList[0];
    message.localCustomInt = localCustomInt;
    Pointer<Char> pMessage = Tools.string2PointerChar(json.encode(message.toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartSetLocalCustomData(pMessage, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> setCloudCustomData({
    required String data,
    required String msgID,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [msgID]);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      return V2TimCallback(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      return V2TimCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: 'message not found');
    }

    String userData = Tools.generateUserData('setCloudCustomData');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    V2TimMessage message = msgList[0];
    message.cloudCustomData = data;
    Pointer<Char> pMessage = Tools.string2PointerChar(json.encode(message.toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartModifyMessage(pMessage, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<List<V2TimMessage>>> getC2CHistoryMessageList({
    required String userID,
    required int count,
    String? lastMsgID,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<List<V2TimMessage>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    if (userID.isEmpty) {
      return V2TimValueCallback<List<V2TimMessage>>(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "userID is empty");
    }

    V2TimMessage? lastMessage; 
    if (lastMsgID != null) {
      V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [lastMsgID]);
      if (findResult.code != TIMErrCode.ERR_SUCC.value) {
        print("getC2CHistoryMessageList, find last message failed");
        return V2TimValueCallback<List<V2TimMessage>>(code: findResult.code, desc: findResult.desc);
      }

      List<V2TimMessage> msgList = findResult.data!;
      if (msgList.isNotEmpty) {
        lastMessage = msgList[0];
      }
    }

    String userData = Tools.generateUserData('getC2CHistoryMessageList');
    Completer<V2TimValueCallback<List<V2TimMessage>>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<List<V2TimMessage>>(userData, completer);
    
    V2TimMessageGetHistoryMessageListParam param = V2TimMessageGetHistoryMessageListParam(count: count, getType: HistoryMsgGetTypeEnum.V2TIM_GET_CLOUD_OLDER_MSG, lastMessage: lastMessage);
    Pointer<Char> pParam = Tools.string2PointerChar(json.encode(param.toJson()));
    Pointer<Char> pUserID = Tools.string2PointerChar(userID);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartGetHistoryMessageList(pUserID, TIMConvType.kTIMConv_C2C, pParam, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<List<V2TimMessage>>> getGroupHistoryMessageList({
    required String groupID,
    required int count,
    String? lastMsgID,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<List<V2TimMessage>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    if (groupID.isEmpty) {
      return V2TimValueCallback<List<V2TimMessage>>(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "groupID is empty");
    }

    V2TimMessage? lastMessage; 
    if (lastMsgID != null) {
      V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [lastMsgID]);
      if (findResult.code != TIMErrCode.ERR_SUCC.value) {
        print("getGroupHistoryMessageList, find last message failed");
        return V2TimValueCallback<List<V2TimMessage>>(code: findResult.code, desc: findResult.desc);
      }

      List<V2TimMessage> msgList = findResult.data!;
      if (msgList.isNotEmpty) {
        lastMessage = msgList[0];
      }
    }

    String userData = Tools.generateUserData('getGroupHistoryMessageList');
    Completer<V2TimValueCallback<List<V2TimMessage>>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<List<V2TimMessage>>(userData, completer);
    
    V2TimMessageGetHistoryMessageListParam param = V2TimMessageGetHistoryMessageListParam(count: count, getType: HistoryMsgGetTypeEnum.V2TIM_GET_CLOUD_OLDER_MSG, lastMessage: lastMessage);
    Pointer<Char> pParam = Tools.string2PointerChar(json.encode(param.toJson()));
    Pointer<Char> pGroupID = Tools.string2PointerChar(groupID);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartGetHistoryMessageList(pGroupID, TIMConvType.kTIMConv_Group, pParam, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<List<V2TimMessage>>> getHistoryMessageList({
    HistoryMsgGetTypeEnum? getType,
    String? userID,
    String? groupID,
    int? lastMsgSeq,
    required int count,
    String? lastMsgID,
    List<int>? messageTypeList,
    List<int>? messageSeqList,
    int? timeBegin,
    int? timePeriod,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<List<V2TimMessage>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    if ((userID == null || userID.isEmpty) && (groupID == null || groupID.isEmpty)) {
      return V2TimValueCallback<List<V2TimMessage>>(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "invalid userID and groupID");
    }

    V2TimMessage? lastMessage;
    if (lastMsgID != null) {
      V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [lastMsgID]);
      if (findResult.code != TIMErrCode.ERR_SUCC.value) {
        print("getHistoryMessageList, find last message failed");
        return V2TimValueCallback<List<V2TimMessage>>(code: findResult.code, desc: findResult.desc);
      }

      List<V2TimMessage> msgList = findResult.data!;
      if (msgList.isNotEmpty) {
        lastMessage = msgList[0];
      }
    }

    String userData = Tools.generateUserData('getHistoryMessageList');
    Completer<V2TimValueCallback<List<V2TimMessage>>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<List<V2TimMessage>>(userData, completer);

    String convID = '';
    TIMConvType convType = TIMConvType.kTIMConv_Group;
    if (groupID != null && groupID.isNotEmpty) {
      convID = groupID;
      convType = TIMConvType.kTIMConv_Group;
    } else {
      convID = userID!;
      convType = TIMConvType.kTIMConv_C2C;
    }

    V2TimMessageGetHistoryMessageListParam param = V2TimMessageGetHistoryMessageListParam(count: count, getType: getType, lastMessage: lastMessage, lastMessageSeq: lastMsgSeq, timeBegin: timeBegin, timePeriod: timePeriod, messageTypeList: messageTypeList, messageSeqList: messageSeqList);
    Pointer<Char> pParam = Tools.string2PointerChar(json.encode(param.toJson()));
    Pointer<Char> pConvID = Tools.string2PointerChar(convID);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartGetHistoryMessageList(pConvID, convType, pParam, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<V2TimMessageListResult>> getHistoryMessageListV2({
    HistoryMsgGetTypeEnum? getType,
    String? userID,
    String? groupID,
    int? lastMsgSeq,
    required int count,
    String? lastMsgID,
    List<int>? messageTypeList,
    List<int>? messageSeqList,
    int? timeBegin,
    int? timePeriod,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<V2TimMessageListResult>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    if ((userID == null || userID.isEmpty) && (groupID == null || groupID.isEmpty)) {
      return V2TimValueCallback<V2TimMessageListResult>(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "invalid userID and groupID");
    }

    V2TimMessage? lastMessage;
    if (lastMsgID != null) {
      V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [lastMsgID]);
      if (findResult.code != TIMErrCode.ERR_SUCC.value) {
        print("getHistoryMessageListV2, find last message failed");
        return V2TimValueCallback<V2TimMessageListResult>(code: findResult.code, desc: findResult.desc);
      }

      List<V2TimMessage> msgList = findResult.data!;
      if (msgList.isNotEmpty) {
        lastMessage = msgList[0];
      }
    }

    String userData = Tools.generateUserData('getHistoryMessageListV2');
    Completer<V2TimValueCallback<V2TimMessageListResult>> completer = Completer();
    void handleApiCallback(Map jsonResult) {
      V2TimValueCallback<List<V2TimMessage>> result = V2TimValueCallback<List<V2TimMessage>>.fromJson(jsonResult);
      List<V2TimMessage> messageList = result.data ?? [];
      V2TimMessageListResult adjustResult = V2TimMessageListResult(isFinished: messageList.length < count, messageList: messageList);
      completer.complete(V2TimValueCallback<V2TimMessageListResult>(code: result.code, desc: result.desc, data: adjustResult));
    }
    NativeLibraryManager.timApiValueCallback2Future(userData, handleApiCallback);

    String convID = '';
    TIMConvType convType = TIMConvType.kTIMConv_Group;
    if (groupID != null && groupID.isNotEmpty) {
      convID = groupID;
      convType = TIMConvType.kTIMConv_Group;
    } else {
      convID = userID!;
      convType = TIMConvType.kTIMConv_C2C;
    }

    V2TimMessageGetHistoryMessageListParam param = V2TimMessageGetHistoryMessageListParam(count: count, getType: getType, lastMessage: lastMessage, lastMessageSeq: lastMsgSeq, timeBegin: timeBegin, timePeriod: timePeriod, messageTypeList: messageTypeList, messageSeqList: messageSeqList);
    Pointer<Char> pParam = Tools.string2PointerChar(json.encode(param.toJson()));
    Pointer<Char> pConvID = Tools.string2PointerChar(convID);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartGetHistoryMessageList(pConvID, convType, pParam, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> revokeMessage({required String msgID}) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [msgID]);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      print("revokeMessage, find message failed");
      return V2TimCallback(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      print("revokeMessage, message not found");
      return V2TimCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "message not found");
    }

    String userData = Tools.generateUserData('revokeMessage');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    V2TimMessage message = msgList[0];
    Pointer<Char> pConvID = Tools.string2PointerChar('conv_id');  // 此参数在内部无实际作用，非空即可
    TIMConvType convType = TIMConvType.kTIMConv_Group;  // 此参数在内部无实际作用，设置 kTIMConv_C2C 和 kTIMConv_Group 都可以
    Pointer<Char> pMessage = Tools.string2PointerChar(json.encode(message.toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartRevokeMessage(pConvID, convType, pMessage, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> markC2CMessageAsRead({
    required String userID,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('markC2CMessageAsRead');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    Pointer<Char> pUserID = Tools.string2PointerChar(userID);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartMarkMessageAsRead(pUserID, TIMConvType.kTIMConv_C2C, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> markGroupMessageAsRead({
    required String groupID,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('markGroupMessageAsRead');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    Pointer<Char> pGroupID = Tools.string2PointerChar(groupID);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartMarkMessageAsRead(pGroupID, TIMConvType.kTIMConv_Group, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> markAllMessageAsRead() async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('markAllMessageAsRead');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartMarkAllMessageAsRead(pUserData);

    return completer.future;
  }

  Future<V2TimCallback> deleteMessageFromLocalStorage({
    required String msgID,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [msgID]);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      print("deleteMessageFromLocalStorage, find message failed");
      return V2TimCallback(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      print("deleteMessageFromLocalStorage, message not found");
      return V2TimCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "message not found");
    }

    V2TimMessage message = msgList[0];
    if ((message.userID == null || message.userID!.isEmpty) && (message.groupID == null || message.groupID!.isEmpty) ) {
      return V2TimCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: 'invalid message');
    }

    String convID = "";
    TIMConvType timConvType = TIMConvType.kTIMConv_Group;
    if (message.groupID != null && message.groupID!.isNotEmpty) {
      convID = message.groupID!;
    } else {
      convID = message.userID!;
      timConvType = TIMConvType.kTIMConv_C2C;
    }

    String userData = Tools.generateUserData('deleteMessageFromLocalStorage');
    Completer<V2TimCallback> completer = Completer();

    void handleApiCallback(Map jsonResult) {
      V2TimCallback result = V2TimCallback.fromJson(jsonResult);
      completer.complete(result);
    }
    NativeLibraryManager.timApiValueCallback2Future(userData, handleApiCallback);

    Map<String, dynamic> jsonParam = {};
    jsonParam['msg_delete_param_msg'] = message.toJson();
    jsonParam['msg_delete_param_is_ramble'] = false;
    Pointer<Char> pConvID = Tools.string2PointerChar(convID);
    Pointer<Char> pJsonParam = Tools.string2PointerChar(json.encode(jsonParam));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);

    NativeLibraryManager.bindings.DartDeleteMessageFromLocalStorage(pConvID, timConvType, pJsonParam, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> deleteMessages({
    required List<String> msgIDs
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: msgIDs);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      print("deleteMessages, find messages failed");
      return V2TimCallback(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      print("deleteMessages, messages not found");
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "messages not found");
    }

    V2TimMessage message = msgList[0];
    if ((message.userID == null || message.userID!.isEmpty) && (message.groupID == null || message.groupID!.isEmpty) ) {
      return V2TimCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: 'invalid messages');
    }

    String convID = "";
    TIMConvType timConvType = TIMConvType.kTIMConv_Group;
    if (message.groupID != null && message.groupID!.isNotEmpty) {
      convID = message.groupID!;
    } else {
      convID = message.userID!;
      timConvType = TIMConvType.kTIMConv_C2C;
    }

    String userData = Tools.generateUserData('deleteMessages');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    Pointer<Char> pConvID = Tools.string2PointerChar(convID);
    Pointer<Char> pMessageList = Tools.string2PointerChar(json.encode(msgList.map((msg) => msg.toJson()).toList()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartDeleteMessages(pConvID, timConvType, pMessageList, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<V2TimMessage>> insertGroupMessageToLocalStorage({
    required String data,
    required String groupID,
    required String sender,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<V2TimMessage>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('insertGroupMessageToLocalStorage');
    Completer<V2TimValueCallback<V2TimMessage>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<V2TimMessage>(userData, completer);

    V2TimMessage message = createCustomMessage(data: data).messageInfo!;
    message.groupID = groupID;
    message.sender = sender;

    Pointer<Char> pGroupID = Tools.string2PointerChar(groupID);
    Pointer<Char> pMessage = Tools.string2PointerChar(json.encode(message.toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartSaveMessage(pGroupID, TIMConvType.kTIMConv_Group, pMessage, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<V2TimMessage>> insertC2CMessageToLocalStorage({
    required String data,
    required String userID,
    required String sender,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<V2TimMessage>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('insertC2CMessageToLocalStorage');
    Completer<V2TimValueCallback<V2TimMessage>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<V2TimMessage>(userData, completer);

    V2TimMessage message = createCustomMessage(data: data).messageInfo!;
    message.userID = userID;
    message.sender = sender;

    Pointer<Char> pUserID= Tools.string2PointerChar(userID);
    Pointer<Char> pMessage = Tools.string2PointerChar(json.encode(message.toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartSaveMessage(pUserID, TIMConvType.kTIMConv_C2C, pMessage, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<V2TimMessage>> insertGroupMessageToLocalStorageV2({
    required String groupID,
    required String senderID,
    required String createdMsgID,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<V2TimMessage>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimMessage? v2timMessage = messageIDMap[createdMsgID];
    if (v2timMessage == null) {
      print("insertGroupMessageToLocalStorageV2, message not found");
      return V2TimValueCallback<V2TimMessage>.fromBool(false, 'message not found');
    }

    v2timMessage.groupID = groupID;
    v2timMessage.sender = senderID;

    String userData = Tools.generateUserData('insertGroupMessageToLocalStorageV2');
    Completer<V2TimValueCallback<V2TimMessage>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<V2TimMessage>(userData, completer);

    Pointer<Char> pGroupID = Tools.string2PointerChar(groupID);
    Pointer<Char> pMessage = Tools.string2PointerChar(json.encode(v2timMessage.toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartSaveMessage(pGroupID, TIMConvType.kTIMConv_Group, pMessage, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<V2TimMessage>> insertC2CMessageToLocalStorageV2({
    required String userID,
    required String senderID,
    required String createdMsgID,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<V2TimMessage>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimMessage? v2timMessage = messageIDMap[createdMsgID];
    if (v2timMessage == null) {
      print("insertC2CMessageToLocalStorageV2, message not found");
      return V2TimValueCallback<V2TimMessage>.fromBool(false, 'message not found');
    }

    v2timMessage.userID = userID;
    v2timMessage.sender = senderID;

    String userData = Tools.generateUserData('insertC2CMessageToLocalStorageV2');
    Completer<V2TimValueCallback<V2TimMessage>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<V2TimMessage>(userData, completer);

    Pointer<Char> pUserID = Tools.string2PointerChar(userID);
    Pointer<Char> pMessage = Tools.string2PointerChar(json.encode(v2timMessage.toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartSaveMessage(pUserID, TIMConvType.kTIMConv_C2C, pMessage, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> clearC2CHistoryMessage({
    required String userID,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('clearC2CHistoryMessage');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    Pointer<Char> pUserID = Tools.string2PointerChar(userID);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartClearHistoryMessage(pUserID, TIMConvType.kTIMConv_C2C, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> clearGroupHistoryMessage({
    required String groupID,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('clearGroupHistoryMessage');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    Pointer<Char> pGroupID = Tools.string2PointerChar(groupID);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartClearHistoryMessage(pGroupID, TIMConvType.kTIMConv_Group, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<V2TimMessageSearchResult>> searchLocalMessages({
    required V2TimMessageSearchParam searchParam,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<V2TimMessageSearchResult>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('searchLocalMessages');
    Completer<V2TimValueCallback<V2TimMessageSearchResult>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<V2TimMessageSearchResult>(userData, completer);

    Pointer<Char> pSearchParam = Tools.string2PointerChar(json.encode(searchParam.toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartSearchLocalMessages(pSearchParam, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<V2TimMessageSearchResult>> searchCloudMessages({
    required V2TimMessageSearchParam searchParam,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<V2TimMessageSearchResult>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('searchCloudMessages');
    Completer<V2TimValueCallback<V2TimMessageSearchResult>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<V2TimMessageSearchResult>(userData, completer);

    Pointer<Char> pSearchParam = Tools.string2PointerChar(json.encode(searchParam.toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartSearchCloudMessages(pSearchParam, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> sendMessageReadReceipts({
    required List<String> messageIDList,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: messageIDList);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      print("sendMessageReadReceipts, find messages failed");
      return V2TimCallback(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      print("sendMessageReadReceipts, messages not found");
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "messages not found");
    }

    String userData = Tools.generateUserData('sendMessageReadReceipts');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    Pointer<Char> pJsonParam = Tools.string2PointerChar(json.encode(msgList.map((e) => e.toJson()).toList()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartSendMessageReadReceipts(pJsonParam, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<List<V2TimMessageReceipt>>> getMessageReadReceipts({
    required List<String> messageIDList,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<List<V2TimMessageReceipt>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: messageIDList);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      print("getMessageReadReceipts, find messages failed");
      return V2TimValueCallback<List<V2TimMessageReceipt>>(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      print("getMessageReadReceipts, messages not found");
      return V2TimValueCallback<List<V2TimMessageReceipt>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "messages not found");
    }

    String userData = Tools.generateUserData('getMessageReadReceipts');
    Completer<V2TimValueCallback<List<V2TimMessageReceipt>>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future(userData, completer);

    Pointer<Char> pJsonParam = Tools.string2PointerChar(json.encode(msgList.map((e) => e.toJson()).toList()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartGetMessageReadReceipts(pJsonParam, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<V2TimGroupMessageReadMemberList>>
      getGroupMessageReadMemberList({
    required String messageID,
    required GetGroupMessageReadMemberListFilter filter,
    required int nextSeq,
    required int count,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<V2TimGroupMessageReadMemberList>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [messageID]);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      print("getGroupMessageReadMemberList, find message failed");
      return V2TimValueCallback<V2TimGroupMessageReadMemberList>(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      print("getGroupMessageReadMemberList, message not found");
      return V2TimValueCallback<V2TimGroupMessageReadMemberList>(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "message not found");
    }


    String userData = Tools.generateUserData('getGroupMessageReadMemberList');
    Completer<V2TimValueCallback<V2TimGroupMessageReadMemberList>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future(userData, completer);

    TIMGroupMessageReadMembersFilter cFilter = TIMGroupMessageReadMembersFilter.TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_READ;

    V2TimMessage message = msgList[0];
    Pointer<Char> pJsonParam = Tools.string2PointerChar(json.encode(message.toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartGetGroupMessageReadMemberList(pJsonParam, cFilter, nextSeq, count, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<List<V2TimMessage>>> findMessages({
    required List<String> messageIDList,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<List<V2TimMessage>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    List<V2TimMessage> messageResult = [];
    bool isFindAll = true;
    for (String messageID in messageIDList) {
      if (_mergerMessageMap.containsKey(messageID)) {
        messageResult.add(_mergerMessageMap[messageID]!);
      } else {
        isFindAll = false;
      }
    }

    if (isFindAll) {
      return V2TimValueCallback<List<V2TimMessage>>(code: TIMErrCode.ERR_SUCC.value, desc: "OK", data: messageResult);
    }

    String userData = Tools.generateUserData('findMessages');
    Completer<V2TimValueCallback<List<V2TimMessage>>> completer = Completer();
    void handleApiCallback(Map jsonResult) {
      V2TimValueCallback<List<V2TimMessage>> result = V2TimValueCallback<List<V2TimMessage>>.fromJson(jsonResult);
      if (result.code != TIMErrCode.ERR_SUCC.value) {
        List<V2TimMessage> messageList = result.data ?? [];
        Set<String> foundMessageIds = messageList.map((message) => message.msgID!).toSet();
        List<String> missingMessageIDs = messageIDList.where((msg) => !foundMessageIds.contains(msg)).toList();

        for (String messageID in missingMessageIDs) {
          if (_mergerMessageMap.containsKey(messageID)) {
            messageList.add(_mergerMessageMap[messageID]!);
          }
        }

        completer.complete(V2TimValueCallback<List<V2TimMessage>>(code: result.code, desc: result.desc, data: messageList));
      } else {
        completer.complete(result);
      }
    }
    NativeLibraryManager.timApiValueCallback2Future(userData, handleApiCallback);

    Pointer<Char> pJsonParam = Tools.string2PointerChar(json.encode(messageIDList));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartFindMessages(pJsonParam, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<List<V2TimMessageExtensionResult>>>
      setMessageExtensions({
    required String msgID,
    required List<V2TimMessageExtension> extensions,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<List<V2TimMessageExtensionResult>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [msgID]);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      print("setMessageExtensions, find message failed");
      return V2TimValueCallback<List<V2TimMessageExtensionResult>>(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      print("setMessageExtensions, message not found");
      return V2TimValueCallback<List<V2TimMessageExtensionResult>>(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "message not found");
    }

    String userData = Tools.generateUserData('setMessageExtensions');
    Completer<V2TimValueCallback<List<V2TimMessageExtensionResult>>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<List<V2TimMessageExtensionResult>>(userData, completer);

    V2TimMessage message = msgList[0];
    Pointer<Char> pMessage = Tools.string2PointerChar(json.encode(message.toJson()));
    Pointer<Char> pExtensions = Tools.string2PointerChar(json.encode(extensions.map((e) => e.toJson()).toList()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);

    NativeLibraryManager.bindings.DartSetMessageExtensions(pMessage, pExtensions, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<List<V2TimMessageExtension>>> getMessageExtensions({
    required String msgID,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<List<V2TimMessageExtension>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [msgID]);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      print("getMessageExtensions, find message failed");
      return V2TimValueCallback<List<V2TimMessageExtension>>(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      print("getMessageExtensions, message not found");
      return V2TimValueCallback<List<V2TimMessageExtension>>(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "message not found");
    }

    String userData = Tools.generateUserData('getMessageExtensions');
    Completer<V2TimValueCallback<List<V2TimMessageExtension>>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<List<V2TimMessageExtension>>(userData, completer);

    V2TimMessage message = msgList[0];
    Pointer<Char> pMessage = Tools.string2PointerChar(json.encode(message.toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);

    NativeLibraryManager.bindings.DartGetMessageExtensions(pMessage, pUserData);
    
    return completer.future;
  }

  Future<V2TimValueCallback<List<V2TimMessageExtensionResult>>>
      deleteMessageExtensions({
    required String msgID,
    required List<String> keys,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<List<V2TimMessageExtensionResult>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [msgID]);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      print("deleteMessageExtensions, find message failed");
      return V2TimValueCallback<List<V2TimMessageExtensionResult>>(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      print("deleteMessageExtensions, message not found");
      return V2TimValueCallback<List<V2TimMessageExtensionResult>>(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "message not found");
    }

    String userData = Tools.generateUserData('deleteMessageExtensions');
    Completer<V2TimValueCallback<List<V2TimMessageExtensionResult>>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<List<V2TimMessageExtensionResult>>(userData, completer);

    V2TimMessage message = msgList[0];
    Pointer<Char> pMessage = Tools.string2PointerChar(json.encode(message.toJson()));
    Pointer<Char> pKeys = Tools.string2PointerChar(json.encode(keys));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);

    NativeLibraryManager.bindings.DartDeleteMessageExtensions(pMessage, pKeys, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<V2TimMessageChangeInfo>> modifyMessage({
    required V2TimMessage message,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<V2TimMessageChangeInfo>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('modifyMessage');
    Completer<V2TimValueCallback<V2TimMessageChangeInfo>> completer = Completer();
    void handleApiCallback(Map jsonResult) {
      V2TimValueCallback<V2TimMessage> result = V2TimValueCallback<V2TimMessage>.fromJson(jsonResult);
      V2TimMessageChangeInfo changeInfo = V2TimMessageChangeInfo(code: result.code, desc: result.desc, message: result.data);

      completer.complete(V2TimValueCallback<V2TimMessageChangeInfo>.fromObject(changeInfo));
    }
    NativeLibraryManager.timApiValueCallback2Future(userData, handleApiCallback);

    Pointer<Char> pMessage = Tools.string2PointerChar(json.encode(message.toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartModifyMessage(pMessage, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<V2TimMessageOnlineUrl>> getMessageOnlineUrl({
    required String msgID,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<V2TimMessageOnlineUrl>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [msgID]);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      print("deleteMessageExtensions, find message failed");
      return V2TimValueCallback<V2TimMessageOnlineUrl>(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      print("deleteMessageExtensions, message not found");
      return V2TimValueCallback<V2TimMessageOnlineUrl>(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "message not found");
    }

    V2TimMessage message = msgList[0];
    V2TimMessageOnlineUrl result = V2TimMessageOnlineUrl();
    switch (message.elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        result.imageElem = message.imageElem;
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        result.videoElem = message.videoElem;
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        result.soundElem = message.soundElem;
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        result.fileElem = message.fileElem;
        break;
      default:
        break;
    }

    return V2TimValueCallback<V2TimMessageOnlineUrl>.fromObject(result);
  }

  String _getDefaultCachePath({
    required V2TimMessage message,
    required int imageType,
    required bool isSnapshot,
    required V2TimMessageDownloadElemParam downloadParam,
  }) {
    Directory cacheDir = CommonUtils.appFileDir;
    String filePath = downloadParam.fileUUID;

    if (Platform.isAndroid) {
      switch (message.elemType) {
        case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
          var imageInstance = downloadParam.downloadElement as V2TimImage?;
          filePath = 'image_${imageInstance?.type}${imageInstance?.size}${imageInstance?.width}${imageInstance?.height}_${imageInstance?.uuid}';

          break;
        case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
          var videoInstance = downloadParam.downloadElement as V2TimVideoElem?;
          filePath = isSnapshot ? 'video_${videoInstance?.snapshotUUID}' : 'video_${videoInstance?.UUID}';

          break;
        case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
          var soundInstance = downloadParam.downloadElement as V2TimSoundElem?;
          filePath = 'sound_${soundInstance?.UUID}';

          break;
        case MessageElemType.V2TIM_ELEM_TYPE_FILE:
          var fileInstance = downloadParam.downloadElement as V2TimFileElem?;
          var separator = fileInstance?.UUID?.contains('.') == true ? '' : '_';
          filePath = 'file_${fileInstance?.UUID}$separator${Uri.encodeComponent(fileInstance?.fileName ?? "").replaceAll('%20', '+')}';

          break;
        default:
          break;
      }
    } else if (Platform.isIOS) {
      String filePathPrefix = '${TIMManager.instance.getSDKAppID()}/${TIMManager.instance.getLoginUser()}';
      switch (message.elemType) {
        case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
          var imageInstance = downloadParam.downloadElement as V2TimImage?;
          filePath = '$filePathPrefix/image_${imageInstance?.type}${imageInstance?.size}${imageInstance?.width}${imageInstance?.height}_${imageInstance?.uuid}';

          break;
        case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
          var videoInstance = downloadParam.downloadElement as V2TimVideoElem?;
          filePath = '$filePathPrefix/video_${isSnapshot ? videoInstance?.snapshotUUID : videoInstance?.UUID}';

          break;
        case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
          var soundInstance = downloadParam.downloadElement as V2TimSoundElem?;
          filePath = '$filePathPrefix/sound_${soundInstance?.UUID}';

          break;
        case MessageElemType.V2TIM_ELEM_TYPE_FILE:
          var fileInstance = downloadParam.downloadElement as V2TimFileElem?;
          filePath = '$filePathPrefix/${fileInstance?.UUID}/${fileInstance?.fileName ?? ""}';

          break;
        default:
          break;
      }
    } else if (Platform.isMacOS) {
      String filePathPrefix = '${TIMManager.instance.getSDKAppID()}/${TIMManager.instance.getLoginUser()}';
      switch (message.elemType) {
        case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
          var imageInstance = downloadParam.downloadElement as V2TimImage?;
          filePath = '$filePathPrefix/image_${imageInstance?.type}${imageInstance?.size}${imageInstance?.width}${imageInstance?.height}_${imageInstance?.uuid}';

          break;
        case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
          var videoInstance = downloadParam.downloadElement as V2TimVideoElem?;
          filePath = '$filePathPrefix/video_${isSnapshot ? videoInstance?.snapshotUUID : videoInstance?.UUID}';

          break;
        case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
          var soundInstance = downloadParam.downloadElement as V2TimSoundElem?;
          filePath = '$filePathPrefix/sound_${soundInstance?.UUID}';

          break;
        case MessageElemType.V2TIM_ELEM_TYPE_FILE:
          var fileInstance = downloadParam.downloadElement as V2TimFileElem?;
          filePath = '$filePathPrefix/${fileInstance?.UUID}/${fileInstance?.fileName ?? ""}';

          break;
        default:
          break;
      }
    } else if (Platform.isWindows) {
      String filePathPrefix = 'TencentCloudChat/DownLoad/${TIMManager.instance.getSDKAppID()}/${TIMManager.instance.getLoginUser()}';
      switch (message.elemType) {
        case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
          var imageInstance = downloadParam.downloadElement as V2TimImage?;
          filePath = '$filePathPrefix/image_${imageInstance?.type}${imageInstance?.size}${imageInstance?.width}${imageInstance?.height}_${imageInstance?.uuid}';

          break;
        case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
          var videoInstance = downloadParam.downloadElement as V2TimVideoElem?;
          filePath = '$filePathPrefix/video_${isSnapshot ? videoInstance?.snapshotUUID : videoInstance?.UUID}';

          break;
        case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
          var soundInstance = downloadParam.downloadElement as V2TimSoundElem?;
          filePath = '$filePathPrefix/sound_${soundInstance?.UUID}';

          break;
        case MessageElemType.V2TIM_ELEM_TYPE_FILE:
          var fileInstance = downloadParam.downloadElement as V2TimFileElem?;
          filePath = '$filePathPrefix/${fileInstance?.UUID}/${fileInstance?.fileName}';

          break;
        default:
          break;
      }
    } else if (Platform.operatingSystem == 'ohos') {
      switch (message.elemType) {
        case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
          var imageInstance = downloadParam.downloadElement as V2TimImage?;
          filePath = 'image_${imageInstance?.type}_${imageInstance?.uuid}';

          break;
        case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
          var videoInstance = downloadParam.downloadElement as V2TimVideoElem?;
          filePath = isSnapshot ? 'video_${videoInstance?.snapshotUUID}' : 'video_${videoInstance?.UUID}';

          break;
        case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
          var soundInstance = downloadParam.downloadElement as V2TimSoundElem?;
          filePath = 'sound_${soundInstance?.UUID}';

          break;
        case MessageElemType.V2TIM_ELEM_TYPE_FILE:
          var fileInstance = downloadParam.downloadElement as V2TimFileElem?;
          filePath = 'file_${Uri.encodeComponent(fileInstance?.fileName ?? "")}';

          break;
        default:
          break;
      }
    }

    return '${cacheDir.path}/$filePath';
  }

  Future<V2TimCallback> downloadMessage({
    required String msgID,
    required int imageType,
    required bool isSnapshot,
    String? downloadPath,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    final downloadKey = 'msgID-$imageType-$isSnapshot';
    if (_downloadingMessageSet.contains(downloadKey)) {
      print("message ID: $msgID, imageType: $imageType, isSnapshot: $isSnapshot is downloading");
      return V2TimCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: 'message is downloading');
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [msgID]);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      print("downloadMessage, find message failed");
      return V2TimCallback(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      print("downloadMessage, message not found");
      return V2TimCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "message not found");
    }

    V2TimMessage message = msgList[0];
    if (!{MessageElemType.V2TIM_ELEM_TYPE_IMAGE, MessageElemType.V2TIM_ELEM_TYPE_VIDEO, MessageElemType.V2TIM_ELEM_TYPE_SOUND, MessageElemType.V2TIM_ELEM_TYPE_FILE}.contains(message.elemType)) {
      print("downloadMessage, message does not support downloading");
      return V2TimCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "message does not support downloading");
    }

    V2TimMessageDownloadElemParam downloadParam = V2TimMessageDownloadElemParam(message: message, imageType: imageType, isSnapshot: isSnapshot);
    if (downloadParam.downloadUrl.isEmpty || downloadParam.fileUUID.isEmpty) {
      print("downloadMessage, message missing necessary download info");
      return V2TimCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "message missing necessary download info");
    }
    String adjustDownloadPath = downloadPath ?? _getDefaultCachePath(message: message, imageType: imageType, isSnapshot: isSnapshot, downloadParam: downloadParam);

    if (File(adjustDownloadPath).existsSync()) {
      return V2TimCallback(code: TIMErrCode.ERR_SUCC.value, desc: "file: $adjustDownloadPath already exists!");
    }

    String userData = Tools.generateUserData('downloadMessage');
    Completer<V2TimCallback> completer = Completer();
    void handleApiCallback(Map jsonResult) {
      V2TimValueCallback<dynamic> result = V2TimValueCallback<dynamic>.fromJson(jsonResult);
      if (result.desc == 'downloading') {
        Map<String, dynamic> processInfo = result.data ?? {};
        if (processInfo.isNotEmpty) {
          int currentSize = processInfo['msg_download_elem_result_current_size'] ?? 0;
          int totalSize = processInfo['msg_download_elem_result_total_size'] ?? 0;

          V2TimMessageDownloadProgress downloadProgress = V2TimMessageDownloadProgress(
            isFinish: currentSize > 0 && currentSize == totalSize,
            isError: result.code == TIMErrCode.ERR_SUCC.value,
            msgID: msgID,
            currentSize: currentSize,
            totalSize: totalSize,
            type: imageType,
            isSnapshot: isSnapshot,
            path: adjustDownloadPath,
            errorCode: result.code,
            errorDesc: result.desc,
          );

          // 下载进度回调
          _advancedMessageListener.onMessageDownloadProgressCallback(downloadProgress);
        }
      } else {
        // 下载完成回调
        _downloadingMessageSet.remove(downloadKey);

        completer.complete(V2TimCallback(code: result.code, desc: result.desc));
      }
    }
    NativeLibraryManager.timApiValueCallback2Future(userData, handleApiCallback);

    _downloadingMessageSet.add(downloadKey);

    Pointer<Char> pDownloadParam = Tools.string2PointerChar(json.encode(downloadParam.toJson()));
    Pointer<Char> pDownloadPath = Tools.string2PointerChar(adjustDownloadPath);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartDownloadElemToPath(pDownloadParam, pDownloadPath, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<Map<String, String>>> translateText({
    required List<String> texts,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<Map<String, String>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('translateText');
    Completer<V2TimValueCallback<Map<String, String>>> completer = Completer();
    void handleApiCallback(Map jsonResult) {
      V2TimValueCallback<List<dynamic>> callbackResult = V2TimValueCallback<List<dynamic>>.fromJson(jsonResult);
      List<Map<String, dynamic>> resultList = callbackResult.data?.whereType<Map<String, dynamic>>().toList() ?? [];
      Map<String, String> result = Tools.jsonList2Map<String>(resultList, 'msg_translate_text_source_text', 'msg_translate_text_target_text');

      completer.complete(V2TimValueCallback<Map<String, String>>(code: callbackResult.code, desc: callbackResult.desc, data: result));
    }
    NativeLibraryManager.timApiValueCallback2Future(userData, handleApiCallback);

    Pointer<Char> pTexts = Tools.string2PointerChar(json.encode(texts));
    Pointer<Char> pSourceLanguage = Tools.string2PointerChar(sourceLanguage ?? '');
    Pointer<Char> pTargetLanguage = Tools.string2PointerChar(targetLanguage);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartTranslateText(pTexts, pSourceLanguage, pTargetLanguage, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> setAllReceiveMessageOpt({
    required int opt,
    required int startHour,
    required int startMinute,
    required int startSecond,
    required int duration,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('setAllReceiveMessageOpt');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartSetAllReceiveMessageOpt(TIMReceiveMessageOpt.fromValue(opt), startHour, startMinute, startSecond, duration, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> setAllReceiveMessageOptWithTimestamp({
    required int opt,
    required int startTimeStamp,
    required int duration,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('setAllReceiveMessageOptWithTimestamp');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartSetAllReceiveMessageOpt2(TIMReceiveMessageOpt.fromValue(opt), startTimeStamp, duration, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<V2TimReceiveMessageOptInfo>> getAllReceiveMessageOpt() async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<V2TimReceiveMessageOptInfo>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('getAllReceiveMessageOpt');
    Completer<V2TimValueCallback<V2TimReceiveMessageOptInfo>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future(userData, completer);

    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartGetAllReceiveMessageOpt(pUserData);

    return completer.future;
  }

  Future<V2TimCallback> addMessageReaction({
    required String msgID,
    required String reactionID,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [msgID]);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      print("addMessageReaction, find message failed");
      return V2TimCallback(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      print("addMessageReaction, message not found");
      return V2TimCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "message not found");
    }

    String userData = Tools.generateUserData('addMessageReaction');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);


    V2TimMessage message = msgList[0];
    Pointer<Char> pMessage = Tools.string2PointerChar(json.encode(message.toJson()));
    Pointer<Char> pReactionID = Tools.string2PointerChar(reactionID);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartAddMessageReaction(pMessage, pReactionID, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> removeMessageReaction({
    required String msgID,
    required String reactionID,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [msgID]);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      print("removeMessageReaction, find message failed");
      return V2TimCallback(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      print("removeMessageReaction, message not found");
      return V2TimCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "message not found");
    }

    String userData = Tools.generateUserData('removeMessageReaction');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    V2TimMessage message = msgList[0];
    Pointer<Char> pMessage = Tools.string2PointerChar(json.encode(message.toJson()));
    Pointer<Char> pReactionID = Tools.string2PointerChar(reactionID);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartRemoveMessageReaction(pMessage, pReactionID, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<List<V2TimMessageReactionResult>>>
      getMessageReactions({
    required List<String> msgIDList,
    required int maxUserCountPerReaction,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<List<V2TimMessageReactionResult>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: msgIDList);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      print("getMessageReactions, find message failed");
      return V2TimValueCallback<List<V2TimMessageReactionResult>>(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      print("getMessageReactions, message not found");
      return V2TimValueCallback<List<V2TimMessageReactionResult>>(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "message not found");
    }

    String userData = Tools.generateUserData('getMessageReactions');
    Completer<V2TimValueCallback<List<V2TimMessageReactionResult>>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future(userData, completer);

    Pointer<Char> pMessageList = Tools.string2PointerChar(json.encode(msgList.map((msg) => msg.toJson()).toList()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartGetMessageReactions(pMessageList, maxUserCountPerReaction, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<V2TimMessageReactionUserResult>>
      getAllUserListOfMessageReaction({
    required String msgID,
    required String reactionID,
    required int nextSeq,
    required int count,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<V2TimMessageReactionUserResult>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [msgID]);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      print("getAllUserListOfMessageReaction, find message failed");
      return V2TimValueCallback<V2TimMessageReactionUserResult>(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      print("getAllUserListOfMessageReaction, message not found");
      return V2TimValueCallback<V2TimMessageReactionUserResult>(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "message not found");
    }

    String userData = Tools.generateUserData('getAllUserListOfMessageReaction');
    Completer<V2TimValueCallback<V2TimMessageReactionUserResult>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future(userData, completer);

    V2TimMessage message = msgList[0];
    Pointer<Char> pMessage = Tools.string2PointerChar(json.encode(message.toJson()));
    Pointer<Char> pReactionID = Tools.string2PointerChar(reactionID);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartGetAllUserListOfMessageReaction(pMessage, pReactionID, nextSeq, count, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<String>> convertVoiceToText({
    required String msgID,
    required String language,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<String>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [msgID]);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      print("convertVoiceToText, find message failed");
      return V2TimValueCallback<String>(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      print("convertVoiceToText, message not found");
      return V2TimValueCallback<String>(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "message not found");
    }

    V2TimMessage message = msgList[0];
    if (message.elemType !=  MessageElemType.V2TIM_ELEM_TYPE_SOUND) {
      print("convertVoiceToText, message elemType should be V2TIM_ELEM_TYPE_SOUND");
      return V2TimValueCallback<String>(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "message elemType should be V2TIM_ELEM_TYPE_SOUND");
    }

    String soundUrl = message.soundElem?.url ?? "";
    if (soundUrl.isEmpty) {
      print("convertVoiceToText, message soundElem url is empty");
      return V2TimValueCallback<String>(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "message soundElem url is empty");
    }

    String userData = Tools.generateUserData('convertVoiceToText');
    Completer<V2TimValueCallback<String>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future(userData, completer);

    Pointer<Char> pSoundUrl = Tools.string2PointerChar(soundUrl);
    Pointer<Char> pLanguage = Tools.string2PointerChar(language);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartConvertVoiceToText(pSoundUrl, pLanguage, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> pinGroupMessage({
    required String msgID,
    required String groupID,
    required bool isPinned,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimCallback(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    V2TimValueCallback<List<V2TimMessage>> findResult = await findMessages(messageIDList: [msgID]);
    if (findResult.code != TIMErrCode.ERR_SUCC.value) {
      print("pinGroupMessage, find message failed");
      return V2TimCallback(code: findResult.code, desc: findResult.desc);
    }

    List<V2TimMessage> msgList = findResult.data!;
    if (msgList.isEmpty) {
      print("pinGroupMessage, message not found");
      return V2TimCallback(code: TIMErrCode.ERR_INVALID_PARAMETERS.value, desc: "message not found");
    }

    String userData = Tools.generateUserData('pinGroupMessage');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    V2TimMessage message = msgList[0];
    Pointer<Char> pMessage = Tools.string2PointerChar(jsonEncode(message.toJson()));
    Pointer<Char> pGroupID = Tools.string2PointerChar(groupID);

    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartPinGroupMessage(pGroupID, pMessage, isPinned, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<List<V2TimMessage>>> getPinnedGroupMessageList({
    required String groupID,
  }) async {
    if (!TIMManager.instance.isInitSDK()) {
      return V2TimValueCallback<List<V2TimMessage>>(code: TIMErrCode.ERR_SDK_NOT_INITIALIZED.value, desc: "sdk not init");
    }

    String userData = Tools.generateUserData('getPinnedGroupMessageList');
    Completer<V2TimValueCallback<List<V2TimMessage>>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future<List<V2TimMessage>>(userData, completer);

    Pointer<Char> pGroupID = Tools.string2PointerChar(groupID);
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartGetPinnedGroupMessageList(pGroupID, pUserData);

    return completer.future;
  }

  // Future<V2TimValueCallback<List<V2TimMessage>>> getC2CHistoryMessageList({
  //   required String userID,
  //   required int count,
  //   String? lastMsgID,
  // }) async {
  //
  // }
  //
  // Future<V2TimValueCallback<List<V2TimMessage>>> getGroupHistoryMessageList({
  //   required String groupID,
  //   required int count,
  //   String? lastMsgID,
  // }) async {
  //
  // }
  //
  // Future<V2TimValueCallback<List<V2TimMessage>>> getHistoryMessageList({
  //   HistoryMsgGetTypeEnum? getType = HistoryMsgGetTypeEnum.V2TIM_GET_LOCAL_OLDER_MSG,
  //   String? userID,
  //   String? groupID,
  //   int lastMsgSeq = -1,
  //   required int count,
  //   String? lastMsgID,
  //   List<int>? messageTypeList,
  //   List<int>? messageSeqList,
  //   int? timeBegin,
  //   int? timePeriod,
  // }) async {
  //
  // }
  //
  // Future<V2TimValueCallback<V2TimMessageListResult>> getHistoryMessageListV2({
  //   HistoryMsgGetTypeEnum? getType =
  //       HistoryMsgGetTypeEnum.V2TIM_GET_LOCAL_OLDER_MSG,
  //   String? userID,
  //   String? groupID,
  //   int lastMsgSeq = -1,
  //   required int count,
  //   String? lastMsgID,
  //   List<int>? messageTypeList,
  //   List<int>? messageSeqList,
  //   int? timeBegin,
  //   int? timePeriod,
  // }) async {
  //
  // }
  //
  // Future<LinkedHashMap<dynamic, dynamic>> getHistoryMessageListWithoutFormat({
  //   HistoryMsgGetTypeEnum? getType =
  //       HistoryMsgGetTypeEnum.V2TIM_GET_LOCAL_OLDER_MSG,
  //   String? userID,
  //   String? groupID,
  //   int lastMsgSeq = -1,
  //   required int count,
  //   String? lastMsgID,
  //   List<int>? messageSeqList,
  //   int? timeBegin,
  //   int? timePeriod,
  // }) async {
  //
  // }

  /// 统一调用最新的获取历史消息接口
  // Future<V2TimValueCallback<List<V2TimMessage>>> getHistoryMessageListWithOption({
  //   required V2TIMMessageListGetOption option
  // }) async {
  //   if (option.userID == null && option.groupID == null) {
  //     print('userID and groupID cannot be null at the same time');
  //     return V2TimValueCallback<List<V2TimMessage>>.fromBool(false, 'userID and groupID cannot be null at the same time');
  //   }

  //   if (option.userID != null && option.userID!.isNotEmpty && option.groupID != null && option.groupID!.isNotEmpty) {
  //     print('userID and groupID cannot set at the same time');
  //     return V2TimValueCallback<List<V2TimMessage>>.fromBool(false, 'userID and groupID cannot set at the same time');
  //   }

  //   String convID = '';
  //   TIMConvType convType = TIMConvType.kTIMConv_Invalid;
  //   if (option.userID != null && option.userID!.isNotEmpty)  {
  //     convID = option.userID!;
  //     convType = TIMConvType.kTIMConv_C2C;
  //   } else {
  //     convID = option.groupID!;
  //     convType = TIMConvType.kTIMConv_Group;
  //   }

  //   String userData = Tools.generateUserData('getHistoryMessageListWithOption');
  //   Completer<V2TimValueCallback<List<V2TimMessage>>> completer = Completer();
  //   NativeLibraryManager.timValueCallback2Future(userData, completer);

  //   Pointer<Char> pConvID = Tools.string2PointerChar(convID);
  //   Pointer<Char> pOption = Tools.string2PointerChar(json.encode(option.toJson()));
  //   Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
  //   NativeLibraryManager.bindings.DartGetMessageList(pConvID, convType, pOption, pUserData);

  //   return completer.future;
  // }

  Future<V2TimCallback> revokeMessageWithMessage({required V2TimMessage v2TIMMessage}) async {
    if (v2TIMMessage.status != MessageStatus.V2TIM_MSG_STATUS_SEND_SUCC) {
      print('revokeMessageWithMessage, message status must be V2TIM_MSG_STATUS_SEND_SUCC');
      return V2TimCallback.fromBool(false, 'message status must be V2TIM_MSG_STATUS_SEND_SUCC');
    }

    String convID = v2TIMMessage.messageConvID;
    TIMConvType convType = v2TIMMessage.messageConvType;

    String userData = Tools.generateUserData('revokeMessageWithMessage');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    Pointer<Char> pConvID = Tools.string2PointerChar(convID);
    Pointer<Char> pMessage = Tools.string2PointerChar(json.encode(v2TIMMessage.toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartRevokeMessage(pConvID, convType, pMessage, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> deleteMessageFromLocalStorageWithMessage({required V2TimMessage v2TIMMessage}) async {
    String userData = Tools.generateUserData('deleteMessageFromLocalStorage');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    String convID = v2TIMMessage.messageConvID;
    TIMConvType convType = v2TIMMessage.messageConvType;
    Pointer<Char> pConvID = Tools.string2PointerChar(convID);
    Pointer<Char> pMessage = Tools.string2PointerChar(json.encode(v2TIMMessage.toJson()));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartDeleteMessageFromLocalStorage(pConvID, convType, pMessage, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> deleteMessagesWithMessage({required List<V2TimMessage> messageList}) async {
    if (messageList.isEmpty) {
      print('deleteMessagesWithMessage, messageList is empty');
      return V2TimCallback.fromBool(false, 'messageList is empty');
    }

    String userData = Tools.generateUserData('deleteMessagesWithMessage');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    V2TimMessage v2timMessage = messageList[0];
    String convID = v2timMessage.messageConvID;
    TIMConvType convType = v2timMessage.messageConvType;
    Pointer<Char> pConvID = Tools.string2PointerChar(convID);
    Pointer<Char> pMessageList = Tools.string2PointerChar(json.encode(messageList.map((e) => e.toJson()).toList));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartDeleteMessages(pConvID, convType, pMessageList, pUserData);

    return completer.future;
  }

  Future<V2TimCallback> sendMessageReadReceiptsWithMessage({required List<V2TimMessage> messageList}) async {
    if (messageList.isEmpty) {
      print('sendMessageReadReceiptsWithMessage, messageList is empty');
      return V2TimCallback.fromBool(false, 'messageList is empty');
    }

    String userData = Tools.generateUserData('sendMessageReadReceiptsWithMessage');
    Completer<V2TimCallback> completer = Completer();
    NativeLibraryManager.timCallback2Future(userData, completer);

    Pointer<Char> pMessageList = Tools.string2PointerChar(json.encode(messageList.map((e) => e.toJson()).toList));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartSendMessageReadReceipts(pMessageList, pUserData);

    return completer.future;
  }

  Future<V2TimValueCallback<List<V2TimMessageReceipt>>> getMessageReadReceiptsWithMessage({required List<V2TimMessage> messageList}) async {
    if (messageList.isEmpty) {
      print('getMessageReadReceiptsWithMessage, messageList is empty');
      return V2TimValueCallback<List<V2TimMessageReceipt>>.fromBool(false, 'messageList is empty');
    }

    String userData = Tools.generateUserData('getMessageReadReceiptsWithMessage');
    Completer<V2TimValueCallback<List<V2TimMessageReceipt>>> completer = Completer();
    NativeLibraryManager.timValueCallback2Future(userData, completer);

    Pointer<Char> pMessageList = Tools.string2PointerChar(json.encode(messageList.map((e) => e.toJson()).toList));
    Pointer<Void> pUserData = Tools.string2PointerVoid(userData);
    NativeLibraryManager.bindings.DartGetMessageReadReceipts(pMessageList, pUserData);

    return completer.future;
  }

  void _internalInitMessageListener() {
    _advancedMessageListener = V2TimAdvancedMsgListener(
      onRecvNewMessage: (V2TimMessage msg) {
        for (var listener in v2TimAdvancedMsgListenerList) {
          listener.onRecvNewMessage(msg);
        }
      },

      onRecvMessageModified: (V2TimMessage msg) {
        for (var listener in v2TimAdvancedMsgListenerList) {
          listener.onRecvMessageModified(msg);
        }
      },

      onSendMessageProgress: (V2TimMessage msg, int progress)  {
        for (var listener in v2TimAdvancedMsgListenerList) {
          listener.onSendMessageProgress(msg, progress);
        }
      },

      onMessageDownloadProgressCallback: (V2TimMessageDownloadProgress progress)  {
        for (var listener in v2TimAdvancedMsgListenerList) {
          listener.onMessageDownloadProgressCallback(progress);
        }
      },

      onRecvC2CReadReceipt: (List<V2TimMessageReceipt> receiptList) {
        for (var listener in v2TimAdvancedMsgListenerList) {
          listener.onRecvC2CReadReceipt(receiptList);
        }
      },

      onRecvMessageReadReceipts: (List<V2TimMessageReceipt> receiptList) {
        for (var listener in v2TimAdvancedMsgListenerList) {
          listener.onRecvMessageReadReceipts(receiptList);
        }
      },

      onRecvMessageRevoked: (String msgID) {
        for (var listener in v2TimAdvancedMsgListenerList) {
          listener.onRecvMessageRevoked(msgID);
        }
      },

      onRecvMessageRevokedWithInfo: (String msgID, V2TimUserFullInfo operateUser, String reason) {
        for (var listener in v2TimAdvancedMsgListenerList) {
          listener.onRecvMessageRevokedWithInfo(msgID, operateUser, reason);
        }
      },

      onRecvMessageExtensionsChanged: (String msgID, List<V2TimMessageExtension> extensions) {
        for (var listener in v2TimAdvancedMsgListenerList) {
          listener.onRecvMessageExtensionsChanged(msgID, extensions);
        }
      },

      onRecvMessageExtensionsDeleted: (String msgID, List<String> extensionIDs) {
        for (var listener in v2TimAdvancedMsgListenerList) {
          listener.onRecvMessageExtensionsDeleted(msgID, extensionIDs);
        }
      },

      onRecvMessageReactionsChanged: (List<V2TIMMessageReactionChangeInfo> reactionChangeInfos) {
        for (var listener in v2TimAdvancedMsgListenerList) {
          listener.onRecvMessageReactionsChanged(reactionChangeInfos);
        }
      },

      onGroupMessagePinned: (String groupID, V2TimMessage message, bool isPinned, V2TimGroupMemberInfo opUserInfo) {
        for (var listener in v2TimAdvancedMsgListenerList) {
          listener.onGroupMessagePinned(groupID, message, isPinned, opUserInfo);
        }
      },
    );

    NativeLibraryManager.setAdvancedMessageListener(_advancedMessageListener);
  }

  String _createMessageTempID(){
    ++_messageSeq;
    return '${V2TimMessage.createIDPrefix}$_messageSeq';
  }
}
