// ignore_for_file: avoid_print, no_leading_underscores_for_local_identifiers

import 'dart:js_util';

import 'package:tencent_cloud_chat_sdk/enum/V2TimFriendshipListener.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_friend_application.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_friend_application_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_friend_check_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_friend_group.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_friend_info_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_friend_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/web/enum/event_enum.dart';
import 'package:tencent_cloud_chat_sdk/web/enum/friend_type.dart';
import 'package:tencent_cloud_chat_sdk/web/manager/im_sdk_plugin_js.dart';
import 'package:tencent_cloud_chat_sdk/web/manager/v2_tim_manager.dart';
import 'package:tencent_cloud_chat_sdk/web/models/v2_tim_add_friend.dart';
import 'package:tencent_cloud_chat_sdk/web/models/v2_tim_check_friend.dart';
import 'package:tencent_cloud_chat_sdk/web/models/v2_tim_friend_black_list.dart';
import 'package:tencent_cloud_chat_sdk/web/models/v2_tim_friend_group.dart';
import 'package:tencent_cloud_chat_sdk/web/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/web/models/v2_tim_friend_list.dart';
import 'package:tencent_cloud_chat_sdk/web/utils/utils.dart';

class V2TIMFriendshipManager {
  static late TencentCloudChat? timeWeb;
  late List<dynamic> friendList;
  static final Map<String, V2TimFriendshipListener> _friendshipListenerList =
      {};

  V2TIMFriendshipManager() {
    timeWeb = V2TIMManagerWeb.timWeb;
  }

  static getUserIDlist(List<dynamic> list) =>
      list.map((e) => e["userID"]).toList();

  static getUserIDlistFromJS(List<dynamic> list) =>
      list.map((e) => e.userID).toList();

// 求差集
  static getDiffsFromTwoArr(List<dynamic> listA, List<dynamic> listB) {
    var tempArr = [];
    tempArr.addAll(listA);
    tempArr.addAll(listB);
    List<dynamic> difference = tempArr
        .where(
            (element) => !listA.contains(element) || !listB.contains(element))
        .toList();

    return difference;
  }

  static final _friendListUpdatedHandler = allowInterop((res) {
    print("好友列表更新回调执行");
    final formateList = FriendList.formatedFriendListRes(jsToMap(res)['data']);
    final oldFriendList = V2TIMManager.getFriendList();
    if (oldFriendList.length == 1 && oldFriendList[0] == "init") {
      return;
    }

    int formateListCount = formateList.length;
    int oldFriendListCount = oldFriendList.length;
    List<dynamic> formateUserIDList = getUserIDlist(formateList);
    List<dynamic> oldFriendUserIDList = getUserIDlist(oldFriendList);

    print("formateListCount:$formateListCount");
    print("oldFriendListCount:$oldFriendListCount");
    if (formateListCount > oldFriendListCount) {
      print("好友列表ADD回调执行");
      final addedList =
          formateList.map((e) => V2TimFriendInfo.fromJson(e)).toList();
      for (var _friendshipListener in _friendshipListenerList.values) {
        _friendshipListener.onFriendListAdded(addedList);
      }
    } else if (formateListCount < oldFriendListCount) {
      print("好友列表Delete回调执行");
      List<dynamic> difference =
          getDiffsFromTwoArr(formateUserIDList, oldFriendUserIDList);
      List<String> userList = List.from(difference);

      for (var _friendshipListener in _friendshipListenerList.values) {
        _friendshipListener.onFriendListDeleted(userList);
      }
    } else {
      List<dynamic> difference = getDiffsFromTwoArr(formateList, oldFriendList);
      log(difference);
      // final differences = formateUserIDList
    }
    V2TIMManager.updtateFriendList(formateList);
  });

