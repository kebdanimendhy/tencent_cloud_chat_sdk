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
    keywordList = json['keywordList'];
    groupIDList = json['groupIDList'];
    isSearchMemberUserID = json['isSearchMemberUserID'];
    isSearchMemberNickName = json['isSearchMemberNickName'];
    isSearchMemberRemark = json['isSearchMemberRemark'];
    isSearchMemberNameCard = json['isSearchMemberNameCard'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['keywordList'] = keywordList;
    data['groupIDList'] = groupIDList;
    data['isSearchMemberUserID'] = isSearchMemberUserID;
    data['isSearchMemberNickName'] = isSearchMemberNickName;
    data['isSearchMemberRemark'] = isSearchMemberRemark;
    data['isSearchMemberNameCard'] = isSearchMemberNameCard;
    return data;
  }
  String toLogString() {
    String res =
        "keywordList:${json.encode(keywordList)}|groupIDList:${json.encode(groupIDList)}|isSearchMemberUserID:$isSearchMemberUserID|isSearchMemberNickName:$isSearchMemberNickName|isSearchMemberRemark:$isSearchMemberRemark|isSearchMemberNameCard:$isSearchMemberNameCard";
    return res;
  }
}
