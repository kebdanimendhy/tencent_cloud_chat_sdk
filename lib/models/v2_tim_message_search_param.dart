import 'package:tencent_cloud_chat_sdk/utils/utils.dart';
import 'package:tencent_cloud_chat_sdk/enum/utils.dart';

/// V2TimMessageSearchParam
///
/// {@category Models}
///
class V2TimMessageSearchParam {
  String? conversationID;
  late List<String> keywordList;
  late int type;
  List<String>? userIDList = [];
  List<int>? messageTypeList = [];
  int? searchTimePosition;
  int? searchTimePeriod;
  int? pageSize = 100;
  int? pageIndex = 0;
  int? searchCount = 10;
  String? searchCursor = "";
  V2TimMessageSearchParam({
    required this.type,
    required this.keywordList,
    this.conversationID,
    this.userIDList,
    this.messageTypeList,
    this.searchTimePosition,
    this.searchTimePeriod,
    this.pageSize,
    this.pageIndex,
    this.searchCount,
    this.searchCursor,
  }) {
    messageTypeList = messageTypeList?.map((e) => EnumUtils.dartElemType2CElemType(e)).toList();
  }

  V2TimMessageSearchParam.fromJson(Map json) {
    json = Utils.formatJson(json);
    conversationID = json['msg_search_param_conv_id'];
    keywordList = json['msg_search_param_keyword_array']?.cast<String>() ?? [];
    type = json['msg_search_param_keyword_list_match_type'];
    userIDList = json['msg_search_param_send_identifier_array']?.cast<String>() ?? [];
    messageTypeList = json['msg_search_param_message_type_array']?.cast<int>() ?? [];
    searchTimePosition = json['msg_search_param_search_time_position'];
    searchTimePeriod = json['msg_search_param_search_time_period'];
    pageSize = json['msg_search_param_page_size'];
    pageIndex = json['msg_search_param_page_index'];
    searchCount = json["msg_search_param_search_count"] ?? 10;
    searchCursor = json["msg_search_param_search_cursor"] ?? "";

    messageTypeList = messageTypeList?.map((e) => EnumUtils.cElemType2DartElemType(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg_search_param_conv_id'] = conversationID;
    data['msg_search_param_keyword_array'] = keywordList;
    data['msg_search_param_keyword_list_match_type'] = type;
    data['msg_search_param_send_identifier_array'] = userIDList ?? List.empty(growable: true);
    data['msg_search_param_message_type_array'] = messageTypeList ?? List.empty(growable: true);
    data['msg_search_param_search_time_position'] = searchTimePosition;
    data['msg_search_param_search_time_period'] = searchTimePeriod;
    data['msg_search_param_page_size'] = pageSize;
    data['msg_search_param_page_index'] = pageIndex;
    data['msg_search_param_search_count'] = searchCount;
    data['msg_search_param_search_cursor'] = searchCursor;
    return data;
  }
  String toLogString() {
    String res = "conversationID:$conversationID|keywordList:$keywordList|type:$type|userIDList:$userIDList|messageTypeList:$messageTypeList|searchTimePosition:$searchTimePosition|searchTimePeriod:$searchTimePeriod|pageSize:$pageSize|pageIndex:$pageIndex|searchCount:$searchCount|searchCursor:$searchCursor";
    return res;
  }
}
