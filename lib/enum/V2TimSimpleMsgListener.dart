// ignore_for_file: file_names, prefer_function_declarations_over_variables

import 'package:tencent_cloud_chat_sdk/enum/callbacks.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_info.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_group_member_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_info.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_user_info.dart';

class V2TimSimpleMsgListener {
  OnRecvC2CCustomMessageCallback onRecvC2CCustomMessage = (
    String msgID,
    V2TimUserInfo userInfo,
    String text,
  ) {};
  OnRecvC2CTextMessageCallback onRecvC2CTextMessage = (
    String msgID,
    V2TimUserInfo sender,
    String customData,
  ) {};
  OnRecvGroupCustomMessageCallback onRecvGroupCustomMessage = (
    String msgID,
    String groupID,
    V2TimGroupMemberInfo sender,
    String customData,
  ) {};
  OnRecvGroupCustomMessageCallback onRecvGroupTextMessage = (
    String msgID,
    String groupID,
    V2TimGroupMemberInfo sender,
    String text,
  ) {};

  V2TimSimpleMsgListener({
    OnRecvC2CCustomMessageCallback? onRecvC2CCustomMessage,
    OnRecvC2CTextMessageCallback? onRecvC2CTextMessage,
    OnRecvGroupCustomMessageCallback? onRecvGroupCustomMessage,
    OnRecvGroupCustomMessageCallback? onRecvGroupTextMessage,
  }) {
    if (onRecvC2CCustomMessage != null) {
      this.onRecvC2CCustomMessage = onRecvC2CCustomMessage;
    }
    if (onRecvC2CTextMessage != null) {
      this.onRecvC2CTextMessage = onRecvC2CTextMessage;
    }
    if (onRecvGroupCustomMessage != null) {
      this.onRecvGroupCustomMessage = onRecvGroupCustomMessage;
    }
    if (onRecvGroupTextMessage != null) {
      this.onRecvGroupTextMessage = onRecvGroupTextMessage;
    }
  }
}
