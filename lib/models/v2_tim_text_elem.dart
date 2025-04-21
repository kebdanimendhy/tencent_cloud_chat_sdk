import 'dart:convert';

import 'package:tencent_cloud_chat_sdk/enum/message_elem_type.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_elem.dart';
import 'package:tencent_cloud_chat_sdk/native_im/adapter/tim_c_enum.dart';
import 'package:tencent_cloud_chat_sdk/utils/utils.dart';

/// V2TimTextElem
///
/// {@category Models}
class V2TimTextElem extends V2TIMElem {
  late String? text;

  V2TimTextElem({
    this.text,
  }): super(elemType: MessageElemType.V2TIM_ELEM_TYPE_TEXT);

  V2TimTextElem.fromJson(Map json) {
    elemType = MessageElemType.V2TIM_ELEM_TYPE_TEXT;
    json = Utils.formatJson(json);
    text = json['text_elem_content'];
    if (json['nextElem'] != null) {
      nextElem = Utils.formatJson(json['nextElem']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['elem_type'] = CElemType.ElemText;
    data['text_elem_content'] = text;
    if (nextElem != null) {
      data['nextElem'] = nextElem;
    }
    return data;
  }

  formatJson(jsonSrc) {
    return json.decode(json.encode(jsonSrc));
  }
  String toLogString() {
    String res = "text:$text";
    return res;
  }
}

// {
//   "text":""
// }
