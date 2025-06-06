// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:collection';
import 'dart:html' as html show window;
import 'dart:js';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimUIKitListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/callbacks.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_conversation_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_reaction_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_reaction_user_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/utils/utils.dart';
import 'package:tencent_cloud_chat_sdk/web/manager/v2_tim_conversation_manager.dart';
import 'package:tencent_cloud_chat_sdk/web/manager/v2_tim_friendship_manager.dart';
import 'package:tencent_cloud_chat_sdk/web/manager/v2_tim_group_manager.dart';
import 'package:tencent_cloud_chat_sdk/web/manager/v2_tim_manager.dart';
import 'package:tencent_cloud_chat_sdk/web/manager/v2_tim_message_manager.dart';
import 'package:tencent_cloud_chat_sdk/web/manager/v2_tim_signaling_manager.dart';
import 'tencent_cloud_chat_sdk_platform_interface.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimConversationListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimFriendshipListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimGroupListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSignalingListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/get_group_message_read_member_list_filter.dart';
import 'package:tencent_cloud_chat_sdk/enum/history_message_get_type.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/offlinePushInfo.dart';
import 'package:tencent_cloud_chat_sdk/enum/v2_tim_plugins.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_topic_info.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_conversation.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_conversation_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_friend_application_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_friend_check_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_friend_group.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_friend_info_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_friend_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_friend_search_param.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_group_application_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_group_info_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_group_member.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_group_member_full_info.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_group_member_info_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_group_member_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_group_member_search_param.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_group_member_search_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_group_message_read_member_list.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_group_search_param.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_change_info.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_list_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_online_url.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_receipt.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_search_param.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_search_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_receive_message_opt_info.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_signaling_info.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_topic_info_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_topic_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_user_full_info.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_user_status.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_msg_create_info_result.dart';

/// A web implementation of the TencentCloudChatSdkPlatform of the TencentCloudChatSdk plugin.
class TencentCloudChatSdkWeb extends TencentCloudChatSdkPlatform {
  static final V2TIMManager _v2timManager = V2TIMManager();
  static final V2TIMGroupManager _v2timGroupManager = V2TIMGroupManager();
  static final V2TIMConversationManager _v2TIMConversationManager =
      V2TIMConversationManager();
  static final V2TIMFriendshipManager _v2timFriendshipManager =
      V2TIMFriendshipManager();

  static final V2TIMSignalingManager _v2timSignalingManager =
      V2TIMSignalingManager();
  static final V2TIMMessageManager _v2timMessageManager = V2TIMMessageManager();

  static final Map<String, V2TimSimpleMsgListener> simpleMessageListenerList =
      {};
  static final Map<String, V2TimSDKListener> initSDKListenerList = {};

  static final Map<String, V2TimGroupListener> groupListenerList = {};

  static final Map<String, V2TimConversationListener> conversationListenerList =
      {};

  static final Map<String, V2TimFriendshipListener> friendListenerList = {};

  static final Map<String, V2TimSignalingListener> signalingListenerList = {};
  static final Map<String, V2TimAdvancedMsgListener> advancedMsgListenerList =
      {};

  static final Map<String, V2TimUIKitListener> uikitIKitListener = {};

  /// Constructs a TencentCloudChatSdkWeb
  TencentCloudChatSdkWeb();

  static void registerWith(Registrar registrar) {
    TencentCloudChatSdkPlatform.instance = TencentCloudChatSdkWeb();
  }

  @override
  addNativeCallback() {}

  @override
  Future<void> emitUIKitEvent(UIKitEvent event) async {}