  static final _blackListUpdatedHandler = allowInterop((res) {
    print("黑名单更新回调执行");
    final formateList = FriendBlackList.formateBlackList(jsToMap(res)['data']);
    final oldBlackList = V2TIMManager.getBlackList();
    if (oldBlackList.length == 1 && oldBlackList[0] == "init") {
      return;
    }

    int formateListCount = formateList.length;
    int oldBlackListCount = oldBlackList.length;
    List<dynamic> formateUserIDList = getUserIDlist(formateList);
    List<dynamic> oldBlackUserIDList = getUserIDlist(oldBlackList);

    print("formateListCount:$formateListCount");
    print("oldFriendListCount:$oldBlackListCount");
    if (formateListCount >= oldBlackListCount) {
      print("好友BlackList Add回调执行");
      final infoListMap =
          formateList.map((e) => V2TimFriendInfo.fromJson(e)).toList();
      for (var _friendshipListener in _friendshipListenerList.values) {
        _friendshipListener.onBlackListAdd(infoListMap);
      }
    } else {
      print("好友BlackList Delete回调执行");
      List<dynamic> difference =
          getDiffsFromTwoArr(formateUserIDList, oldBlackUserIDList);
      List<String> userList = List.from(difference);
      for (var _friendshipListener in _friendshipListenerList.values) {
        _friendshipListener.onBlackListDeleted(userList);
      }
    }
    V2TIMManager.updateBlackList(formateList);
  });

  static final _friendApplicationListUpdatedHandler = allowInterop((res) {
    final resData = jsToMap(res)['data'];
    final List formateList = FriendApplication.formateResult(
        jsToMap(resData))["friendApplicationList"];
    final oldApplicationList = V2TIMManager.getFriendApplicationList();
    if (oldApplicationList.length == 1 && oldApplicationList[0] == "init") {
      return;
    }

    int formateListCount = formateList.length;
    int oldApplicationListCount = oldApplicationList.length;
    List<dynamic> formateUserIDList = getUserIDlist(formateList);
    List<dynamic> oldApplicationIDList = getUserIDlist(oldApplicationList);

    print("formateListCount:$formateListCount");
    print("oldFriendListCount:$oldApplicationListCount");
    if (formateListCount >= oldApplicationListCount) {
      print("好友Application ADD回调执行");
      final addedList =
          formateList.map((e) => V2TimFriendApplication.fromJson(e)).toList();
      for (var _friendshipListener in _friendshipListenerList.values) {
        _friendshipListener.onFriendApplicationListAdded(addedList);
      }
    } else {
      print("好友Application Delete回调执行");
      List<dynamic> difference =
          getDiffsFromTwoArr(formateUserIDList, oldApplicationIDList);
      List<String> userIDList = List.from(difference);
      for (var _friendshipListener in _friendshipListenerList.values) {
        _friendshipListener.onFriendApplicationListDeleted(userIDList);
      }
    }
    V2TIMManager.updateFriendApplicationList(formateList);
  });

  static final _profileUpdatedHanlder = allowInterop((res) async {
    List<dynamic> userIDList = getUserIDlistFromJS(jsToMap(res)['data']);
    print("好友资料更新回调执行");
    // 判断是不是修改自己的信息
    if (userIDList.length == 1 && userIDList[0] == V2TIMManager.getUserID()) {
      return null;
    }

    final result = await wrappedPromiseToFuture(timeWeb!.getFriendProfile(
        FriendInfo.formateGetInfoParams({"userIDList": userIDList})));

    List<dynamic> formateList =
        FriendInfo.formateFriendInfoToList(jsToMap(result.data)['friendList']);
    final infoList =
        formateList.map((e) => V2TimFriendInfo.fromJson(e)).toList();

    for (var listener in _friendshipListenerList.values) {
      listener.onFriendInfoChanged(infoList);
    }
  });

/*
  这里因为web add Friend 只有一个update
*/
  void setFriendListener(
      V2TimFriendshipListener listener, String? listenerUuid) {
    if (_friendshipListenerList.isNotEmpty) {
      _friendshipListenerList[listenerUuid!] = (listener);
      return;
    }
    _friendshipListenerList[listenerUuid!] = (listener);
    // FriendList update linstener
    timeWeb!.on(EventType.FRIEND_LIST_UPDATED, _friendListUpdatedHandler);

    // BlackList update Listenet
    timeWeb!.on(EventType.BLACKLIST_UPDATED, _blackListUpdatedHandler);

    // ApplicationList update Listenet
    timeWeb!.on(EventType.FRIEND_APPLICATION_LIST_UPDATED,
        _friendApplicationListUpdatedHandler);

    // FriendIinfo update Listenet, res 只会返回
    timeWeb!.on(EventType.PROFILE_UPDATED, _profileUpdatedHanlder);
  }

