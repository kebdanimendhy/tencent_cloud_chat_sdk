import 'dart:convert';

import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_search_result_item.dart';
import 'package:tencent_cloud_chat_sdk/utils/utils.dart';

/// V2TimMessageSearchResult
///
/// {@category Models}
///
class V2TimMessageSearchResult {
  int? totalCount;
  List<V2TimMessageSearchResultItem>? messageSearchResultItems;
  String? searchCursor;
  V2TimMessageSearchResult({
    this.totalCount,
    this.messageSearchResultItems,
    this.searchCursor,
  });

  V2TimMessageSearchResult.fromJson(Map json) {
    json = Utils.formatJson(json);
    totalCount = json['msg_search_result_total_count'];
    searchCursor = json["msg_search_result_search_cursor"] ?? "";
    if (json['msg_search_result_item_array'] != null) {
      messageSearchResultItems = List.empty(growable: true);
      json['msg_search_result_item_array'].forEach((v) {
        messageSearchResultItems!.add(V2TimMessageSearchResultItem.fromJson(v));
      });
    } else {
      messageSearchResultItems = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalCount'] = totalCount;
    data["searchCursor"] = searchCursor;
    if (messageSearchResultItems != null) {
      data['messageSearchResultItems'] = messageSearchResultItems?.map((v) => v.toJson()).toList();
    }
    return data;
  }

  String toLogString() {
    String res = "totalCount:$totalCount|searchCursor:$searchCursor|messageSearchResultItems:${json.encode(messageSearchResultItems?.map((e) => e.toJson()).toList())}";
    return res;
  }
}

// {
//   "userID":"",
//   "timestamp":0
// }