  @override
  Future<void> emitPluginEvent(PluginEvent event) async {}

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = html.window.navigator.userAgent;
    return version;
  }

  @override
  Future<V2TimCallback> cleanConversationUnreadMessageCount({
    required String conversationID,
    required int cleanTimestamp,
    required int cleanSequence,
  }) async {
    if (conversationID.toLowerCase().startsWith("c2c")) {
      return await _v2timMessageManager.markC2CMessageAsRead({
        "userID": conversationID.replaceFirst("c2c_", ""),
      });
    } else if (conversationID.startsWith("group")) {
      return await _v2timMessageManager.markGroupMessageAsRead({
        "groupID": conversationID.replaceFirst("group_", ""),
      });
    } else {
      return V2TimCallback.fromJson(
          {'code': -1, "desc": "conversationID format error"});
    }
  }

  @override
  Future<void> uikitTrace({
    required String trace,
  }) async {
    debugPrint(trace);
  }

  @override
  Future<V2TimValueCallback<bool>> initSDK({
    required int sdkAppID,
    required int loglevel,
    String? listenerUuid,
    required int uiPlatform,
    bool? showImLog,
    List<V2TimPlugins>? plugins,
    V2TimSDKListener? listener,
  }) async {
    if (context['tencent_cloud_im_csig_flutter_for_web_25F_cy'] == null) {
      context['tencent_cloud_im_csig_flutter_for_web_25F_cy'] = "flutter_web";
    }
    return _v2timManager.initSDK(sdkAppID: sdkAppID, listener: listener);
  }

  @override
  Future<V2TimCallback> unInitSDK() async {
    return await _v2timManager.unInitSDK();
  }

  @override
  Future<V2TimValueCallback<int>> getServerTime() async {
    return await _v2timManager.getServerTime();
  }

  @override
  Future<V2TimCallback> login({
    required String userID,
    required String userSig,
  }) async {
    return await _v2timManager.login(userID: userID, userSig: userSig);
  }

  @override
  Future<V2TimCallback> logout() async {
    return await _v2timManager.logout();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendC2CTextMessage({
    required String text,
    required String userID,
  }) async {
    return await _v2timManager
        .sendC2CTextMessage({"text": text, "userID": userID});
  }

  @override
  Future<V2TimValueCallback<String>> getLoginUser() async {
    return await _v2timManager.getLoginUser();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendC2CCustomMessage({
    required String customData,
    required String userID,
  }) async {
    return await _v2timManager
        .sendC2CCustomMessage({"customData": customData, "userID": userID});
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendGroupTextMessage({
    required String text,
    required String groupID,
    int priority = 0,
  }) async {
    return await _v2timManager.sendGroupTextMessage({
      "text": text,
      "groupID": groupID,
      "priority": priority,
    });
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendGroupCustomMessage({
    required String customData,
    required String groupID,
    int priority = 0,
  }) async {
    return await _v2timManager.sendGroupCustomMessage({
      "customData": customData,
      "groupID": groupID,
      "priority": priority,
    });
  }

  @override
  Future<V2TimValueCallback<String>> getVersion() async {
    return await _v2timManager.getVersion();
  }

  @override
  Future<V2TimValueCallback<int>> getLoginStatus() async {
    return await _v2timManager.getLoginStatus();
  }

  @override
  Future<V2TimValueCallback<List<V2TimUserFullInfo>>> getUsersInfo({
    required List<String> userIDList,
  }) async {
    return await _v2timManager.getUsersInfo({"userIDList": userIDList});
  }

  // @override
  // Future<V2TimValueCallback<String>> createGroup({
  //   required String groupType,
  //   required String groupName,
  //   String? groupID,
  // }) async {
  //   return await _v2timGroupManager.createGroup(
  //       {"groupType": groupType, "groupName": groupName, "groupID": groupID});
  // }

  @override
  Future<V2TimCallback> joinGroup({
    required String groupID,
    required String message,
    String? groupType,
  }) async {
    return await _v2timGroupManager.joinGroup(
        {"groupID": groupID, "message": message, "groupType": groupType});
  }

  @override
  Future<V2TimCallback> dismissGroup({
    required String groupID,
  }) async {
    return await _v2timManager.dismissGroup({"groupID": groupID});
  }

  @override
  Future<V2TimCallback> quitGroup({
    required String groupID,
  }) async {
    return await _v2timManager.quitGroup({"groupID": groupID});
  }

  @override
  Future<V2TimCallback> setSelfInfo({
    required V2TimUserFullInfo userFullInfo,
  }) async {
    return await _v2timManager.setSelfInfo(
      {
        "nickName": userFullInfo.nickName,
        "faceUrl": userFullInfo.faceUrl,
        "birthday": userFullInfo.birthday,
        "selfSignature": userFullInfo.selfSignature,
        "gender": userFullInfo.gender,
        "allowType": userFullInfo.allowType,
        "customInfo": userFullInfo.customInfo
      },
    );
  }

  @override
  Future<V2TimValueCallback<Object>> callExperimentalAPI({
    required String api,
    Object? param,
  }) async {
    return await _v2timManager.callExperimentalAPI();
  }

  @override
  Future<String> addSimpleMsgListener({
    required V2TimSimpleMsgListener listener,
  }) async {
    _v2timManager.addSimpleMsgListener(listener);
    return "";
  }

  @override
  Future<void> removeSimpleMsgListener({
    V2TimSimpleMsgListener? listener,
    String? uuid,
  }) async {
    _v2timManager.removeSimpleMsgListener();
  }

  /// ***************************会话模块***********************************/
  @override
  Future<V2TimValueCallback<V2TimConversationResult>> getConversationList({
    required String nextSeq,
    required int count,
  }) async {
    // web中nextSeq，count等分页参数不生效
    return await _v2TIMConversationManager.getConversationList();
  }

  @override
  Future<void> setConversationListener(
      {required V2TimConversationListener listener,
      String? listenerUuid}) async {
    listenerUuid = Utils.generateUniqueString();
    _v2TIMConversationManager.setConversationListener(listener, listenerUuid);
  }

  @override
  Future<void> addConversationListener(
      {required V2TimConversationListener listener}) async {
    final String uuid = Utils.generateUniqueString();
    conversationListenerList[uuid] = listener;
    _v2TIMConversationManager.setConversationListener(listener, uuid);
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversation>>>
      getConversationListByConversationIds({
    required List<String> conversationIDList,
  }) async {
    final List<String> formatedConversationIDList = conversationIDList.map((e) {
      var formatedConversationID = e.replaceAll("c2c_", "C2C");
      formatedConversationID =
          formatedConversationID.replaceAll("group_", "GROUP");
      return formatedConversationID;
    }).toList();
    return await _v2TIMConversationManager.getConversationListByConversaionIds(
        {"conversationIDList": formatedConversationIDList});
  }

  @override
  Future<V2TimValueCallback<V2TimConversation>> getConversation({
    required String conversationID,
  }) async {
    var formatedConversationID = conversationID.replaceAll("c2c_", "C2C");
    formatedConversationID =
        formatedConversationID.replaceAll("group_", "GROUP");
    return await _v2TIMConversationManager.getConversation(
        conversationID: formatedConversationID);
  }

  @override
  Future<V2TimCallback> deleteConversation({
    required String conversationID,
  }) async {
    var formatedConversationID = conversationID.replaceAll("c2c_", "C2C");
    formatedConversationID =
        formatedConversationID.replaceAll("group_", "GROUP");
    return await _v2TIMConversationManager
        .deleteConversation({"conversationID": formatedConversationID});
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      deleteConversationList({
    required List<String> conversationIDList,
    required bool clearMessage,
  }) async {
    final List<String> formatedConversationIDList = conversationIDList.map((e) {
      var formatedConversationID = e.replaceAll("c2c_", "C2C");
      formatedConversationID =
          formatedConversationID.replaceAll("group_", "GROUP");
      return formatedConversationID;
    }).toList();
    return await _v2TIMConversationManager.deleteConversationList(
      conversationIDList: formatedConversationIDList,
      clearMessage: clearMessage,
    );
  }

  @override
  Future<V2TimCallback> setConversationDraft({
    required String conversationID,
    String? draftText,
  }) async {
    return await _v2TIMConversationManager.setConversationDraft();
  }

  @override
  Future<V2TimCallback> pinConversation({
    required String conversationID,
    required bool isPinned,
  }) async {
    var formatedConversationID = conversationID.replaceAll("c2c_", "C2C");
    formatedConversationID =
        formatedConversationID.replaceAll("group_", "GROUP");
    return await _v2TIMConversationManager.pinConversation({
      "conversationID": formatedConversationID,
      "isPinned": isPinned,
    });
  }

  @override
  Future<V2TimValueCallback<int>> getTotalUnreadMessageCount() async {
    return await _v2TIMConversationManager.getTotalUnreadMessageCount();
  }

  /// ***************************好友关系模块***********************************/
  @override
  Future<V2TimValueCallback<List<V2TimFriendInfo>>> getFriendList() async {
    return await _v2timFriendshipManager.getFriendList();
  }

  @override
  Future<void> setFriendListener(
      {required V2TimFriendshipListener listener, String? listenerUuid}) async {
    listenerUuid = Utils.generateUniqueString();
    _v2timFriendshipManager.setFriendListener(listener, listenerUuid);
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendInfoResult>>> getFriendsInfo({
    required List<String> userIDList,
  }) async {
    return await _v2timFriendshipManager
        .getFriendsInfo({"userIDList": userIDList});
  }

  @override
  Future<V2TimValueCallback<V2TimFriendOperationResult>> addFriend({
    required String userID,
    String? remark,
    String? friendGroup,
    String? addWording,
    String? addSource,
    required int addType,
  }) async {
    return await _v2timFriendshipManager.addFriend({
      "userID": userID,
      "remark": remark,
      "friendGroup": friendGroup,
      "addWording": addWording,
      "addSource": addSource,
      "addType": addType
    });
  }

  @override
  Future<V2TimCallback> setFriendInfo({
    required String userID,
    String? friendRemark,
    Map<String, String>? friendCustomInfo,
  }) async {
    return await _v2timFriendshipManager.setFriendInfo({
      "userID": userID,
      "friendRemark": friendRemark,
      "friendCustomInfo": friendCustomInfo
    });
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFromFriendList({
    required List<String> userIDList,
    required int deleteType,
  }) async {
    return await _v2timFriendshipManager.deleteFromFriendList(
        {"userIDList": userIDList, "deleteType": deleteType});
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendCheckResult>>> checkFriend({
    required List<String> userIDList,
    required int checkType,
  }) async {
    return await _v2timFriendshipManager
        .checkFriend({"userIDList": userIDList, "checkType": checkType});
  }

  @override
  Future<V2TimValueCallback<V2TimFriendApplicationResult>>
      getFriendApplicationList() async {
    return await _v2timFriendshipManager.getFriendApplicationList();
  }

  @override
  Future<V2TimValueCallback<V2TimFriendOperationResult>>
      acceptFriendApplication({
    required int responseType,
    required int type,
    required String userID,
  }) async {
    return await _v2timFriendshipManager.acceptFriendApplication(
        {"responseType": responseType, "type": type, "userID": userID});
  }

  @override
  Future<V2TimValueCallback<V2TimFriendOperationResult>>
      refuseFriendApplication({
    required int type,
    required String userID,
  }) async {
    return await _v2timFriendshipManager
        .refuseFriendApplication({"type": type, "userID": userID});
  }

  @override
  Future<V2TimCallback> deleteFriendApplication({
    required int type,
    required String userID,
  }) async {
    return await _v2timFriendshipManager
        .deleteFriendApplication({"type": type, "userID": userID});
  }

  @override
  Future<V2TimCallback> setFriendApplicationRead() async {
    return await _v2timFriendshipManager.setFriendApplicationRead();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendInfo>>> getBlackList() async {
    return await _v2timFriendshipManager.getBlackList();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>> addToBlackList({
    required List<String> userIDList,
  }) async {
    return await _v2timFriendshipManager
        .addToBlackList({"userIDList": userIDList});
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFromBlackList({
    required List<String> userIDList,
  }) async {
    return await _v2timFriendshipManager
        .deleteFromBlackList({"userIDList": userIDList});
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      createFriendGroup({
    required String groupName,
    List<String>? userIDList,
  }) async {
    return await _v2timFriendshipManager
        .createFriendGroup({"groupName": groupName, "userIDList": userIDList});
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendGroup>>> getFriendGroups({
    List<String>? groupNameList,
  }) async {
    return await _v2timFriendshipManager
        .getFriendGroups({"groupNameList": groupNameList});
  }

  @override
  Future<V2TimCallback> deleteFriendGroup({
    required List<String> groupNameList,
  }) async {
    return await _v2timFriendshipManager
        .deleteFriendGroup({"groupNameList": groupNameList});
  }

  @override
  Future<V2TimCallback> renameFriendGroup({
    required String oldName,
    required String newName,
  }) async {
    return await _v2timFriendshipManager
        .renameFriendGroup({"oldName": oldName, "newName": newName});
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      addFriendsToFriendGroup({
    required String groupName,
    required List<String> userIDList,
  }) async {
    return await _v2timFriendshipManager.addFriendsToFriendGroup(
        {"groupName": groupName, "userIDList": userIDList});
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFriendsFromFriendGroup({
    required String groupName,
    required List<String> userIDList,
  }) async {
    return await _v2timFriendshipManager.deleteFriendsFromFriendGroup({
      "groupName": groupName,
      "userIDList": userIDList,
    });
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendInfoResult>>> searchFriends({
    required V2TimFriendSearchParam searchParam,
  }) async {
    return await _v2timFriendshipManager.searchFriends();
  }

  /// ***************************群组模块***********************************/
  @override
  Future<V2TimValueCallback<List<V2TimGroupInfo>>> getJoinedGroupList() async {
    return await _v2timGroupManager.getJoinedGroupList();
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupInfo>>>
      getJoinedCommunityList() async {
    return await _v2timGroupManager.getJoinedCommunityList();
  }

  @override
  Future<V2TimValueCallback<String>> createTopicInCommunity({
    required String groupID,
    required V2TimTopicInfo topicInfo,
  }) async {
    final res = await _v2timGroupManager.createTopicInCommunity(
        groupID: groupID, topicInfo: topicInfo);
    return res;
  }

  @override
  Future<V2TimValueCallback<List<V2TimTopicInfoResult>>> getTopicInfoList({
    required String groupID,
    required List<String> topicIDList,
  }) async {
    return await _v2timGroupManager.getTopicInfoList(
        groupID: groupID, topicIDList: topicIDList);
  }

  @override
  Future<V2TimCallback> setTopicInfo({
    required V2TimTopicInfo topicInfo,
  }) async {
    return await _v2timGroupManager.setTopicInfo(topicInfo: topicInfo);
  }

  @override
  Future<V2TimValueCallback<List<V2TimTopicOperationResult>>>
      deleteTopicFromCommunity({
    required String groupID,
    required List<String> topicIDList,
  }) async {
    return await _v2timGroupManager.deleteTopicFromCommunity(
        groupID: groupID, topicIDList: topicIDList);
  }

  @override
  Future<V2TimValueCallback<String>> createGroup({
    String? groupID,
    required String groupType,
    required String groupName,
    String? notification,
    String? introduction,
    String? faceUrl,
    bool? isAllMuted,
    int? addOpt,
    List<V2TimGroupMember>? memberList,
    bool? isSupportTopic = false,
    int? approveOpt,
    bool? isEnablePermissionGroup,
    int? defaultPermissions,
  }) async {
    return await _v2timGroupManager.createGroup({
      "groupID": groupID,
      "groupType": groupType,
      "groupName": groupName,
      "notification": notification,
      "introduction": introduction,
      "faceUrl": faceUrl,
      "isAllMuted": isAllMuted,
      "addOpt": addOpt,
      "memberList": memberList,
      "isSupportTopic": isSupportTopic,
      "approveOpt": approveOpt,
      "isEnablePermissionGroup": isEnablePermissionGroup ?? false,
      "defaultPermissions": defaultPermissions ?? 0,
    });
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupInfoResult>>> getGroupsInfo({
    required List<String> groupIDList,
  }) async {
    return await _v2timGroupManager.getGroupsInfo({"groupIDList": groupIDList});
  }

  @override
  Future<V2TimCallback> setGroupInfo({
    required V2TimGroupInfo info,
  }) async {
    return await _v2timGroupManager.setGroupInfo(info: info);
  }

  @override
  Future<V2TimCallback> setGroupAttributes({
    required String groupID,
    required Map<String, String> attributes,
  }) async {
    return await _v2timGroupManager
        .setGroupAttributes({"groupID": groupID, "attributes": attributes});
  }

  @override
  Future<V2TimCallback> deleteGroupAttributes({
    required String groupID,
    required List<String> keys,
  }) async {
    return await _v2timGroupManager
        .deleteGroupAttributes({"groupID": groupID, "keys": keys});
  }

  @override
  Future<V2TimValueCallback<Map<String, String>>> getGroupAttributes({
    required String groupID,
    List<String>? keys,
  }) async {
    return await _v2timGroupManager
        .getGroupAttributes({"groupID": groupID, "keys": keys});
  }

  @override
  Future<V2TimValueCallback<int>> getGroupOnlineMemberCount({
    required String groupID,
  }) async {
    return await _v2timGroupManager
        .getGroupOnlineMemberCount({"groupID": groupID});
  }

  @override
  Future<V2TimValueCallback<V2TimGroupMemberInfoResult>> getGroupMemberList({
    required String groupID,
    required int filter,
    required String nextSeq,
    int count = 15,
    int offset = 0,
  }) async {
    return await _v2timGroupManager.getGroupMemberList({
      "groupID": groupID,
      "filter": filter,
      "nextSeq": nextSeq,
      "count": count,
      "offset": offset
    });
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupMemberFullInfo>>>
      getGroupMembersInfo({
    required String groupID,
    required List<String> memberList,
  }) async {
    return await _v2timGroupManager
        .getGroupMembersInfo({"groupID": groupID, "memberList": memberList});
  }

  @override
  Future<V2TimCallback> setGroupMemberInfo({
    required String groupID,
    required String userID,
    String? nameCard,
    Map<String, String>? customInfo,
  }) async {
    return await _v2timGroupManager.setGroupMemberInfo({
      "groupID": groupID,
      "userID": userID,
      "nameCard": nameCard,
      "customInfo": customInfo
    });
  }

  @override
  Future<V2TimCallback> muteGroupMember({
    required String groupID,
    required String userID,
    required int seconds,
  }) async {
    return await _v2timGroupManager.muteGroupMember({
      "groupID": groupID,
      "userID": userID,
      "seconds": seconds,
    });
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupMemberOperationResult>>>
      inviteUserToGroup({
    required String groupID,
    required List<String> userList,
  }) async {
    return await _v2timGroupManager.inviteUserToGroup({
      "groupID": groupID,
      "userList": userList,
    });
  }

  @override
  Future<V2TimCallback> kickGroupMember({
    required String groupID,
    required List<String> memberList,
    int? duration,
    String? reason,
  }) async {
    return await _v2timGroupManager.kickGroupMember({
      "groupID": groupID,
      "memberList": memberList,
      "duration": duration ?? 0,
    });
  }

  @override
  Future<V2TimCallback> setGroupMemberRole({
    required String groupID,
    required String userID,
    required int role,
  }) async {
    return await _v2timGroupManager.setGroupMemberRole({
      "groupID": groupID,
      "userID": userID,
      "role": role,
    });
  }

  @override
  Future<V2TimCallback> transferGroupOwner({
    required String groupID,
    required String userID,
  }) async {
    return await _v2timGroupManager.transferGroupOwner({
      "groupID": groupID,
      "userID": userID,
    });
  }

  @override
  Future<V2TimValueCallback<V2TimGroupApplicationResult>>
      getGroupApplicationList() async {
    return _v2timGroupManager.getGroupApplicationList();
  }

  @override
  Future<V2TimCallback> acceptGroupApplication({
    required String groupID,
    String? reason,
    required String fromUser,
    required String toUser,
    int? addTime,
    int? type,
    String? webMessageInstance,
  }) async {
    return await _v2timGroupManager.acceptGroupApplication({
      "groupID": groupID,
      "reason": reason,
      "fromUser": fromUser,
      "toUser": toUser,
      "addTime": addTime,
      "type": type,
      "webMessageInstance": webMessageInstance
    });
  }

  @override
  Future<V2TimCallback> refuseGroupApplication({
    required String groupID,
    String? reason,
    required String fromUser,
    required String toUser,
    required int addTime,
    required int type,
    String? webMessageInstance,
  }) async {
    return await _v2timGroupManager.refuseGroupApplication({
      "groupID": groupID,
      "reason": reason,
      "fromUser": fromUser,
      "toUser": toUser,
      "addTime": addTime,
      "type": type,
      "webMessageInstance": webMessageInstance
    });
  }

  @override
  Future<V2TimCallback> setGroupApplicationRead() async {
    return _v2timGroupManager.setGroupApplicationRead();
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupInfo>>> searchGroups({
    required V2TimGroupSearchParam searchParam,
  }) async {
    return _v2timGroupManager.searchGroups();
  }

  @override
  Future<V2TimValueCallback<V2GroupMemberInfoSearchResult>> searchGroupMembers({
    required V2TimGroupMemberSearchParam param,
  }) async {
    return _v2timGroupManager.searchGroupMembers();
  }

  @override
  Future<V2TimValueCallback<V2TimGroupInfo>> searchGroupByID({
    required String groupID,
  }) async {
    return _v2timGroupManager.searchGroupsByID();
  }

  @override
  Future<V2TimCallback> initGroupAttributes({
    required String groupID,
    required Map<String, String> attributes,
  }) async {
    return _v2timGroupManager.initGroupAttributes();
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createTextMessage(
      {required String text}) async {
    return _v2timMessageManager.createTextMessage(text: text);
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createCustomMessage(
      {required String data, String? desc, String? extension}) async {
    return _v2timMessageManager.createCustomMessage(
        data: data, desc: desc, extension: extension);
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createImageMessage({
    required String imagePath,
    String? imageName,
    Uint8List? fileContent,
    dynamic inputElement,
  }) async {
    return _v2timMessageManager.createImageMessage({
      "inputElement": inputElement,
      "imagePath": imagePath,
      "imageName": imageName,
    });
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createVideoMessage({
    required String videoFilePath,
    required String? type,
    required int? duration,
    required String? snapshotPath,
    dynamic inputElement,
  }) async {
    return _v2timMessageManager.createVideoMessage({
      "videoFilePath": videoFilePath,
      "type": type,
      "duration": duration,
      "snapshotPath": snapshotPath,
      "inputElement": inputElement,
    });
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createFaceMessage({
    required int index,
    required String data,
  }) async {
    return _v2timMessageManager.createFaceMessage(index: index, data: data);
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createFileMessage(
      {required String filePath,
      required String fileName,
      dynamic inputElement}) async {
    return _v2timMessageManager.createFileMessage({
      "filePath": filePath,
      "fileName": fileName,
      "inputElement": inputElement
    });
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createTextAtMessage({
    required String text,
    required List<String> atUserList,
  }) async {
    return _v2timMessageManager.createTextAtMessage(
        text: text, atUserList: atUserList);
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createLocationMessage({
    required String desc,
    required double longitude,
    required double latitude,
  }) async {
    return _v2timMessageManager.createLocationMessage(
        desc: desc, longitude: longitude, latitude: latitude);
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createMergerMessage(
      {required List<String> msgIDList,
      required String title,
      required List<String> abstractList,
      required String compatibleText,
      List<String>? webMessageInstanceList}) async {
    return _v2timMessageManager.createMergerMessage(
        msgIDList: msgIDList,
        title: title,
        abstractList: abstractList,
        compatibleText: compatibleText,
        webMessageInstanceList: webMessageInstanceList);
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createForwardMessage(
      {required String msgID, String? webMessageInstance}) async {
    return _v2timMessageManager.createForwardMessage(msgID: msgID);
  }

  /// 3.6.0 新接口统一发送消息实例
  @override
  Future<V2TimValueCallback<V2TimMessage>> sendMessage(
      {String? id,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      bool isExcludedFromLastMessage = false,
      bool? isSupportMessageExtension = false,
      bool? isExcludedFromContentModeration = false,
      bool needReadReceipt = false,
      Map<String, dynamic>? offlinePushInfo,
      String? cloudCustomData, // 云自定义消息字段，只能在消息发送前添加
      String? localCustomData // 本地自定义消息字段
      }) async {
    return await _v2timMessageManager
        .sendMessageForNew<V2TimValueCallback<V2TimMessage>, V2TimMessage>(
            params: {
          "id": id,
          "receiver": receiver,
          "groupID": groupID,
          "priority": priority,
          "onlineUserOnly": onlineUserOnly,
          "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
          "isExcludedFromLastMessage": isExcludedFromLastMessage,
          "cloudCustomData": cloudCustomData,
          "needReadReceipt": needReadReceipt
        });
  }

  @override

  ///发送高级文本消息
  Future<V2TimValueCallback<V2TimMessage>> sendTextMessage({
    required String text,
    required String receiver,
    required String groupID,
    String? id,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    return await _v2timMessageManager
        .sendTextMessage<V2TimValueCallback<V2TimMessage>, V2TimMessage>({
      "text": text,
      "receiver": receiver,
      "groupID": groupID,
      "priority": priority,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo
    });
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendCustomMessage({
    required String data,
    required String receiver,
    required String groupID,
    int priority = 0,
    String desc = "",
    String extension = "",
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    return await _v2timMessageManager
        .sendCustomMessage<V2TimValueCallback<V2TimMessage>, V2TimMessage>({
      "data": data,
      "receiver": receiver,
      "groupID": groupID,
      "priority": priority,
      "desc": desc,
      "extension": extension,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo,
    });
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendImageMessage(
      {required String imagePath,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      Map<String, dynamic>? offlinePushInfo,
      String? fileName,
      Uint8List? fileContent}) async {
    return await _v2timMessageManager
        .sendImageMessage<V2TimValueCallback<V2TimMessage>, V2TimMessage>({
      "imagePath": imagePath,
      "receiver": receiver,
      "groupID": groupID,
      "priority": priority,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo,
      "fileName": fileName,
      "fileContent": fileContent
    });
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendVideoMessage({
    required String videoFilePath,
    required String receiver,
    required String type,
    required String snapshotPath,
    required int duration,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
    String? fileName,
    Uint8List? fileContent,
  }) async {
    return await _v2timMessageManager
        .sendVideoMessage<V2TimValueCallback<V2TimMessage>, V2TimMessage>({
      "videoFilePath": videoFilePath,
      "receiver": receiver,
      "snapshotPath": snapshotPath,
      "duration": duration,
      "type": type,
      "groupID": groupID,
      "priority": priority,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo,
      "fileName": fileName,
      "fileContent": fileContent
    });
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendFileMessage(
      {required String filePath,
      required String fileName,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      Map<String, dynamic>? offlinePushInfo,
      Uint8List? fileContent}) async {
    return await _v2timMessageManager
        .sendFileMessage<V2TimValueCallback<V2TimMessage>, V2TimMessage>({
      "filePath": filePath,
      "fileName": fileName,
      "receiver": receiver,
      "groupID": groupID,
      "priority": priority,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo,
      "fileContent": fileContent
    });
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendSoundMessage({
    required String soundPath,
    required String receiver,
    required String groupID,
    required int duration,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    return await _v2timMessageManager.sendSoundMessage();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendTextAtMessage({
    required String text,
    required List<String> atUserList,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    return await _v2timMessageManager
        .sendTextAtMessage<V2TimValueCallback<V2TimMessage>, V2TimMessage>({
      "text": text,
      "atUserList": atUserList,
      "receiver": receiver,
      "groupID": groupID,
      "priority": priority,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo,
    });
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendLocationMessage({
    required String desc,
    required double longitude,
    required double latitude,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    return await _v2timMessageManager
        .sendLocationMessage<V2TimValueCallback<V2TimMessage>, V2TimMessage>({
      "desc": desc,
      "longitude": longitude,
      "latitude": latitude,
      "receiver": receiver,
      "groupID": groupID,
      "priority": priority,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo,
    });
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendFaceMessage({
    required int index,
    required String data,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    return await _v2timMessageManager
        .sendFaceMessage<V2TimValueCallback<V2TimMessage>, V2TimMessage>({
      "index": index,
      "data": data,
      "receiver": receiver,
      "groupID": groupID,
      "priority": priority,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo,
    });
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendMergerMessage(
      {required List<String> msgIDList,
      required String title,
      required List<String> abstractList,
      required String compatibleText,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      Map<String, dynamic>? offlinePushInfo,
      List<String>? webMessageInstanceList}) async {
    return await _v2timMessageManager
        .sendMergerMessage<V2TimValueCallback<V2TimMessage>, V2TimMessage>({
      "msgIDList": msgIDList,
      "title": title,
      "abstractList": abstractList,
      "compatibleText": compatibleText,
      "receiver": receiver,
      "groupID": groupID,
      "priority": priority,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo,
      "webMessageInstanceList": webMessageInstanceList
    });
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> getC2CHistoryMessageList({
    required String userID,
    required int count,
    String? lastMsgID,
  }) async {
    return await _v2timMessageManager.getC2CHistoryMessageList(
        {"userID": userID, "count": count, "lastMsgID": lastMsgID});
  }

  @override
  Future<V2TimCallback> setLocalCustomData({
    required String msgID,
    required String localCustomData,
  }) async {
    return await _v2timMessageManager.setLocalCustomData();
  }

  @override
  Future<V2TimCallback> setLocalCustomInt({
    required String msgID,
    required int localCustomInt,
  }) async {
    return await _v2timMessageManager.setLocalCustomInt();
  }

  @override
  Future<V2TimCallback> setCloudCustomData({
    required String data,
    required String msgID,
  }) async {
    return await _v2timMessageManager.setCloudCustomData();
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> getGroupHistoryMessageList({
    required String groupID,
    required int count,
    String? lastMsgID,
  }) async {
    return await _v2timMessageManager.getGroupHistoryMessageList({
      "groupID": groupID,
      "count": count,
      "lastMsgID": lastMsgID,
    });
  }

  @override
  Future<V2TimCallback> revokeMessage(
      {required String msgID, Object? webMessageInstatnce}) async {
    return await _v2timMessageManager.revokeMessage(
        {"msgID": msgID, "webMessageInstatnce": webMessageInstatnce});
  }

  @override
  Future<V2TimCallback> markC2CMessageAsRead({
    required String userID,
  }) async {
    return await _v2timMessageManager.markC2CMessageAsRead({
      "userID": userID,
    });
  }

  @override
  Future<LinkedHashMap<dynamic, dynamic>> getHistoryMessageListWithoutFormat({
    int getType = HistoryMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    String? lastMsgID,
    List<int>? messageSeqList,
    int? timeBegin,
    int? timePeriod,
  }) async {
    return await _v2timMessageManager.getHistoryMessageListWithoutFormat();
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> getHistoryMessageList({
    int getType = HistoryMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    List<int>? messageTypeList, // web暂不处理
    String? lastMsgID,
    List<int>? messageSeqList,
    int? timeBegin,
    int? timePeriod,
  }) async {
    return await _v2timMessageManager.getC2CHistoryMessageList({
      "getType": getType,
      "userID": userID,
      "groupID": groupID,
      "lastMsgSeq": lastMsgSeq,
      "count": count,
      "lastMsgID": lastMsgID,
      "messageSeqList": messageSeqList,
      "timeBegin": timeBegin,
      "timePeriod": timePeriod,
    });
  }

  @override
  Future<V2TimValueCallback<V2TimMessageListResult>> getHistoryMessageListV2({
    int getType = HistoryMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    List<int>? messageTypeList, // web暂不处理
    String? lastMsgID,
    List<int>? messageSeqList,
    int? timeBegin,
    int? timePeriod,
  }) async {
    return await _v2timMessageManager.getC2CHistoryMessageListV2({
      "getType": getType,
      "userID": userID,
      "groupID": groupID,
      "lastMsgSeq": lastMsgSeq,
      "count": count,
      "lastMsgID": lastMsgID,
      "messageSeqList": messageSeqList,
      "timeBegin": timeBegin,
      "timePeriod": timePeriod,
    });
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendForwardMessage(
      {required String msgID,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      Map<String, dynamic>? offlinePushInfo,
      String? webMessageInstance}) async {
    return await _v2timMessageManager.sendForwardMessage({
      "msgID": msgID,
      "receiver": receiver,
      "groupID": groupID,
      "priority": priority,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo,
      "webMessageInstance": webMessageInstance
    });
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> reSendMessage(
      {required String msgID,
      bool onlineUserOnly = false,
      Object? webMessageInstatnce}) async {
    return await _v2timMessageManager.reSendMessage({
      "msgID": msgID,
      "onlineUserOnly": onlineUserOnly,
      "webMessageInstatnce": webMessageInstatnce
    });
  }

  @override
  Future<V2TimCallback> setC2CReceiveMessageOpt({
    required List<String> userIDList,
    required int opt,
  }) async {
    return await _v2timMessageManager.setC2CReceiveMessageOpt(
        userIDList: userIDList, opt: opt);
  }

  @override
  Future<V2TimValueCallback<List<V2TimReceiveMessageOptInfo>>>
      getC2CReceiveMessageOpt({
    required List<String> userIDList,
  }) async {
    return await _v2timMessageManager.getC2CReceiveMessageOpt();
  }

  @override
  Future<V2TimCallback> setGroupReceiveMessageOpt({
    required String groupID,
    required int opt,
  }) async {
    return await _v2timMessageManager.setGroupReceiveMessageOpt({
      "groupID": groupID,
      "opt": opt,
    });
  }

  @override
  Future<V2TimCallback> markGroupMessageAsRead({
    required String groupID,
  }) async {
    return await _v2timMessageManager.markGroupMessageAsRead({
      "groupID": groupID,
    });
  }

  @override
  Future<V2TimValueCallback<Map<String, String>>> translateText({
    required List<String> texts,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    return _v2timMessageManager.translateText(
      texts: texts,
      targetLanguage: targetLanguage,
      sourceLanguage: sourceLanguage,
    );
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
  Future<V2TimCallback> deleteMessageFromLocalStorage({
    required String msgID,
  }) async {
    return await _v2timMessageManager.deleteMessageFromLocalStorage();
  }

  @override
  Future<V2TimCallback> deleteMessages(
      {required List<String> msgIDs,
      List<dynamic>? webMessageInstanceList}) async {
    return await _v2timMessageManager.deleteMessages(
        {"msgIDs": msgIDs, "webMessageInstanceList": webMessageInstanceList});
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> insertGroupMessageToLocalStorage({
    required String data,
    required String groupID,
    required String sender,
  }) async {
    return await _v2timMessageManager.insertGroupMessageToLocalStorage();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> insertC2CMessageToLocalStorage({
    required String data,
    required String userID,
    required String sender,
  }) async {
    return await _v2timMessageManager.insertC2CMessageToLocalStorage();
  }

  @override
  Future<V2TimCallback> clearC2CHistoryMessage({
    required String userID,
  }) async {
    return await _v2timMessageManager.clearC2CHistoryMessage();
  }

  @override
  Future<V2TimCallback> clearGroupHistoryMessage({
    required String groupID,
  }) async {
    return await _v2timMessageManager.clearGroupHistoryMessage();
  }

  @override
  Future<V2TimValueCallback<V2TimMessageSearchResult>> searchLocalMessages({
    required V2TimMessageSearchParam searchParam,
  }) async {
    return await _v2timMessageManager.searchLocalMessages(searchParam);
  }
  @override
  Future<V2TimValueCallback<V2TimMessageSearchResult>> searchCloudMessages({
    required V2TimMessageSearchParam searchParam,
  }) async {
    return await _v2timMessageManager.searchLocalMessages(searchParam);
  }
  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> findMessages({
    required List<String> messageIDList,
  }) async {
    return await _v2timMessageManager.findMessages(
        messageIDList: messageIDList);
  }

  @override
  Future<void> setGroupListener(
      {required V2TimGroupListener listener, String? listenerUuid}) async {
    listenerUuid = Utils.generateUniqueString();
    return _v2timManager.setGroupListener(listener, listenerUuid);
  }

  @override
  Future<void> addGroupListener({required V2TimGroupListener listener}) async {
    var listenerUuid = Utils.generateUniqueString();
    groupListenerList[listenerUuid] = listener;
    return _v2timManager.setGroupListener(listener, listenerUuid);
  }

  @override
  Future<String> addAdvancedMsgListener(
      {required V2TimAdvancedMsgListener listener}) async {
    var listenerUuid = Utils.generateUniqueString();
    advancedMsgListenerList[listenerUuid] = listener;
    _v2timMessageManager.addAdvancedMsgListener(listener, listenerUuid);
    return listenerUuid;
  }

  @override
  Future<void> removeAdvancedMsgListener({
    String? uuid,
    V2TimAdvancedMsgListener? listener,
  }) async {
    var listenerUuid = "";
    var hasListener = false;
    if (listener != null) {
      hasListener = true;
      listenerUuid = advancedMsgListenerList.keys.firstWhere(
        (k) => advancedMsgListenerList[k] == listener,
        orElse: () => "",
      );
      if (listenerUuid.isNotEmpty) {
        advancedMsgListenerList.remove(listenerUuid);
      }
    } else {
      advancedMsgListenerList.clear();
    }
    _v2timMessageManager.removeAdvancedMsgListener(uuid, hasListener);
  }

  @override
  Future<void> addFriendListener({
    required V2TimFriendshipListener listener,
  }) async {
    var listenerUuid = Utils.generateUniqueString();

    friendListenerList[listenerUuid] = listener;

    _v2timFriendshipManager.setFriendListener(listener, listenerUuid);
  }

  @override
  Future<V2TimValueCallback<List<V2TimUserStatus>>> getUserStatus({
    required List<String> userIDList,
  }) async {
    return _v2timManager.getUserStatus(userIDList: userIDList);
  }

  @override
  Future<void> removeConversationListener({
    V2TimConversationListener? listener,
  }) {
    var listenerUuid = "";
    var hasListener = false;
    if (listener != null) {
      hasListener = true;
      listenerUuid = conversationListenerList.keys.firstWhere(
        (k) => conversationListenerList[k] == listener,
        orElse: () => "",
      );
      if (listenerUuid.isNotEmpty) {
        conversationListenerList.remove(listenerUuid);
      }
    } else {
      conversationListenerList.clear();
    }
    return _v2TIMConversationManager.removeConversationListener(
        listenerUuid: listenerUuid, hasListener: hasListener);
  }

  @override
  Future<void> removeGroupListener({
    V2TimGroupListener? listener,
  }) async {
    var listenerUuid = "";
    var hasListener = false;
    if (listener != null) {
      hasListener = true;
      listenerUuid = groupListenerList.keys.firstWhere(
        (k) => groupListenerList[k] == listener,
        orElse: () => "",
      );
      if (listenerUuid.isNotEmpty) {
        groupListenerList.remove(listenerUuid);
      }
    } else {
      groupListenerList.clear();
    }
    return _v2timManager.removeGroupListener(listenerUuid, hasListener);
  }

  @override
  Future<void> removeFriendListener({
    V2TimFriendshipListener? listener,
  }) async {
    var listenerUuid = "";
    var hasListener = false;
    if (listener != null) {
      hasListener = true;
      listenerUuid = friendListenerList.keys.firstWhere(
        (k) => friendListenerList[k] == listener,
        orElse: () => "",
      );
      if (listenerUuid.isNotEmpty) {
        friendListenerList.remove(listenerUuid);
      }
    } else {
      friendListenerList.clear();
    }
    return _v2timFriendshipManager.removeFriendListener(
        listenerUuid, hasListener);
  }

  // 信令模块
  @override
  Future<void> addSignalingListener({
    required V2TimSignalingListener listener,
  }) async {
    final String listenerUuid = Utils.generateUniqueString();
    signalingListenerList[listenerUuid] = listener;
    return _v2timSignalingManager.addSignalingListenerForWeb(
      listener: listener,
      listenerUuid: listenerUuid,
    );
  }

  @override
  Future<void> removeSignalingListener({
    V2TimSignalingListener? listener,
  }) async {
    var listenerUuid = "";
    if (listener != null) {
      listenerUuid = signalingListenerList.keys.firstWhere(
          (k) => signalingListenerList[k] == listener,
          orElse: () => "");
      signalingListenerList.remove(listenerUuid);
    } else {
      signalingListenerList.clear();
    }
    return _v2timSignalingManager.removeSignalingListener(
        listener: listener, listenerUuid: listenerUuid);
  }

  @override
  Future<V2TimValueCallback<String>> invite({
    required String invitee,
    required String data,
    int timeout = 30,
    bool onlineUserOnly = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return _v2timSignalingManager.invite(
      invitee: invitee,
      data: data,
      timeout: timeout,
      onlineUserOnly: onlineUserOnly,
      offlinePushInfo: offlinePushInfo,
    );
  }

  @override
  Future<V2TimValueCallback<String>> inviteInGroup({
    required String groupID,
    required List<String> inviteeList,
    required String data,
    int timeout = 30,
    bool onlineUserOnly = false,
  }) async {
    return _v2timSignalingManager.inviteInGroup(
        groupID: groupID,
        inviteeList: inviteeList,
        data: data,
        timeout: timeout,
        onlineUserOnly: onlineUserOnly);
  }

  @override
  Future<V2TimCallback> cancel({
    required String inviteID,
    String? data,
  }) async {
    return _v2timSignalingManager.cancel(inviteID: inviteID, data: data);
  }

  @override
  Future<V2TimCallback> accept({
    required String inviteID,
    String? data,
  }) async {
    return _v2timSignalingManager.accept(inviteID: inviteID, data: data);
  }

  @override
  Future<V2TimCallback> reject({
    required String inviteID,
    String? data,
  }) async {
    return _v2timSignalingManager.reject(inviteID: inviteID, data: data);
  }

  @override
  Future<V2TimValueCallback<V2TimSignalingInfo>> getSignalingInfo({
    required String msgID,
  }) async {
    return _v2timSignalingManager.getSignalingInfo(msgID: msgID);
  }

  @override
  Future<V2TimCallback> addInvitedSignaling({
    required V2TimSignalingInfo info,
  }) async {
    return _v2timSignalingManager.addInvitedSignaling(info: info);
  }

  @override
  Future<V2TimValueCallback<V2TimMessageChangeInfo>> modifyMessage({
    required V2TimMessage message,
  }) async {
    return await _v2timMessageManager.modifyMessage(message: message);
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> downloadMergerMessage({
    required String msgID,
  }) async {
    return await _v2timMessageManager.downloadMergerMessage(msgID: msgID);
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessageReceipt>>> getMessageReadReceipts({
    required List<String> messageIDList,
  }) async {
    return await _v2timMessageManager.getMessageReadReceipts(
        messageIDList: messageIDList);
  }

  @override
  Future<V2TimCallback> sendMessageReadReceipts({
    required List<String> messageIDList,
  }) async {
    return await _v2timMessageManager.sendMessageReadReceipts(
        messageIDList: messageIDList);
  }

  @override
  Future<V2TimValueCallback<V2TimGroupMessageReadMemberList>>
      getGroupMessageReadMemberList({
    required String messageID,
    required GetGroupMessageReadMemberListFilter filter,
    int nextSeq = 0,
    int count = 100,
  }) {
    return _v2timMessageManager.getGroupMessageReadMemberList(
        filter: filter, messageID: messageID, nextSeq: nextSeq, count: count);
  }

  @override
  Future<V2TimValueCallback<V2TimMessageOnlineUrl>> getMessageOnlineUrl({
    required String msgID,
  }) async {
    return V2TimValueCallback<V2TimMessageOnlineUrl>.fromJson({});
  }

  @override
  Future<V2TimCallback> downloadMessage({
    required String msgID,
    required int messageType,
    required int imageType, // 图片类型，仅messageType为图片消息是有效
    required bool isSnapshot, // 是否是视频封面，仅messageType为视频消息是有效
  }) async {
    return V2TimCallback.fromJson({});
  }

  @override
  Future<V2TimCallback> addMessageReaction({
    required String msgID,
    required String reactionID,
  }) async {
    return _v2timMessageManager.addMessageReaction(
        msgID: msgID, reactionID: reactionID);
  }

  @override
  Future<V2TimCallback> removeMessageReaction({
    required String msgID,
    required String reactionID,
  }) async {
    return _v2timMessageManager.removeMessageReaction(
        msgID: msgID, reactionID: reactionID);
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessageReactionResult>>>
      getMessageReactions({
    required List<String> msgIDList,
    required int maxUserCountPerReaction,
    List<String>? webMessageInstanceList,
  }) async {
    return _v2timMessageManager.getMessageReactions(
      msgIDList: msgIDList,
      maxUserCountPerReaction: maxUserCountPerReaction,
      webMessageInstanceList: webMessageInstanceList,
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMessageReactionUserResult>>
      getAllUserListOfMessageReaction({
    required String msgID,
    required String reactionID,
    required int nextSeq,
    required int count,
    String? webMessageInstance,
  }) async {
    return _v2timMessageManager.getAllUserListOfMessageReaction(
      msgID: msgID,
      reactionID: reactionID,
      nextSeq: nextSeq,
      count: count,
      webMessageInstance: webMessageInstance,
    );
  }

  @override
  Future<V2TimValueCallback<String>> convertVoiceToText({
    required String msgID,
    required String
        language, // "zh (cmn-Hans-CN)" "yue-Hant-HK" "en-US" "ja-JP",
    String? webMessageInstance,
  }) async {
    return _v2timMessageManager.convertVoiceToText(
      msgID: msgID,
      language: language,
      webMessageInstance: webMessageInstance,
    );
  }
}
