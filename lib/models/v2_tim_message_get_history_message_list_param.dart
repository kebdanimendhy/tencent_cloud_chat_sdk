import 'v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/enum/history_msg_get_type_enum.dart';

/// V2TimMessageGetHistoryMessageListParam
///
/// {@category Models}
///
class V2TimMessageGetHistoryMessageListParam {
  late int count;
  late bool isRamble;
  late bool isForward;
  V2TimMessage? lastMessage;
  List<int>? messageTypeList;
  int? lastMessageSeq;
  int? timeBegin;
  int? timePeriod;
  List<int>? messageSeqList;

  V2TimMessageGetHistoryMessageListParam({
    required this.count,
    HistoryMsgGetTypeEnum? getType,
    this.lastMessage,
    this.messageTypeList,
    this.lastMessageSeq,
    this.timeBegin,
    this.timePeriod,
    this.messageSeqList,
  }) {
    // 默认为 HistoryMsgGetTypeEnum.V2TIM_GET_LOCAL_OLDER_MSG
    isRamble = false;
    isForward = false;

    if (getType != null) {
      switch (getType) {
        case HistoryMsgGetTypeEnum.V2TIM_GET_CLOUD_OLDER_MSG:
          isRamble = true;
          isForward = false;
          break;
        case HistoryMsgGetTypeEnum.V2TIM_GET_CLOUD_NEWER_MSG:
          isRamble = true;
          isForward = true;
          break;
        case HistoryMsgGetTypeEnum.V2TIM_GET_LOCAL_OLDER_MSG:
          isRamble = false;
          isForward = false;
          break;
        case HistoryMsgGetTypeEnum.V2TIM_GET_LOCAL_NEWER_MSG:
          isRamble = false;
          isForward = true;
          break;
        default:
          isRamble = false;
          isForward = false;
          break;
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg_getmsglist_param_count'] = count;
    data['msg_getmsglist_param_is_ramble'] = isRamble;
    data['msg_getmsglist_param_is_forward'] = isForward;
    data['msg_getmsglist_param_last_msg'] = lastMessage?.toJson();
    data['msg_getmsglist_param_message_type_array'] = messageTypeList;
    data['msg_getmsglist_param_last_msg_seq'] = lastMessageSeq;
    data['msg_getmsglist_param_time_begin'] = timeBegin;
    data['msg_getmsglist_param_time_period'] = timePeriod;
    data['msg_getmsglist_param_message_seq_array'] = messageSeqList;

    return data;
  }

  String toLogString() {
    String res = 'count: $count|isRamble: $isRamble|isForward: $isForward|lastMessage: $lastMessage|messageTypeList: $messageTypeList|lastMessageSeq: $lastMessageSeq|timeBegin: $timeBegin|timePeriod: $timePeriod|messageSeqList: $messageSeqList';
    return res;
  }
}