  void removeFriendListener(String? listenerUuid, bool hasListener) {
    if (listenerUuid != null && listenerUuid.isNotEmpty) {
      _friendshipListenerList.remove(listenerUuid);
      if (_friendshipListenerList.isNotEmpty) {
        return;
      }
    }
    if (!hasListener) {
      _friendshipListenerList.clear();
    }
    if (_friendshipListenerList.isEmpty) {
      timeWeb!.off(EventType.FRIEND_LIST_UPDATED, _friendListUpdatedHandler);

      // BlackList update Listenet
      timeWeb!.off(EventType.BLACKLIST_UPDATED, _blackListUpdatedHandler);

      // ApplicationList update Listenet
      timeWeb!.off(
          EventType.FRIEND_APPLICATION_LIST_UPDATED, _blackListUpdatedHandler);

      // FriendIinfo update Listenet, res 只会返回
      timeWeb!.off(EventType.PROFILE_UPDATED, _profileUpdatedHanlder);
    }
  }

  void makeConversationListenerEventData(_channel, String type, data) {
    CommonUtils.emitEvent(_channel, "friendListener", type, data);
  }

  Future<V2TimValueCallback<List<V2TimFriendInfo>>> getFriendList() async {
    try {
      final res = await wrappedPromiseToFuture(timeWeb!.getFriendList());

      final code = res.code;
      final friendList = res.data as List;
      if (code == 0) {
        final formateList = FriendList.formatedFriendListRes(friendList);
        return CommonUtils.returnSuccess<List<V2TimFriendInfo>>(formateList);
      } else {
        return CommonUtils.returnErrorForValueCb('get friend list failed');
      }
    } catch (error) {
      return CommonUtils.returnErrorForValueCb(error);
    }
  }

  Future<V2TimValueCallback<List<V2TimFriendInfoResult>>> getFriendsInfo(
      Map<String, dynamic> params) async {
    try {
      final res = await wrappedPromiseToFuture(
          timeWeb!.getFriendProfile(FriendInfo.formateGetInfoParams(params)));
      final resultData = jsToMap(res.data);
      final successFriendList = resultData['friendList'] as List;
      final failureFriendList = resultData['failureUserIDList'] as List;
      var formatedFailureFriendList = [];
      if (failureFriendList.isNotEmpty) {
        final failedUserIDList =
            failureFriendList.map((e) => jsToMap(e)["userID"]).toList();
        final userProfileListResult = await wrappedPromiseToFuture(timeWeb!
            .getUserProfile(mapToJSObj({"userIDList": failedUserIDList})));
        formatedFailureFriendList = failureFriendList.map((e) {
          final item = jsToMap(e);
          final userID = item["userID"];
          final userProfileList = userProfileListResult.data as List;
          final result = userProfileList
              .firstWhere((element) => jsToMap(element)["userID"] == userID);
          item['profile'] = result;
          return mapToJSObj(item);
        }).toList();
      }
      final result = await FriendInfo.formateFriendInfoResult(
          successFriendList, formatedFailureFriendList);

      return CommonUtils.returnSuccess<List<V2TimFriendInfoResult>>(result);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<List<V2TimFriendInfoResult>>(
          error);
    }
  }

  Future<dynamic> addFriend(Map<String, dynamic> params) async {
    try {
      final res = await wrappedPromiseToFuture(
          timeWeb!.addFriend(AddFriend.formateParams(params)));
      final result = AddFriend.formateResult(jsToMap(res.data));

      return CommonUtils.returnSuccess<V2TimFriendOperationResult>(result);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<V2TimFriendOperationResult>(
          error);
    }
  }

