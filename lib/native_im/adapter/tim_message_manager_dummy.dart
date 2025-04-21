import 'dart:async';

import 'package:tencent_cloud_chat_sdk/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/get_group_message_read_member_list_filter.dart';
import 'package:tencent_cloud_chat_sdk/enum/history_msg_get_type_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_elem_type.dart';
import 'package:tencent_cloud_chat_sdk/enum/offlinePushInfo.dart';
import 'package:tencent_cloud_chat_sdk/enum/receive_message_opt_enum.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_group_message_read_member_list.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_change_info.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_extension.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_extension_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_list_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_online_url.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_reaction_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_reaction_user_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_receipt.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_search_param.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_search_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_receive_message_opt_info.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_value_callback.dart';

class TIMMessageManager {
  static TIMMessageManager instance = TIMMessageManager();

  TIMMessageManager();

  void init() {}

  void addAdvancedMsgListener(V2TimAdvancedMsgListener? listener) {}

  void removeAdvancedMsgListener({V2TimAdvancedMsgListener? listener}) {}

  V2TimMsgCreateInfoResult createTextMessage({required String text}) {
    return V2TimMsgCreateInfoResult();
  }

  V2TimMsgCreateInfoResult createCustomMessage(
      {required String data, String desc = "", String extension = ""}) {
    return V2TimMsgCreateInfoResult();
  }

  V2TimMsgCreateInfoResult createImageMessage(
      {required String imagePath, String? imageName}) {
    return V2TimMsgCreateInfoResult();
  }

  V2TimMsgCreateInfoResult createVideoMessage(
      {required String videoFilePath,
      required String type,
      required int duration,
      required String snapshotPath}) {
    return V2TimMsgCreateInfoResult();
  }

  V2TimMsgCreateInfoResult createSoundMessage(
      {required String soundPath, required int duration}) {
    return V2TimMsgCreateInfoResult();
  }

  V2TimMsgCreateInfoResult createFileMessage(
      {required String filePath, required String fileName}) {
    return V2TimMsgCreateInfoResult();
  }

  V2TimMsgCreateInfoResult createFaceMessage(
      {required int index, required String data}) {
    return V2TimMsgCreateInfoResult();
  }

