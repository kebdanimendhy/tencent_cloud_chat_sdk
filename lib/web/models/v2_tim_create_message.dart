import 'dart:html';
import 'package:tencent_cloud_chat_sdk/web/enum/message_priority.dart';
import 'package:tencent_cloud_chat_sdk/web/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/web/utils/utils.dart';

class CreateMessage {
  static Object createTextMessage(
      {required String userID,
      required String text,
      String cloudCustomData = "",
      String convType = 'C2C',
      bool needReadReceipt = false,
      int priority = 0}) {
    final textParams = {
      "to": userID,
      "needReadReceipt": needReadReceipt,
      "cloudCustomData": cloudCustomData,
      "conversationType": convType,
      "priority": MessagePriorityWeb.convertMsgPriorityToWeb(priority),
      "payload": mapToJSObj({"text": text})
    };
    return mapToJSObj(textParams);
  }

  // 不在此createMessage
  /*
      V2TIM_ELEM_TYPE_NONE                      = 0,  ///< 未知消息
    V2TIM_ELEM_TYPE_TEXT                      = 1,  ///< 文本消息
    V2TIM_ELEM_TYPE_CUSTOM                    = 2,  ///< 自定义消息
    V2TIM_ELEM_TYPE_IMAGE                     = 3,  ///< 图片消息
    V2TIM_ELEM_TYPE_SOUND                     = 4,  ///< 语音消息
    V2TIM_ELEM_TYPE_VIDEO                     = 5,  ///< 视频消息
    V2TIM_ELEM_TYPE_FILE                      = 6,  ///< 文件消息
    V2TIM_ELEM_TYPE_LOCATION                  = 7,  ///< 地理位置消息
    V2TIM_ELEM_TYPE_FACE                      = 8,  ///< 表情消息
    V2TIM_ELEM_TYPE_GROUP_TIPS                = 9,  ///< 群 Tips 消息
    V2TIM_ELEM_TYPE_MERGER                    = 10, ///< 合并消息
  */
  // web为了统一native的创建消息
  static createSimpleTextMessage(String text) {
    return {
      "type": "text",
      "elemType": 1,
      "textElem": {"text": text}
    };
  }

  static createSimpleCustomMessage(String data, String desc, String extension) {
    return {
      "elemType": 2,
      "type": "custom",
      "customElem": {"data": data, "desc": desc, "extension": extension}
    };
  }

  static createFile({required String path, String? name}) async {
    File? file;
    await window.fetch(path).then((r) async {
      Blob blob = await r.blob();
      file = File([blob], name ?? path.toString(), {'type': blob.type});
    });
    return file;
  }

  static createSimpleImageMessage(Map params) async {
    return {
      "elemType": 3,
      "type": "image",
      "imageElem": {
        "file": params["inputElement"] ??
            await createFile(
              path: params["imagePath"],
              name: params["imageName"],
            ),
      }
    };
  }

  static createSimpleSoundMessage(String file, int duration) {
    return {
      "elemType": 4,
      "type": "file",
      "imageElem": {"file": file, "duration": duration}
    };
  }

  static createSimpleVideoMessage(
    String videoFilePath,
    dynamic file,
  ) async {
    return {
      "elemType": 5,
      "type": "video",
      "videoElem": {
        "videoFilePath": videoFilePath,
        "file": file ?? await createFile(path: videoFilePath),
      }
    };
  }

  static createSimpleTextAtMessage(List<String> atUserList, String text) {
    return {
      "elemType": 6,
      "type": "textAt",
      "textAtElem": {
        "text": text,
        "atUserList": atUserList,
      }
    };
  }

  static createSimpleSounMessage(
      String snapshotPath, String videoFilePath, String type, int duration) {
    return {
      "elemType": 6,
      "type": "video",
      "textAtElem": {
        "videoFilePath": videoFilePath,
        "snapshotPath": snapshotPath,
        "duration": duration
      }
    };
  }

  static createSimpleFaceMessage({
    required int index,
    required String data,
  }) {
    return {
      "elemType": 8,
      "type": "face",
      "faceElem": {
        "index": index,
        "data": data,
      }
    };
  }

  static createSimpleAtText({
    required List<String> atUserList,
    required String text,
  }) {
    return {
      "elemType": 1,
      "type": "textAt",
      "textElem": {
        "atUserList": atUserList,
        "text": text,
      }
    };
  }

  static createSimpleLoaction({
    required String description,
    required double latitude,
    required double longitude,
  }) {
    return {
      "elemType": 7,
      "type": "location",
      "locationElem": {
        "latitude": latitude,
        "longitude": longitude,
        "description": description
      }
    };
  }

  static createSimpleMergeMessage(
      {required List<String> msgIDList,
      required String title,
      required List<String> abstractList,
      required String compatibleText,
      List<String>? webMessageInstanceList}) {
    return {
      "elemType": 10,
      "type": "mergeMessage",
      "mergerElem": {
        "abstractList": abstractList,
        "title": title,
        "msgIDList": msgIDList,
        "compatibleText": compatibleText,
        "webMessageInstanceList": webMessageInstanceList ?? []
      }
    };
  }

  static createSimpleFileMessage(
      {required String filePath,
      required String fileName,
      dynamic file}) async {
    return {
      "elemType": 6,
      "type": "file",
      "fileElem": {
        "filePath": filePath,
        "fileName": fileName,
        "file": file ??= await createFile(path: filePath, name: fileName)
      }
    };
  }

  static createSimpleForwardMessage({required webRawMessage}) async {
    final formatedMessage =
        await V2TIMMessage.convertMessageFromWebToDart(webRawMessage);
    formatedMessage['type'] = "forwardMessage";
    return formatedMessage;
  }

