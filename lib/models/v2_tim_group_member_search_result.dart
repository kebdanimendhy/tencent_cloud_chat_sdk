import 'dart:convert';

import 'package:tencent_cloud_chat_sdk/utils/utils.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_full_info.dart';

/// V2TimMessageSearchResult
///
/// {@category Models}
///
class V2GroupMemberInfoSearchResult {
  Map<String, dynamic>? groupMemberSearchResultItems;

  V2GroupMemberInfoSearchResult({
    this.groupMemberSearchResultItems,
  });

  V2GroupMemberInfoSearchResult.fromJson(Map json) {
    json = Utils.formatJson(json);
    Map<String, dynamic> resultMap = {};
    json.forEach((key, value) {
      var tempArr = [];
      if (value is List) {
        for (var element in value) {
          tempArr.add(V2TimGroupMemberFullInfo.fromJson(element));
        }
        resultMap[key] = tempArr;
      }
    });
    groupMemberSearchResultItems = resultMap;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (groupMemberSearchResultItems != null) {
      var map = groupMemberSearchResultItems;
      map?.forEach((key, value) {
        data[key] = value.map((v) => v.toJson()).toList();
      });
    }
    return data;
  }

  String toLogString() {
    String res = json.encode(groupMemberSearchResultItems);
    return res;
  }
}