  V2TimMsgCreateInfoResult createLocationMessage(
      {required String desc,
      required double longitude,
      required double latitude}) {
    return V2TimMsgCreateInfoResult();
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createMergerMessage(
      {required List<String> msgIDList,
      required String title,
      required List<String> abstractList,
      required String compatibleText}) async {
    return V2TimValueCallback.fromBool(false, "invoke error");
  }

  V2TimMsgCreateInfoResult? createMergerMessageWithMessageList(
      {required List<V2TimMessage> msgList,
      required String title,
      required List<String> abstractList,
      required String compatibleText}) {
    return V2TimMsgCreateInfoResult();
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createForwardMessage(
      {required String msgID}) async {
    return V2TimValueCallback.fromBool(false, "invoke error");
  }

  V2TimMsgCreateInfoResult? createForwardMessageWithMessage(
      {required V2TimMessage message}) {
    return V2TimMsgCreateInfoResult();
  }

  V2TimMsgCreateInfoResult createTargetedGroupMessage(
      {required String id, required List<String> receiverList}) {
    return V2TimMsgCreateInfoResult();
  }

  V2TimMsgCreateInfoResult createTargetedGroupMessageWithMessage(
      {required V2TimMessage message, required List<String> receiverList}) {
    return V2TimMsgCreateInfoResult();
  }

  V2TimMsgCreateInfoResult createAtSignedGroupMessage(
      {required String createdMsgID, required List<String> atUserList}) {
    return V2TimMsgCreateInfoResult();
  }

  V2TimMsgCreateInfoResult? createAtSignedGroupMessageWithMessage(
      {required V2TimMessage message, required List<String> atUserList}) {
    return V2TimMsgCreateInfoResult();
  }

  V2TimMessage appendMessage({
    required String createMessageBaseId,
    required String createMessageAppendId,
  }) {
    return V2TimMessage(elemType: MessageElemType.V2TIM_ELEM_TYPE_NONE);
  }

  V2TimMsgCreateInfoResult createTextAtMessage({
    required String text,
    required List<String> atUserList,
  }) {
    return V2TimMsgCreateInfoResult();
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
    return V2TimValueCallback<V2TimMessage>.fromBool(false, "invoke error");
  }

  Future<V2TimValueCallback<List<V2TimMessage>>> downloadMergerMessage(
      {required String msgID}) async {
    return V2TimValueCallback<List<V2TimMessage>>.fromBool(
        false, "invoke error");
  }

  Future<V2TimValueCallback<V2TimMessage>> reSendMessage({
    required String msgID,
    bool onlineUserOnly = false,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromBool(false, "invoke error");
  }

  Future<V2TimCallback> setC2CReceiveMessageOpt({
    required List<String> userIDList,
    required ReceiveMsgOptEnum opt,
  }) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimValueCallback<List<V2TimReceiveMessageOptInfo>>>
      getC2CReceiveMessageOpt({
    required List<String> userIDList,
  }) async {
    return V2TimValueCallback<List<V2TimReceiveMessageOptInfo>>.fromBool(
        false, "invoke error");
  }

  Future<V2TimCallback> setGroupReceiveMessageOpt({
    required String groupID,
    required ReceiveMsgOptEnum opt,
  }) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimCallback> setLocalCustomData({
    required String msgID,
    required String localCustomData,
  }) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimCallback> setLocalCustomInt({
    required String msgID,
    required int localCustomInt,
  }) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimCallback> setCloudCustomData({
    required String data,
    required String msgID,
  }) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimValueCallback<List<V2TimMessage>>> getC2CHistoryMessageList({
    required String userID,
    required int count,
    String? lastMsgID,
  }) async {
    return V2TimValueCallback<List<V2TimMessage>>.fromBool(
        false, "invoke error");
  }

  Future<V2TimValueCallback<List<V2TimMessage>>> getGroupHistoryMessageList({
    required String groupID,
    required int count,
    String? lastMsgID,
  }) async {
    return V2TimValueCallback<List<V2TimMessage>>.fromBool(
        false, "invoke error");
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
    return V2TimValueCallback<List<V2TimMessage>>.fromBool(
        false, "invoke error");
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
    return V2TimValueCallback<V2TimMessageListResult>.fromBool(
        false, "invoke error");
  }

  Future<V2TimCallback> revokeMessage({required String msgID}) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimCallback> markC2CMessageAsRead({
    required String userID,
  }) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimCallback> markGroupMessageAsRead({
    required String groupID,
  }) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimCallback> markAllMessageAsRead() async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimCallback> deleteMessageFromLocalStorage({
    required String msgID,
  }) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimCallback> deleteMessages({required List<String> msgIDs}) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimValueCallback<V2TimMessage>> insertGroupMessageToLocalStorage({
    required String data,
    required String groupID,
    required String sender,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromBool(false, "invoke error");
  }

  Future<V2TimValueCallback<V2TimMessage>> insertC2CMessageToLocalStorage({
    required String data,
    required String userID,
    required String sender,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromBool(false, "invoke error");
  }

  Future<V2TimValueCallback<V2TimMessage>> insertGroupMessageToLocalStorageV2({
    required String groupID,
    required String senderID,
    required String createdMsgID,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromBool(false, "invoke error");
  }

  Future<V2TimValueCallback<V2TimMessage>> insertC2CMessageToLocalStorageV2({
    required String userID,
    required String senderID,
    required String createdMsgID,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromBool(false, "invoke error");
  }

  Future<V2TimCallback> clearC2CHistoryMessage({
    required String userID,
  }) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimCallback> clearGroupHistoryMessage({
    required String groupID,
  }) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimValueCallback<V2TimMessageSearchResult>> searchLocalMessages({
    required V2TimMessageSearchParam searchParam,
  }) async {
    return V2TimValueCallback<V2TimMessageSearchResult>.fromBool(
        false, "invoke error");
  }

  Future<V2TimValueCallback<V2TimMessageSearchResult>> searchCloudMessages({
    required V2TimMessageSearchParam searchParam,
  }) async {
    return V2TimValueCallback<V2TimMessageSearchResult>.fromBool(
        false, "invoke error");
  }

  Future<V2TimCallback> sendMessageReadReceipts({
    required List<String> messageIDList,
  }) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimValueCallback<List<V2TimMessageReceipt>>> getMessageReadReceipts({
    required List<String> messageIDList,
  }) async {
    return V2TimValueCallback<List<V2TimMessageReceipt>>.fromBool(
        false, "invoke error");
  }

  Future<V2TimValueCallback<V2TimGroupMessageReadMemberList>>
      getGroupMessageReadMemberList({
    required String messageID,
    required GetGroupMessageReadMemberListFilter filter,
    required int nextSeq,
    required int count,
  }) async {
    return V2TimValueCallback<V2TimGroupMessageReadMemberList>.fromBool(
        false, "invoke error");
  }

  Future<V2TimValueCallback<List<V2TimMessage>>> findMessages({
    required List<String> messageIDList,
  }) async {
    return V2TimValueCallback<List<V2TimMessage>>.fromBool(
        false, "invoke error");
  }

  Future<V2TimValueCallback<List<V2TimMessageExtensionResult>>>
      setMessageExtensions({
    required String msgID,
    required List<V2TimMessageExtension> extensions,
  }) async {
    return V2TimValueCallback<List<V2TimMessageExtensionResult>>.fromBool(
        false, "invoke error");
  }

  Future<V2TimValueCallback<List<V2TimMessageExtension>>> getMessageExtensions({
    required String msgID,
  }) async {
    return V2TimValueCallback<List<V2TimMessageExtension>>.fromBool(
        false, "invoke error");
  }

  Future<V2TimValueCallback<List<V2TimMessageExtensionResult>>>
      deleteMessageExtensions({
    required String msgID,
    required List<String> keys,
  }) async {
    return V2TimValueCallback<List<V2TimMessageExtensionResult>>.fromBool(
        false, "invoke error");
  }

  Future<V2TimValueCallback<V2TimMessageChangeInfo>> modifyMessage({
    required V2TimMessage message,
  }) async {
    return V2TimValueCallback<V2TimMessageChangeInfo>.fromBool(
        false, "invoke error");
  }

  Future<V2TimValueCallback<V2TimMessageOnlineUrl>> getMessageOnlineUrl({
    required String msgID,
  }) async {
    return V2TimValueCallback<V2TimMessageOnlineUrl>.fromBool(
        false, "invoke error");
  }

  Future<V2TimCallback> downloadMessage({
    required String msgID,
    required int imageType,
    required bool isSnapshot,
    String? downloadPath,
  }) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimValueCallback<Map<String, String>>> translateText({
    required List<String> texts,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    return V2TimValueCallback<Map<String, String>>.fromBool(
        false, "invoke error");
  }

  Future<V2TimCallback> setAllReceiveMessageOpt({
    required int opt,
    required int startHour,
    required int startMinute,
    required int startSecond,
    required int duration,
  }) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimCallback> setAllReceiveMessageOptWithTimestamp({
    required int opt,
    required int startTimeStamp,
    required int duration,
  }) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimValueCallback<V2TimReceiveMessageOptInfo>>
      getAllReceiveMessageOpt() async {
    return V2TimValueCallback<V2TimReceiveMessageOptInfo>.fromBool(
        false, "invoke error");
  }

  Future<V2TimCallback> addMessageReaction({
    required String msgID,
    required String reactionID,
  }) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimCallback> removeMessageReaction({
    required String msgID,
    required String reactionID,
  }) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimValueCallback<List<V2TimMessageReactionResult>>>
      getMessageReactions({
    required List<String> msgIDList,
    required int maxUserCountPerReaction,
  }) async {
    return V2TimValueCallback<List<V2TimMessageReactionResult>>.fromBool(
        false, "invoke error");
  }

  Future<V2TimValueCallback<V2TimMessageReactionUserResult>>
      getAllUserListOfMessageReaction({
    required String msgID,
    required String reactionID,
    required int nextSeq,
    required int count,
  }) async {
    return V2TimValueCallback<V2TimMessageReactionUserResult>.fromBool(
        false, "invoke error");
  }

  Future<V2TimValueCallback<String>> convertVoiceToText({
    required String msgID,
    required String language,
  }) async {
    return V2TimValueCallback<String>.fromBool(false, "invoke error");
  }

  Future<V2TimCallback> pinGroupMessage({
    required String msgID,
    required String groupID,
    required bool isPinned,
  }) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimValueCallback<List<V2TimMessage>>> getPinnedGroupMessageList({
    required String groupID,
  }) async {
    return V2TimValueCallback<List<V2TimMessage>>.fromBool(
        false, "invoke error");
  }

  Future<V2TimCallback> revokeMessageWithMessage(
      {required V2TimMessage v2TIMMessage}) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimCallback> deleteMessageFromLocalStorageWithMessage(
      {required V2TimMessage v2TIMMessage}) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimCallback> deleteMessagesWithMessage(
      {required List<V2TimMessage> messageList}) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimCallback> sendMessageReadReceiptsWithMessage(
      {required List<V2TimMessage> messageList}) async {
    return V2TimCallback.fromBool(false, "invoke error");
  }

  Future<V2TimValueCallback<List<V2TimMessageReceipt>>>
      getMessageReadReceiptsWithMessage(
          {required List<V2TimMessage> messageList}) async {
    return V2TimValueCallback<List<V2TimMessageReceipt>>.fromBool(
        false, "invoke error");
  }
}