  /*
    web中只有remark和自定义字短可以更新
    /必须以 Tag_SNS_Custom为开头，且此自定义字段需要先到控制台定义
  */
  Future<dynamic> setFriendInfo(Map<String, dynamic> params) async {
    try {
      final formateParams = mapToJSObj({
        "userID": params["userID"],
        "remark": params["friendRemark"],
        "friendCustomField":
            FriendInfo.formateFriendCustomInfo(params["friendCustomInfo"])
      });
      final res =
          await wrappedPromiseToFuture(timeWeb!.updateFriend(formateParams));
      if (res.code == 0) {
        return CommonUtils.returnSuccessForCb(null);
      } else {
        return CommonUtils.returnError(
            "getFriendsInfo faile code:${res.code}, data:${res.data}");
      }
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  Future<dynamic> deleteFromFriendList(Map<String, dynamic> params) async {
    try {
      final formateParams = mapToJSObj({
        "userIDList": params["userIDList"],
        "type": FriendTypeWeb.convertWebFriendType(params["deleteType"]),
      });

      final res =
          await wrappedPromiseToFuture(timeWeb!.deleteFriend(formateParams));

      final successUserIDList = jsToMap(res.data)['successUserIDList'];
      final formateArr = [];
      successUserIDList.forEach((element) =>
          formateArr.add(AddFriend.formateResult(jsToMap(element))));

      return CommonUtils.returnSuccess<List<V2TimFriendOperationResult>>(
          formateArr);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<
          List<V2TimFriendOperationResult>>(error);
    }
  }

  Future<dynamic> checkFriend(Map<String, dynamic> params) async {
    try {
      final formateParams = CheckFriend.formateParams(params);
      final res =
          await wrappedPromiseToFuture(timeWeb!.checkFriend(formateParams));
      final formateResult = CheckFriend.formateResult(jsToMap(res.data));
      return CommonUtils.returnSuccess<List<V2TimFriendCheckResult>>(
          formateResult);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<List<V2TimFriendCheckResult>>(
          error);
    }
  }

  Future<dynamic> getFriendApplicationList() async {
    try {
      final res =
          await wrappedPromiseToFuture(timeWeb!.getFriendApplicationList());
      final formateResult = FriendApplication.formateResult(jsToMap(res.data));
      return CommonUtils.returnSuccess<V2TimFriendApplicationResult>(
          formateResult);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<V2TimFriendApplicationResult>(
          error);
    }
  }

  // 注意：同意好友申请成功无返回值
  Future<dynamic> acceptFriendApplication(Map<String, dynamic> params) async {
    try {
      final formateParams = AcceptFriendApplication.formateParams(params);
      final res = await promiseToFuture(
          timeWeb!.acceptFriendApplication(formateParams));
      if (res != null) {
        log(res);
      }

      return CommonUtils.returnSuccess<V2TimFriendOperationResult>(null);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<V2TimFriendOperationResult>(
          error);
    }
  }

  // 注意：拒绝好友申请成功无返回值
  Future<dynamic> refuseFriendApplication(Map<String, dynamic> params) async {
    try {
      final formateParams = mapToJSObj({"userID": params["userID"]});
      final result = await promiseToFuture(
          timeWeb!.refuseFriendApplication(formateParams));
      if (result != null) {
        log(result);
      }
      return CommonUtils.returnSuccess<V2TimFriendOperationResult>(null);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<V2TimFriendOperationResult>(
          error);
    }
  }

  Future<dynamic> deleteFriendApplication(Map<String, dynamic> params) async {
    try {
      final formateParams = mapToJSObj({
        "userID": params["userID"],
        "type": FriendTypeWeb.convertToApplicationFriendType(params["type"])
      });
      final res = await wrappedPromiseToFuture(
          timeWeb!.deleteFriendApplication(formateParams));
      return CommonUtils.returnSuccessForCb(jsToMap(res.data));
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  // 注意：好友申请已读不会返回任何参数
  Future<dynamic> setFriendApplicationRead() async {
    try {
      await promiseToFuture(timeWeb!.setFriendApplicationRead());

      return CommonUtils.returnSuccess(null);
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>> addToBlackList(
      params) async {
    try {
      final formateParams = mapToJSObj({
        "userIDList": params["userIDList"],
      });
      final res =
          await wrappedPromiseToFuture(timeWeb!.addToBlacklist(formateParams));
      List<dynamic> resultArr = [];
      res.data.forEach((userID) =>
          resultArr.add({"userID": userID, "resultCode": res.code}));

      return CommonUtils.returnSuccess<List<V2TimFriendOperationResult>>(
          resultArr);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<
          List<V2TimFriendOperationResult>>(error);
    }
  }

  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFromBlackList(params) async {
    try {
      final formateParams = mapToJSObj({
        "userIDList": params["userIDList"],
      });
      await wrappedPromiseToFuture(timeWeb!.removeFromBlacklist(formateParams));
      final formateResult =
          FriendBlackList.formateDeleteBlackListRes(params["userIDList"]);
      return CommonUtils.returnSuccess<List<V2TimFriendOperationResult>>(
          formateResult);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<
          List<V2TimFriendOperationResult>>(error);
    }
  }

  // 黑名单这里只会返回userID，无法拿到详细信息
  Future<dynamic> getBlackList() async {
    try {
      final res = await wrappedPromiseToFuture(timeWeb!.getBlacklist());
      final formateResult = FriendBlackList.formateBlackList(res.data);
      log(res);
      return CommonUtils.returnSuccess<List<V2TimFriendInfo>>(formateResult);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<List<V2TimFriendInfo>>(error);
    }
  }

  Future<dynamic> createFriendGroup(Map<String, dynamic> params) async {
    try {
      var formateParams = FriendGroup.formateParams(params);
      final res = await wrappedPromiseToFuture(
          timeWeb!.createFriendGroup(formateParams));
      log(res);
      final formateResult = FriendGroup.formateResult(jsToMap(res.data));
      return CommonUtils.returnSuccess<List<V2TimFriendOperationResult>>(
          formateResult);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<
          List<V2TimFriendOperationResult>>(error);
    }
  }

  Future<dynamic> getFriendGroups(Map<String, dynamic> params) async {
    try {
      if (params["groupNameList"] != null) {
        print(" web getFriendGroupList 不支特定分组传入");
      }
      final res = await wrappedPromiseToFuture(timeWeb!.getFriendGroupList());
      final formateResult = FriendGroup.formateGroupResult(res.data);
      return CommonUtils.returnSuccess<List<V2TimFriendGroup>>(formateResult);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<List<V2TimFriendGroup>>(error);
    }
  }

  // 只支持单项好友分组删除
  Future<dynamic> deleteFriendGroup(Map<String, dynamic> params) async {
    try {
      print(" web deleteFriendGroup 只支持单项好友分组删除");
      final formateParams = mapToJSObj({"name": params["groupNameList"][0]});
      final res =
          await promiseToFuture(timeWeb!.deleteFriendGroup(formateParams));
      log(res);
      return CommonUtils.returnSuccessForCb(null);
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  Future<dynamic> renameFriendGroup(Map<String, dynamic> params) async {
    try {
      final formateParams = mapToJSObj(
          {"oldName": params["oldName"], "newName": params["newName"]});
      final res =
          await promiseToFuture(timeWeb!.renameFriendGroup(formateParams));
      log(res);
      return CommonUtils.returnSuccessForCb(null);
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  Future<dynamic> addFriendsToFriendGroup(Map<String, dynamic> params) async {
    try {
      final formateParams = mapToJSObj(
          {"name": params["groupName"], "userIDList": params["userIDList"]});
      final res = await wrappedPromiseToFuture(
          timeWeb!.addToFriendGroup(formateParams));
      log(res);
      final formateResult = FriendBlackList.formateDeleteBlackListRes(
          jsToMap(jsToMap(res.data)['friendGroup'])['userIDList']);
      return CommonUtils.returnSuccess<List<V2TimFriendOperationResult>>(
          formateResult);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<
          List<V2TimFriendOperationResult>>(error);
    }
  }

  //分组返回逻辑奇怪 他返回的是现存在分组里的内容，但是natvie中却是删除的
  Future<dynamic> deleteFriendsFromFriendGroup(
      Map<String, dynamic> params) async {
    try {
      final formateParams = mapToJSObj(
          {"name": params["groupName"], "userIDList": params["userIDList"]});
      final res = await wrappedPromiseToFuture(
          timeWeb!.removeFromFriendGroup(formateParams));
      log(res);
      final formateResult = FriendBlackList.formateDeleteBlackListRes(
          jsToMap(jsToMap(res.data)['friendGroup'])['userIDList']);
      return CommonUtils.returnSuccess<List<V2TimFriendOperationResult>>(
          formateResult);
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<
          List<V2TimFriendOperationResult>>(error);
    }
  }

  Future<dynamic> searchFriends() async {
    return CommonUtils.returnErrorForValueCb<List<V2TimFriendInfoResult>>(
        'searchFriends Not support for web');
  }
}
