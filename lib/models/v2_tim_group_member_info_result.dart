import 'dart:convert';

import 'package:tencent_cloud_chat_sdk/utils/utils.dart';
import 'v2_tim_group_member_full_info.dart';

/// V2TimGroupMemberInfoResult
///
/// {@category Models}
///

class V2TimGroupMemberInfoResult {
  late String? nextSeq;
  List<V2TimGroupMemberFullInfo?>? memberInfoList = List.empty(growable: true);

  V2TimGroupMemberInfoResult({
    this.nextSeq,
    this.memberInfoList,
  });

  V2TimGroupMemberInfoResult.fromJson(Map json) {
    json = Utils.formatJson(json);
    nextSeq = json['group_get_member_info_list_result_next_seq'].toString();
    if (json['group_get_member_info_list_result_info_array'] != null) {
      memberInfoList = List.empty(growable: true);
      json['group_get_member_info_list_result_info_array'].forEach((v) {
        memberInfoList!.add(V2TimGroupMemberFullInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['group_get_member_info_list_result_next_seq'] = nextSeq;
    if (memberInfoList != null) {
      data['group_get_member_info_list_result_info_array'] = memberInfoList?.map((v) => v?.toJson()).toList();
    }
    return data;
  }
  String toLogString() {
    String res = "nextSeq:$nextSeq|memberInfoList:${json.encode(memberInfoList?.map((e) => e?.toLogString()).toList())}";
    return res;
  }
}
// {
//   "nextSeq":0,
//   "memberInfoList":[{}]
// }
