import 'dart:convert';

import 'package:tencent_cloud_chat_sdk/utils/utils.dart';

/// V2TimGroupMemberSearchParam
///
/// {@category Models}
///
class V2TimGroupMemberSearchParam {
  late List<String> keywordList;
  List<String>? groupIDList;
  bool isSearchMemberUserID = true;
  bool isSearchMemberNickName = true;
  bool isSearchMemberRemark = true;
  bool isSearchMemberNameCard = true;

  // 1.9 群成员搜索 Field 的枚举
  // 用户 ID
  static const int _kTIMGroupMemberSearchFieldKey_Identifier = 0x01;
  // 昵称
  static const int _kTIMGroupMemberSearchFieldKey_NickName = 0x01 << 1;
  // 备注
  static const int _kTIMGroupMemberSearchFieldKey_Remark = 0x01 << 2;
  // 名片
  static const int _kTIMGroupMemberSearchFieldKey_NameCard = 0x01 << 3;

  V2TimGroupMemberSearchParam({
    required this.keywordList,
    this.groupIDList,
    this.isSearchMemberUserID = true,
    this.isSearchMemberNickName = true,
    this.isSearchMemberRemark = true,
    this.isSearchMemberNameCard = true,
  });

  V2TimGroupMemberSearchParam.fromJson(Map json) {
    json = Utils.formatJson(json);
    keywordList = json['group_search_member_params_keyword_list']?.cast<String>() ?? [];
    groupIDList = json['group_search_member_params_groupid_list']?.cast<String>();
    List<int> searchFieldList = json['group_search_member_params_field_list']?.cast<int>() ?? [];
    for (int searchField in searchFieldList) {
      switch (searchField) {
        case _kTIMGroupMemberSearchFieldKey_Identifier:
          isSearchMemberUserID = true;
          break;
        case _kTIMGroupMemberSearchFieldKey_NickName:
          isSearchMemberNickName = true;
          break;
        case _kTIMGroupMemberSearchFieldKey_Remark:
          isSearchMemberRemark = true;
          break;
        case _kTIMGroupMemberSearchFieldKey_NameCard:
          isSearchMemberNameCard = true;
          break;
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['group_search_member_params_keyword_list'] = keywordList;
    data['group_search_member_params_groupid_list'] = groupIDList;
    List<int> searchFieldList = [];
    if (isSearchMemberUserID) {
      searchFieldList.add(_kTIMGroupMemberSearchFieldKey_Identifier);
    }
    if (isSearchMemberNickName) {
      searchFieldList.add(_kTIMGroupMemberSearchFieldKey_NickName);
    }
    if (isSearchMemberRemark) {
      searchFieldList.add(_kTIMGroupMemberSearchFieldKey_Remark);
    }
    if (isSearchMemberNameCard) {
      searchFieldList.add(_kTIMGroupMemberSearchFieldKey_NameCard);
    }
    data['group_search_member_params_field_list'] = searchFieldList;
    return data;
  }

  String toLogString() {
    String res =
        "keywordList:${json.encode(keywordList)}|groupIDList:${json.encode(groupIDList ?? [])}|isSearchMemberUserID:$isSearchMemberUserID|isSearchMemberNickName:$isSearchMemberNickName|isSearchMemberRemark:$isSearchMemberRemark|isSearchMemberNameCard:$isSearchMemberNameCard";
    return res;
  }
}
