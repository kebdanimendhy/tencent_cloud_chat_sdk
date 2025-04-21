import 'dart:convert';

import 'package:tencent_cloud_chat_sdk/utils/utils.dart';

/// V2TimGroupSearchParam
///
/// {@category Models}
///
class V2TimGroupSearchParam {
  late List<String> keywordList;
  bool isSearchGroupID = true;
  bool isSearchGroupName = true;

  // 群搜索的枚举
  // 搜索群 ID
  static const int _kTIMGroupSearchFieldKey_GroupId = 0x01;
  // 搜索群名称
  static const int _kTIMGroupSearchFieldKey_GroupName = 0x01 << 1;

  V2TimGroupSearchParam({
    required this.keywordList,
    this.isSearchGroupID = true,
    this.isSearchGroupName = true,
  });

  V2TimGroupSearchParam.fromJson(Map json) {
    json = Utils.formatJson(json);
    keywordList = json['group_search_params_keyword_list']?.cast<String>() ?? [];
    List<int> searchFieldList = json['group_search_params_field_list']?.cast<int>() ?? [];
    for (int searchField in searchFieldList) {
      if (searchField == _kTIMGroupSearchFieldKey_GroupId) {
        isSearchGroupID = true;
      } else if (searchField == _kTIMGroupSearchFieldKey_GroupName) {
        isSearchGroupName = true;
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['group_search_params_keyword_list'] = keywordList;
    List<int> searchFieldList = [];
    if (isSearchGroupID) {
      searchFieldList.add(_kTIMGroupSearchFieldKey_GroupId);
    }
    if (isSearchGroupName) {
      searchFieldList.add(_kTIMGroupSearchFieldKey_GroupName);
    }
    data['group_search_params_field_list'] = searchFieldList;
    return data;
  }

  String toLogString() {
    String res = "${json.encode(keywordList)}|isSearchGroupID:$isSearchGroupID|isSearchGroupName:$isSearchGroupName";
    return res;
  }
}