  static Object createCustomMessage(
      {required String userID,
      required String customData,
      int priority = 0,
      String convType = 'C2C',
      String description = '',
      String cloudCustomData = '',
      bool needReadReceipt = false,
      String extension = ''}) {
    final customParams = {
      "to": userID,
      "conversationType": convType,
      "cloudCustomData": cloudCustomData,
      "needReadReceipt": needReadReceipt,
      "priority": MessagePriorityWeb.convertMsgPriorityToWeb(priority),
      "payload": mapToJSObj({
        "data": customData,
        "description": description,
        "extension": extension
      })
    };

    return mapToJSObj(customParams);
  }

  static Object createImageMessage(
      {required String userID,
      required file,
      String convType = 'C2C',
      String cloudCustomData = '',
      bool needReadReceipt = false,
      required progressCallback,
      int priority = 0}) {
    final textParams = {
      "to": userID,
      "conversationType": convType,
      "cloudCustomData": cloudCustomData,
      "needReadReceipt": needReadReceipt,
      "priority": MessagePriorityWeb.convertMsgPriorityToWeb(priority),
      "payload": mapToJSObj({"file": file}),
      "onProgress": progressCallback
    };
    return mapToJSObj(textParams);
  }

  static Object createVideoMessage(
      {required String userID,
      required file,
      String convType = 'C2C',
      required progressCallback,
      bool needReadReceipt = false,
      String cloudCustomData = '',
      int priority = 0}) {
    final textParams = {
      "to": userID,
      "conversationType": convType,
      "cloudCustomData": cloudCustomData,
      "needReadReceipt": needReadReceipt,
      "priority": MessagePriorityWeb.convertMsgPriorityToWeb(priority),
      "payload": mapToJSObj({"file": file}),
      "onProgress": progressCallback
    };
    return mapToJSObj(textParams);
  }

  static Object createFaceMessage(
      {required String userID,
      String convType = 'C2C',
      required int index,
      required data,
      String cloudCustomData = '',
      bool needReadReceipt = false,
      int priority = 0}) {
    final textParams = {
      "to": userID,
      "conversationType": convType,
      "needReadReceipt": needReadReceipt,
      "cloudCustomData": cloudCustomData,
      "priority": MessagePriorityWeb.convertMsgPriorityToWeb(priority),
      "payload": mapToJSObj({"index": index, "data": data}),
    };
    return mapToJSObj(textParams);
  }

  static Object createFileMessage(
      {required String userID,
      required file,
      String convType = 'C2C',
      String cloudCustomData = '',
      required progressCallback,
      bool needReadReceipt = false,
      int priority = 0}) {
    final textParams = {
      "to": userID,
      "conversationType": convType,
      "cloudCustomData": cloudCustomData,
      "needReadReceipt": needReadReceipt,
      "priority": MessagePriorityWeb.convertMsgPriorityToWeb(priority),
      "payload": mapToJSObj({"file": file}),
      "onProgress": progressCallback
    };
    return mapToJSObj(textParams);
  }

  static Object createTextAtMessage(
      {required String groupID,
      required String text,
      required List<dynamic> atList,
      String cloudCustomData = '',
      bool needReadReceipt = false,
      int priority = 0}) {
    final textParams = {
      "to": groupID,
      "conversationType": "GROUP",
      "cloudCustomData": cloudCustomData,
      "needReadReceipt": needReadReceipt,
      "priority": MessagePriorityWeb.convertMsgPriorityToWeb(priority),
      "payload": mapToJSObj({"text": text, "atUserList": atList}),
    };
    return mapToJSObj(textParams);
  }

  static Object createLocationMessage(
      {required String userID,
      required String description,
      required double latitude,
      bool needReadReceipt = false,
      required double longitude,
      String cloudCustomData = '',
      String convType = 'C2C',
      int priority = 0}) {
    final textParams = {
      "to": userID,
      "conversationType": convType,
      "cloudCustomData": cloudCustomData,
      "needReadReceipt": needReadReceipt,
      "priority": MessagePriorityWeb.convertMsgPriorityToWeb(priority),
      "payload": mapToJSObj({
        "description": description,
        "longitude": longitude,
        "latitude": latitude
      }),
    };
    return mapToJSObj(textParams);
  }

  static Object createMereMessage(
      {required String userID,
      required List<dynamic> messageList,
      required String title,
      required List<String> abstractList,
      required String compatibleText,
      bool needReadReceipt = false,
      String cloudCustomData = '',
      String convType = 'C2C',
      int priority = 0}) {
    final params = {
      "to": userID,
      "conversationType": convType,
      "cloudCustomData": cloudCustomData,
      "needReadReceipt": needReadReceipt,
      "priority": MessagePriorityWeb.convertMsgPriorityToWeb(priority),
      "payload": mapToJSObj({
        "messageList": messageList,
        "title": title,
        "abstractList": abstractList,
        "compatibleText": compatibleText
      }),
    };

    return mapToJSObj(params);
  }

  static Object createForwardMessage(
      {required String userID,
      required dynamic message,
      String convType = 'C2C',
      String cloudCustomData = '',
      bool needReadReceipt = false,
      int priority = 0}) {
    final params = {
      "to": userID,
      "conversationType": convType,
      "cloudCustomData": cloudCustomData,
      "needReadReceipt": needReadReceipt,
      "priority": MessagePriorityWeb.convertMsgPriorityToWeb(priority),
      "payload": message,
    };

    return mapToJSObj(params);
  }
}
