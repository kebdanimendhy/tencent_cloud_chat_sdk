import 'package:tencent_cloud_chat_sdk/utils/utils.dart';

class V2TimConversationFilter {
  int? conversationType;

  String? conversationGroup;

  int? markType;

  bool? hasUnreadCount;

  bool? hasGroupAtInfo;

  V2TimConversationFilter({
    this.conversationGroup,
    this.conversationType,
    this.hasGroupAtInfo,
    this.hasUnreadCount,
    this.markType,
  });

  V2TimConversationFilter.fromJson(Map json) {
    json = Utils.formatJson(json);
    conversationType = json['conversation_list_filter_conv_type'];
    conversationGroup = json['conversation_list_filter_conversation_group'] ?? "";
    markType = json['conversation_list_filter_mark_type'] ?? 0;
    hasUnreadCount = json['conversation_list_filter_has_unread_count'];
    hasGroupAtInfo = json['conversation_list_filter_has_group_at_info'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['conversation_list_filter_conv_type'] = conversationType;
    data['conversation_list_filter_conversation_group'] = conversationGroup;
    data['conversation_list_filter_mark_type'] = markType;
    data['conversation_list_filter_has_unread_count'] = hasUnreadCount;
    data['conversation_list_filter_has_group_at_info'] = hasGroupAtInfo;
    return data;
  }

  String toLogString() {
    String res = "conversationType:$conversationType|conversationGroup:$conversationGroup|markType:$markType|hasUnreadCount:$hasUnreadCount|hasGroupAtInfo:$hasGroupAtInfo";
    return res;
  }
}
