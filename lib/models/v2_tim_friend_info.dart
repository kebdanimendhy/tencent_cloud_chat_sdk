import 'v2_tim_user_full_info.dart';
import 'package:tencent_cloud_chat_sdk/utils/utils.dart';
import 'package:tencent_cloud_chat_sdk/native_im/tools.dart';

/// V2TimFriendInfo
///
/// {@category Models}
///
class V2TimFriendInfo {
  late String userID;
  late String? friendRemark;
  List<String>? friendGroups = List.empty(growable: true);
  Map<String, String>? friendCustomInfo;
  V2TimUserFullInfo? userProfile;

  V2TimFriendInfo({
    required this.userID,
    this.friendRemark,
    this.friendGroups,
    this.friendCustomInfo,
    this.userProfile,
  });

  V2TimFriendInfo.fromJson(Map json) {
    json = Utils.formatJson(json);
    userID = json['friend_profile_identifier'] ?? "";
    friendRemark = json['friend_profile_remark'];
    friendGroups = json['friend_profile_group_name_array']?.cast<String>();

    List<dynamic>? jsonList = json['friend_profile_custom_string_array'];
    if (jsonList != null && jsonList.isNotEmpty) {
      friendCustomInfo = Tools.jsonList2Map<String>(jsonList.whereType<Map<String, dynamic>>().toList(), 'friend_profile_custom_string_info_key', 'friend_profile_custom_string_info_value');
    }

    userProfile = json['friend_profile_user_profile'] != null
        ? V2TimUserFullInfo.fromJson(json['friend_profile_user_profile'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['friend_profile_identifier'] = userID;
    data['friend_profile_remark'] = friendRemark;
    data['friend_profile_group_name_array'] = friendGroups;

    if (friendCustomInfo != null && friendCustomInfo!.isNotEmpty) {
      List<Map<String, dynamic>> customInfoList = Tools.map2JsonList(friendCustomInfo!, 'friend_profile_custom_string_info_key', 'friend_profile_custom_string_info_value');
      data['friend_profile_custom_string_array'] = customInfoList;
    }

    if (userProfile != null) {
      data['friend_profile_user_profile'] = userProfile!.toJson();
    }
    return data;
  }

  Map<String, dynamic> toModifyJsonParam() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['friendship_modify_friend_profile_param_identifier'] = userID;

    final Map<String, dynamic> modifyItem = <String, dynamic>{};
    if (friendRemark != null) {
      modifyItem['friend_profile_item_remark'] = friendRemark;
    }
    if (friendGroups != null) {
      modifyItem['friend_profile_item_group_name_array'] = friendGroups;
    }
    if (friendCustomInfo != null) {
      List<Map<String, dynamic>> customInfoList = Tools.map2JsonList(friendCustomInfo!, 'friend_profile_custom_string_info_key', 'friend_profile_custom_string_info_value');
      data['friend_profile_item_custom_string_array'] = customInfoList;
    }
    data['friendship_modify_friend_profile_param_item'] = modifyItem;

    return data;
  }

  String toLogString() {
    String res = "userID:$userID|friendRemark:$friendRemark|friendGroups:$friendGroups|friendCustomInfo:$friendCustomInfo";
    return res;
  }
}
// {
//   "userID":"",
//   "friendRemark":"",
//   "friendGroups":[""],
//   "friendCustomInfo":{},
//   "userProfile":{}
// }
