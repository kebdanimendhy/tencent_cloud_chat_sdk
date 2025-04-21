import 'package:tencent_cloud_chat_sdk/utils/utils.dart';

class V2TimPermissionGroupInfo {
  String groupID;
  String? permissionGroupID;
  String permissionGroupName;
  String? customData;
  int? groupPermission;
  int? memberCount;

  V2TimPermissionGroupInfo({
    this.customData,
    required this.groupID,
    this.groupPermission,
    this.memberCount,
    this.permissionGroupID,
    required this.permissionGroupName,
  });

  Map<String, dynamic> toJson() {
    return Map<String, dynamic>.from({
      'community_group_id': groupID,
      'permission_group_id': permissionGroupID,
      'permission_group_name': permissionGroupName,
      'permission_custom_data': customData,
      'group_permission': groupPermission,
      'permission_group_member_count': memberCount,
    });
  }

  static V2TimPermissionGroupInfo fromJson(Map json) {
    json = Utils.formatJson(json);
    return V2TimPermissionGroupInfo(
      groupID: json['community_group_id'] ?? "",
      permissionGroupID: json['permission_group_id'] ?? "",
      permissionGroupName: json['permission_group_name'] ?? "",
      customData: json['permission_custom_data'] ?? "",
      groupPermission: json['group_permission'] ?? 0,
      memberCount: json['permission_group_member_count'] ?? 0,
    );
  }

  String toLogString() {
    String res = "groupID:$groupID|permissionGroupID:$permissionGroupID|groupPermission:$groupPermission|memberCount:$memberCount|permissionGroupName:$permissionGroupName";
    return res;
  }
}
