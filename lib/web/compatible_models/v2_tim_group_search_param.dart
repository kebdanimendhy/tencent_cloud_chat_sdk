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

  V2TimGroupSearchParam({
    required this.keywordList,
    this.isSearchGroupID = true,
    this.isSearchGroupName = true,
  });

  V2TimGroupSearchParam.fromJson(Map json) {
    json = Utils.formatJson(json);
    keywordList = json['keywordList'];
    isSearchGroupID = json['isSearchGroupID'];
    isSearchGroupName = json['isSearchGroupName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['keywordList'] = keywordList;
    data['isSearchGroupID'] = isSearchGroupID;
    data['isSearchGroupName'] = isSearchGroupName;
    return data;
  }
  String toLogString() {
    String res = "${json.encode(keywordList)}|isSearchGroupID:$isSearchGroupID|isSearchGroupName:$isSearchGroupName";
    return res;
  }
}
