import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/enum/get_group_message_read_member_list_filter.dart';
import 'package:tencent_cloud_chat_sdk/enum/history_msg_get_type_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_elem_type.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_priority_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/receive_message_opt_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/v2_tim_keyword_list_match_type.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_extension.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_extension.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_list_result.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_list_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_search_param.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_search_param.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk_example/utils/log_manager.dart';
import '../utils/utils.dart';
import 'base_api_test.dart';

class MessageAPITest extends StatefulWidget {
  const MessageAPITest({Key? key}) : super(key: key);

  @override
  State<MessageAPITest> createState() => _MessageAPITestState();
}

class _MessageAPITestState extends State<MessageAPITest> {
  final TextEditingController _receiverIDController = TextEditingController();
  final TextEditingController _groupIDController = TextEditingController();
  final TextEditingController _messageContentController = TextEditingController();
  final TextEditingController _messageIDController = TextEditingController();
  final TextEditingController _customDataController = TextEditingController();
  final TextEditingController _messageTypeController = TextEditingController();
  final TextEditingController _conversationIDController = TextEditingController();
  // 拉取历史消息参数
  final TextEditingController _countHistoryController = TextEditingController(text: '20');
  final TextEditingController _lastMsgIDHistoryController = TextEditingController();
  final TextEditingController _lastMsgTimeHistoryController = TextEditingController();
  final TextEditingController _userIDHistoryController = TextEditingController();
  final TextEditingController _groupIDHistoryController = TextEditingController();
  final TextEditingController _lastMsgSeqHistoryController = TextEditingController();
  final TextEditingController _messageTypeListHistoryController = TextEditingController();
  final TextEditingController _messageSeqListHistoryController = TextEditingController();
  final TextEditingController _timeBeginHistoryController = TextEditingController();
  final TextEditingController _timePeriodHistoryController = TextEditingController();
  
  final TextEditingController _faceIndexController = TextEditingController();
  final TextEditingController _faceDataController = TextEditingController();
  final TextEditingController _locationDescController = TextEditingController();
  final TextEditingController _locationLongitudeController = TextEditingController();
  final TextEditingController _locationLatitudeController = TextEditingController();
  
  // 媒体消息相关控制器
  final TextEditingController _videoDurationController = TextEditingController();
  final TextEditingController _soundDurationController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();
  
  // 合并消息和转发消息相关控制器
  final TextEditingController _mergerMsgIDListController = TextEditingController();
  final TextEditingController _forwardMsgIDListController = TextEditingController();
  
  // @消息相关控制器
  final TextEditingController _atUserIDListController = TextEditingController();
  final TextEditingController _atTextController = TextEditingController();
  
  // 本地自定义数据和整数相关控制器
  final TextEditingController _localCustomDataController = TextEditingController();
  final TextEditingController _localCustomIntController = TextEditingController();
  
  // 存储获取到的消息列表
  List<V2TimMessage> _messageList = [];
  
  // 使用全局日志管理器和监听器管理器
  final LogManager _logManager = LogManager();

  // 消息接收选项
  ReceiveMsgOptEnum _receiveMessageOpt = ReceiveMsgOptEnum.V2TIM_RECEIVE_MESSAGE;

  @override
  void initState() {
    super.initState();
    // 初始化全局监听器
    _receiverIDController.text = 'teacher13';
    _groupIDController.text = 'public15';
    _messageContentController.text = '测试消息';
    _customDataController.text = '自定义数据';
    _faceIndexController.text = '1';
    _faceDataController.text = '[微笑]';
    _locationDescController.text = '深圳腾讯滨海大厦';
    _locationLongitudeController.text = '113.943488';
    _locationLatitudeController.text = '22.546057';
    // 历史消息
    _userIDHistoryController.text = 'teacher13';
    _groupIDHistoryController.text = 'public15';
  }

  // 添加日志的帮助方法
  void _addLog(String log) {
    _logManager.updateLogText(log);
  }

  // 清空日志
  void _clearLog() {
    _logManager.clearAllLogs();
  }

  // 发送文本消息
  Future<void> _sendTextMessage() async {
    if (_messageContentController.text.isEmpty) {
      _addLog('请输入消息内容');
      return;
    }
    if (_receiverIDController.text.isEmpty && _groupIDController.text.isEmpty) {
      _addLog('请输入接收者ID或群组ID');
      return;
    }
    try {
      // 先创建文本消息
      V2TimValueCallback<V2TimMsgCreateInfoResult> createResult = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createTextMessage(
        text: _messageContentController.text,
      );

      if (createResult.code != 0) {
        _addLog('创建文本消息失败: ${createResult.toJson()}');
        return;
      }
      
      // 发送创建的消息
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
        id: createResult.data?.id ?? '',
        receiver: _receiverIDController.text,
        groupID: _groupIDController.text,
        priority: MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
        needReadReceipt: true,
        isSupportMessageExtension: true,
      );
      _addLog('发送文本消息成功: ${result.toJson()}');
    } catch (e) {
      _addLog('发送文本消息失败: $e');
    }
  }

  // 发送自定义消息
  Future<void> _sendCustomMessage() async {
    if (_customDataController.text.isEmpty) {
      _addLog('请输入自定义数据');
      return;
    }
    if (_receiverIDController.text.isEmpty && _groupIDController.text.isEmpty) {
      _addLog('请输入接收者ID或群组ID');
      return;
    }
    try {
      // 先创建自定义消息
      final createResult = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createCustomMessage(
        data: _customDataController.text,
        desc: '自定义消息',
        extension: '',
      );
      
      if (createResult.code != 0) {
        _addLog('创建自定义消息失败: ${createResult.toJson()}');
        return;
      }
      
      // 发送创建的消息
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
        id: createResult.data?.id ?? '',
        receiver: _receiverIDController.text,
        groupID: _groupIDController.text,
        priority: MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
        needReadReceipt: true,
        isSupportMessageExtension: true,
      );
      _addLog('发送自定义消息成功: ${result.toJson()}');
    } catch (e) {
      _addLog('发送自定义消息失败: $e');
    }
  }

  // 发送表情消息
  Future<void> _sendFaceMessage() async {
    if (_faceIndexController.text.isEmpty || _faceDataController.text.isEmpty) {
      _addLog('请输入表情索引和表情数据');
      return;
    }
    if (_receiverIDController.text.isEmpty && _groupIDController.text.isEmpty) {
      _addLog('请输入接收者ID或群组ID');
      return;
    }
    try {
      // 先创建表情消息
      final createResult = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createFaceMessage(
        index: int.parse(_faceIndexController.text),
        data: _faceDataController.text,
      );
      
      if (createResult.code != 0) {
        _addLog('创建表情消息失败: ${createResult.toJson()}');
        return;
      }
      
      // 发送创建的消息
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
        id: createResult.data?.id ?? '',
        receiver: _receiverIDController.text,
        groupID: _groupIDController.text,
        priority: MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
        needReadReceipt: true,
        isSupportMessageExtension: true,
      );
      _addLog('发送表情消息成功: ${result.toJson()}');
    } catch (e) {
      _addLog('发送表情消息失败: $e');
    }
  }

  // 发送位置消息
  Future<void> _sendLocationMessage() async {
    if (_locationDescController.text.isEmpty || 
        _locationLongitudeController.text.isEmpty || 
        _locationLatitudeController.text.isEmpty) {
      _addLog('请输入位置描述、经度和纬度');
      return;
    }
    if (_receiverIDController.text.isEmpty && _groupIDController.text.isEmpty) {
      _addLog('请输入接收者ID或群组ID');
      return;
    }
    try {
      // 先创建位置消息
      final createResult = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createLocationMessage(
        desc: _locationDescController.text,
        longitude: double.parse(_locationLongitudeController.text),
        latitude: double.parse(_locationLatitudeController.text),
      );
      
      if (createResult.code != 0) {
        _addLog('创建位置消息失败: ${createResult.toJson()}');
        return;
      }
      
      // 发送创建的消息
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
        id: createResult.data?.id ?? '',
        receiver: _receiverIDController.text,
        groupID: _groupIDController.text,
        priority: MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
        needReadReceipt: true,
        isSupportMessageExtension: true,
      );
      _addLog('发送位置消息成功: ${result.toJson()}');
    } catch (e) {
      _addLog('发送位置消息失败: $e');
    }
  }

  // 获取消息历史
  Future<void> _getMessageHistory() async {
    if (_countHistoryController.text.isEmpty) {
      _addLog('请输入获取消息数量');
      return;
    }
    try {
      V2TimValueCallback<V2TimMessageListResult> result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().getHistoryMessageListV2(
        getType: HistoryMsgGetTypeEnum.V2TIM_GET_LOCAL_OLDER_MSG,
        userID: _userIDHistoryController.text.isEmpty ? null : _userIDHistoryController.text,
        groupID: _groupIDHistoryController.text.isEmpty ? null : _groupIDHistoryController.text,
        lastMsgSeq: _lastMsgSeqHistoryController.text.isEmpty ? -1 : int.parse(_lastMsgSeqHistoryController.text),
        count: int.parse(_countHistoryController.text),
        lastMsgID: _lastMsgIDHistoryController.text.isEmpty ? null : _lastMsgIDHistoryController.text,
        messageTypeList: _messageTypeListHistoryController.text.isEmpty ? null :
          _messageTypeListHistoryController.text.split(',').map((e) => int.parse(e)).toList(),
        messageSeqList: _messageSeqListHistoryController.text.isEmpty ? null :
          _messageSeqListHistoryController.text.split(',').map((e) => int.parse(e)).toList(),
        timeBegin: _timeBeginHistoryController.text.isEmpty ? null : int.parse(_timeBeginHistoryController.text),
        timePeriod: _timePeriodHistoryController.text.isEmpty ? null : int.parse(_timePeriodHistoryController.text),
      );
      if (result.code == 0) {
        _messageList = result.data?.messageList ?? [];
        String messageListLog = '';
        for (V2TimMessage msg in _messageList) {
          messageListLog += 'msgID:${msg.msgID}|status:${msg.status}|msgTime:${msg.timestamp}|seq:${msg.seq}|random:${msg.random}|elemType:${msg.elemType}|content:${Utils.getMessageContent(msg)}\n';
        }
        _addLog('获取消息历史: $messageListLog');
      } else {
        _addLog('获取消息历史失败, code: ${result.code}, desc: ${result.desc}');
      }
    } catch (e) {
      _addLog('获取消息历史失败: $e');
    }
  }

  // 删除消息
  Future<void> _deleteMessage() async {
    if (_messageIDController.text.isEmpty) {
      _addLog('请输入消息ID');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().deleteMessages(
        msgIDs: [_messageIDController.text],
      );
      _addLog('删除消息: ${result.toJson()}');
    } catch (e) {
      _addLog('删除消息失败: $e');
    }
  }

  // 撤回消息
  Future<void> _revokeMessage() async {
    if (_messageIDController.text.isEmpty) {
      _addLog('请输入消息ID');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().revokeMessage(
        msgID: _messageIDController.text,
      );

      _addLog('撤回消息: ${result.toJson()}');
    } catch (e) {
      _addLog('撤回消息失败: $e');
    }
  }

  // 发送图片消息
  Future<void> _sendImageMessage() async {
    if (_receiverIDController.text.isEmpty && _groupIDController.text.isEmpty) {
      _addLog('请输入接收者ID或群组ID');
      return;
    }
    try {
      // 先创建图片消息
      final createResult = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createImageMessage(
        imagePath: '/storage/emulated/0/test.png',
      );
      
      if (createResult.code != 0) {
        _addLog('创建图片消息失败: ${createResult.toJson()}');
        return;
      }
      
      // 发送创建的消息
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
        id: createResult.data?.id ?? '',
        receiver: _receiverIDController.text,
        groupID: _groupIDController.text,
        priority: MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
        needReadReceipt: true,
        isSupportMessageExtension: true,
      );
      if (result.code == 0) {
        _addLog('发送图片消息成功，msgID: ${result.data?.msgID}');
      } else {
        _addLog('发送图片消息失败，code: ${result.code}, desc: ${result.desc}');
      }

    } catch (e) {
      _addLog('发送图片消息失败: $e');
    }
  }

  // 发送视频消息
  Future<void> _sendVideoMessage() async {
    if (_receiverIDController.text.isEmpty && _groupIDController.text.isEmpty) {
      _addLog('请输入接收者ID或群组ID');
      return;
    }
    try {
      // 先创建视频消息
      final createResult = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createVideoMessage(
        videoFilePath: '/storage/emulated/0/test.mp4',
        snapshotPath: '/storage/emulated/0/test-snapshot.png',
        duration: int.parse(_videoDurationController.text),
        type: "mp4",
      );
      
      if (createResult.code != 0) {
        _addLog('创建视频消息失败: ${createResult.toJson()}');
        return;
      }
      
      // 发送创建的消息
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
        id: createResult.data?.id ?? '',
        receiver: _receiverIDController.text,
        groupID: _groupIDController.text,
        priority: MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
        needReadReceipt: true,
        isSupportMessageExtension: true,
      );
      _addLog('发送视频消息成功: ${result.toJson()}');
    } catch (e) {
      _addLog('发送视频消息失败: $e');
    }
  }

  // 发送语音消息
  Future<void> _sendSoundMessage() async {
    if (_receiverIDController.text.isEmpty && _groupIDController.text.isEmpty) {
      _addLog('请输入接收者ID或群组ID');
      return;
    }
    try {
      // 先创建语音消息
      final createResult = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createSoundMessage(
        soundPath: '/storage/emulated/0/test.mp3',
        duration: int.parse(_soundDurationController.text),
      );
      
      if (createResult.code != 0) {
        _addLog('创建语音消息失败: ${createResult.toJson()}');
        return;
      }
      
      // 发送创建的消息
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
        id: createResult.data?.id ?? '',
        receiver: _receiverIDController.text,
        groupID: _groupIDController.text,
        priority: MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
        needReadReceipt: true,
        isSupportMessageExtension: true,
      );
      _addLog('发送语音消息成功: ${result.toJson()}');
    } catch (e) {
      _addLog('发送语音消息失败: $e');
    }
  }

  // 发送文件消息
  Future<void> _sendFileMessage() async {
    if (_receiverIDController.text.isEmpty && _groupIDController.text.isEmpty) {
      _addLog('请输入接收者ID或群组ID');
      return;
    }
    if (_fileNameController.text.isEmpty) {
      _addLog('请输入文件名');
      return;
    }
    try {
      // 先创建文件消息
      final createResult = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createFileMessage(
        filePath: '/storage/emulated/0/test.mp3',
        fileName: _fileNameController.text,
      );
      
      if (createResult.code != 0) {
        _addLog('创建文件消息失败: ${createResult.toJson()}');
        return;
      }
      
      // 发送创建的消息
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
        id: createResult.data?.id ?? '',
        receiver: _receiverIDController.text,
        groupID: _groupIDController.text,
        priority: MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
        needReadReceipt: true,
        isSupportMessageExtension: true,
      );
      _addLog('发送文件消息成功: ${result.toJson()}');
    } catch (e) {
      _addLog('发送文件消息失败: $e');
    }
  }

  // 发送合并消息
  Future<void> _sendMergerMessage() async {
    if (_receiverIDController.text.isEmpty && _groupIDController.text.isEmpty) {
      _addLog('请输入接收者ID或群组ID');
      return;
    }
    if (_messageList.length < 2) {
      _addLog('请先获取至少两条消息历史');
      return;
    }
    try {
      // 先创建合并消息
      final createResult = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createMergerMessage(
        msgIDList: [_messageList[0].msgID ?? "", _messageList[1].msgID ?? ""], // 使用前两条消息
        title: '合并消息标题',
        abstractList: ['摘要1', '摘要2'],
        compatibleText: "合并消息",
      );
      
      if (createResult.code != 0) {
        _addLog('创建合并消息失败: ${createResult.toJson()}');
        return;
      }
      
      // 发送创建的消息
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
        id: createResult.data?.id ?? '',
        receiver: _receiverIDController.text,
        groupID: _groupIDController.text,
        priority: MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
        needReadReceipt: true,
        isSupportMessageExtension: true,
      );
      _addLog('发送合并消息成功: ${result.toJson()}');
    } catch (e) {
      _addLog('发送合并消息失败: $e');
    }
  }

  // 发送转发消息
  Future<void> _sendForwardMessage() async {
    if (_receiverIDController.text.isEmpty && _groupIDController.text.isEmpty) {
      _addLog('请输入接收者ID或群组ID');
      return;
    }
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      // 先创建转发消息
      final createResult = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createForwardMessage(
        msgID: _messageList[0].msgID ?? "", // 使用第一条消息
      );
      
      if (createResult.code != 0) {
        _addLog('创建转发消息失败: ${createResult.toJson()}');
        return;
      }
      
      // 发送创建的消息
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
        id: createResult.data?.id ?? '',
        receiver: _receiverIDController.text,
        groupID: _groupIDController.text,
        priority: MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
        needReadReceipt: true,
        isSupportMessageExtension: true,
      );
      _addLog('发送转发消息成功: ${result.toJson()}');
    } catch (e) {
      _addLog('发送转发消息失败: $e');
    }
  }

  // 发送@消息
  Future<void> _sendTextAtMessage() async {
    if (_receiverIDController.text.isEmpty && _groupIDController.text.isEmpty) {
      _addLog('请输入接收者ID或群组ID');
      return;
    }
    if (_atTextController.text.isEmpty) {
      _addLog('请输入@消息内容');
      return;
    }
    if (_atUserIDListController.text.isEmpty) {
      _addLog('请输入@用户ID列表');
      return;
    }
    try {
      // 先创建@消息
      final createResult = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createTextAtMessage(
        text: _atTextController.text,
        atUserList: _atUserIDListController.text.split(','),
      );
      
      if (createResult.code != 0) {
        _addLog('创建@消息失败: ${createResult.toJson()}');
        return;
      }
      
      // 发送创建的消息
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
        id: createResult.data?.id ?? '',
        receiver: _receiverIDController.text,
        groupID: _groupIDController.text,
        priority: MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
        needReadReceipt: true,
        isSupportMessageExtension: true,
      );
      _addLog('发送@消息成功: ${result.toJson()}');
    } catch (e) {
      _addLog('发送@消息失败: $e');
    }
  }

  // 下载合并消息
  Future<void> _downloadMergerMessage() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().downloadMergerMessage(
        msgID: _messageList[0].msgID ?? "",
      );
      _addLog('下载合并消息: ${result.toJson()}');
    } catch (e) {
      _addLog('下载合并消息失败: $e');
    }
  }

  // 设置C2C消息接收选项
  Future<void> _setC2CReceiveMessageOpt() async {
    if (_receiverIDController.text.isEmpty) {
      _addLog('请输入用户ID');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().setC2CReceiveMessageOpt(
        userIDList: [_receiverIDController.text],
        opt: _receiveMessageOpt,
      );
      _addLog('设置C2C消息接收选项: ${result.toJson()}');
    } catch (e) {
      _addLog('设置C2C消息接收选项失败: $e');
    }
  }

  // 获取C2C消息接收选项
  Future<void> _getC2CReceiveMessageOpt() async {
    if (_receiverIDController.text.isEmpty) {
      _addLog('请输入用户ID');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().getC2CReceiveMessageOpt(
        userIDList: [_receiverIDController.text],
      );
      _addLog('获取C2C消息接收选项: ${result.toJson()}');
    } catch (e) {
      _addLog('获取C2C消息接收选项失败: $e');
    }
  }

  // 设置群组消息接收选项
  Future<void> _setGroupReceiveMessageOpt() async {
    if (_groupIDController.text.isEmpty) {
      _addLog('请输入群组ID');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().setGroupReceiveMessageOpt(
        groupID: _groupIDController.text,
        opt: _receiveMessageOpt,
      );
      _addLog('设置群组消息接收选项: ${result.toJson()}');
    } catch (e) {
      _addLog('设置群组消息接收选项失败: $e');
    }
  }

  // 设置全局消息接收选项
  Future<void> _setAllReceiveMessageOpt() async {
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().setAllReceiveMessageOpt(
        opt: _receiveMessageOpt.index,
        startHour: 0,  // 默认从0点开始
        startMinute: 0,
        startSecond: 0,
        duration: 24 * 60 * 60,  // 默认持续24小时
      );
      _addLog('设置全局消息接收选项: ${result.toJson()}');
    } catch (e) {
      _addLog('设置全局消息接收选项失败: $e');
    }
  }

  // 设置全局消息接收选项（带时间戳）
  Future<void> _setAllReceiveMessageOptWithTimestamp() async {
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().setAllReceiveMessageOptWithTimestamp(
        opt: _receiveMessageOpt.index,
        startTimeStamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        duration: 24 * 60 * 60,  // 默认持续24小时
      );
      _addLog('设置全局消息接收选项(带时间戳): ${result.toJson()}');
    } catch (e) {
      _addLog('设置全局消息接收选项(带时间戳)失败: $e');
    }
  }

  // 获取全局消息接收选项
  Future<void> _getAllReceiveMessageOpt() async {
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().getAllReceiveMessageOpt();
      _addLog('获取全局消息接收选项: ${result.toJson()}');
    } catch (e) {
      _addLog('获取全局消息接收选项失败: $e');
    }
  }

  // 设置本地自定义数据
  Future<void> _setLocalCustomData() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    if (_localCustomDataController.text.isEmpty) {
      _addLog('请输入本地自定义数据');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().setLocalCustomData(
        msgID: _messageList[0].msgID ?? "",
        localCustomData: _localCustomDataController.text,
      );
      _addLog('设置本地自定义数据: ${result.toJson()}');
    } catch (e) {
      _addLog('设置本地自定义数据失败: $e');
    }
  }

  // 设置本地自定义整数
  Future<void> _setLocalCustomInt() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    if (_localCustomIntController.text.isEmpty) {
      _addLog('请输入本地自定义整数');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().setLocalCustomInt(
        msgID: _messageList[0].msgID ?? "",
        localCustomInt: int.parse(_localCustomIntController.text),
      );
      _addLog('设置本地自定义整数: ${result.toJson()}');
    } catch (e) {
      _addLog('设置本地自定义整数失败: $e');
    }
  }

  // 标记C2C消息已读
  Future<void> _markC2CMessageAsRead() async {
    if (_receiverIDController.text.isEmpty) {
      _addLog('请输入用户ID');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().markC2CMessageAsRead(
        userID: _receiverIDController.text,
      );
      _addLog('标记C2C消息已读: ${result.toJson()}');
    } catch (e) {
      _addLog('标记C2C消息已读失败: $e');
    }
  }

  // 标记群组消息已读
  Future<void> _markGroupMessageAsRead() async {
    if (_groupIDController.text.isEmpty) {
      _addLog('请输入群组ID');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().markGroupMessageAsRead(
        groupID: _groupIDController.text,
      );
      _addLog('标记群组消息已读: ${result.toJson()}');
    } catch (e) {
      _addLog('标记群组消息已读失败: $e');
    }
  }

  // 标记所有消息已读
  Future<void> _markAllMessageAsRead() async {
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().markAllMessageAsRead();
      _addLog('标记所有消息已读: ${result.toJson()}');
    } catch (e) {
      _addLog('标记所有消息已读失败: $e');
    }
  }

  // 从本地存储删除消息
  Future<void> _deleteMessageFromLocalStorage() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().deleteMessageFromLocalStorage(
        msgID: _messageList[0].msgID ?? "",
      );
      _addLog('从本地存储删除消息: ${result.toJson()}');
    } catch (e) {
      _addLog('从本地存储删除消息失败: $e');
    }
  }

  // 删除消息
  Future<void> _deleteMessages() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().deleteMessages(
        msgIDs: [_messageList[0].msgID ?? ""],
      );
      _addLog('删除消息成功: ${result.toJson()}');
    } catch (e) {
      _addLog('删除消息失败: $e');
    }
  }

  // 向群组消息列表中添加一条消息
  Future<void> _insertGroupMessageToLocalStorage() async {
    if (_groupIDController.text.isEmpty) {
      _addLog('请输入群组ID');
      return;
    }
    if (_messageContentController.text.isEmpty) {
      _addLog('请输入消息内容');
      return;
    }
    try {
      // 先创建文本消息
      final createResult = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createTextMessage(
        text: _messageContentController.text,
      );

      if (createResult.code != 0) {
        _addLog('创建文本消息失败: ${createResult.toJson()}');
        return;
      }

      final loginUserResult = await TencentImSDKPlugin.v2TIMManager.getLoginUser();

      // 插入到本地存储
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().insertGroupMessageToLocalStorageV2(
        groupID: _groupIDController.text,
        senderID: loginUserResult.data ?? '',
        createdMsgID: createResult.data?.id ?? '',
      );
      _addLog('向群组消息列表中添加消息成功: ${result.toJson()}');
    } catch (e) {
      _addLog('向群组消息列表中添加消息失败: $e');
    }
  }

  // 向C2C消息列表中添加一条消息
  Future<void> _insertC2CMessageToLocalStorage() async {
    if (_userIDHistoryController.text.isEmpty) {
      _addLog('请输入用户ID');
      return;
    }
    if (_messageContentController.text.isEmpty) {
      _addLog('请输入消息内容');
      return;
    }
    try {
      // 先创建文本消息
      final createResult = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createTextMessage(
        text: _messageContentController.text,
      );
      
      if (createResult.code != 0) {
        _addLog('创建文本消息失败: ${createResult.toJson()}');
        return;
      }

      final loginUserResult = await TencentImSDKPlugin.v2TIMManager.getLoginUser();

      // 插入到本地存储
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().insertC2CMessageToLocalStorageV2(
        userID: _userIDHistoryController.text,
        senderID: loginUserResult.data ?? '',
        createdMsgID: createResult.data?.id ?? '',
      );
      _addLog('向C2C消息列表中添加消息成功: ${result.toJson()}');
    } catch (e) {
      _addLog('向C2C消息列表中添加消息失败: $e');
    }
  }

  // 清空单聊本地及云端的消息
  Future<void> _clearC2CHistoryMessage() async {
    if (_userIDHistoryController.text.isEmpty) {
      _addLog('请输入用户ID');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().clearC2CHistoryMessage(
        userID: _userIDHistoryController.text,
      );
      _addLog('清空单聊本地及云端的消息成功: ${result.toJson()}');
    } catch (e) {
      _addLog('清空单聊本地及云端的消息失败: $e');
    }
  }

  // 清空群聊本地及云端的消息
  Future<void> _clearGroupHistoryMessage() async {
    if (_groupIDController.text.isEmpty) {
      _addLog('请输入群组ID');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().clearGroupHistoryMessage(
        groupID: _groupIDController.text,
      );
      _addLog('清空群聊本地及云端的消息成功: ${result.toJson()}');
    } catch (e) {
      _addLog('清空群聊本地及云端的消息失败: $e');
    }
  }

  // 搜索本地消息
  Future<void> _searchLocalMessages() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      final searchParam = V2TimMessageSearchParam(
        keywordList: [_messageList[0].msgID ?? ""],
        type: V2TIMKeywordListMatchType.KEYWORD_LIST_MATCH_TYPE_AND,
        messageTypeList: [MessageElemType.V2TIM_ELEM_TYPE_TEXT],
        searchTimePosition: 0,
        searchTimePeriod: 24 * 60 * 60, // 24小时
        pageSize: 20,
        pageIndex: 0,
      );
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().searchLocalMessages(
        searchParam: searchParam,
      );
      _addLog('搜索本地消息成功: ${result.toJson()}');
    } catch (e) {
      _addLog('搜索本地消息失败: $e');
    }
  }

  // 发送消息已读回执
  Future<void> _sendMessageReadReceipts() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessageReadReceipts(
        messageIDList: [_messageList[0].msgID ?? ""],
      );
      _addLog('发送消息已读回执成功: ${result.toJson()}');
    } catch (e) {
      _addLog('发送消息已读回执失败: $e');
    }
  }

  // 获取消息已读回执
  Future<void> _getMessageReadReceipts() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().getMessageReadReceipts(
        messageIDList: [_messageList[0].msgID ?? ""],
      );
      _addLog('获取消息已读回执成功: ${result.toJson()}');
    } catch (e) {
      _addLog('获取消息已读回执失败: $e');
    }
  }

  // 获取群消息已读群成员列表
  Future<void> _getGroupMessageReadMemberList() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().getGroupMessageReadMemberList(
        messageID: _messageList[0].msgID ?? "",
        filter: GetGroupMessageReadMemberListFilter.V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_READ,
        nextSeq: 0,
        count: 100,
      );
      _addLog('获取群消息已读群成员列表成功: ${result.toJson()}');
    } catch (e) {
      _addLog('获取群消息已读群成员列表失败: $e');
    }
  }

  // 根据 messageID 查询指定会话中的本地消息
  Future<void> _findMessages() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().findMessages(
        messageIDList: [_messageList[0].msgID ?? ""],
      );
      _addLog('查询本地消息成功: ${result.toJson()}');
    } catch (e) {
      _addLog('查询本地消息失败: $e');
    }
  }

  // 设置消息扩展
  Future<void> _setMessageExtensions() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      final extensions = [
        V2TimMessageExtension(
          extensionKey: "key1",
          extensionValue: "value1",
        ),
      ];
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().setMessageExtensions(
        msgID: _messageList[0].msgID ?? "",
        extensions: extensions,
      );
      _addLog('设置消息扩展: ${result.toJson()}');
    } catch (e) {
      _addLog('设置消息扩展失败: $e');
    }
  }

  // 获取消息扩展
  Future<void> _getMessageExtensions() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().getMessageExtensions(
        msgID: _messageList[0].msgID ?? "",
      );
      _addLog('获取消息扩展: ${result.toJson()}');
    } catch (e) {
      _addLog('获取消息扩展失败: $e');
    }
  }

  // 删除消息扩展
  Future<void> _deleteMessageExtensions() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().deleteMessageExtensions(
        msgID: _messageList[0].msgID ?? "",
        keys: ["key1"],
      );
      _addLog('删除消息扩展: ${result.toJson()}');
    } catch (e) {
      _addLog('删除消息扩展失败: $e');
    }
  }

  // 消息变更
  Future<void> _modifyMessage() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      final message = _messageList[0];
      message.cloudCustomData = "modified data";
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().modifyMessage(
        message: message,
      );
      _addLog('消息变更: ${result.toJson()}');
    } catch (e) {
      _addLog('消息变更失败: $e');
    }
  }

  // 获取多媒体消息URL
  Future<void> _getMessageOnlineUrl() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().getMessageOnlineUrl(
        msgID: _messageList[0].msgID ?? "",
      );
      _addLog('获取多媒体消息URL成功: ${result.toJson()}');
    } catch (e) {
      _addLog('获取多媒体消息URL失败: $e');
    }
  }

  // 下载多媒体消息
  Future<void> _downloadMessage() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().downloadMessage(
        msgID: _messageList[0].msgID ?? "",
        messageType: MessageElemType.V2TIM_ELEM_TYPE_IMAGE,
        imageType: 0,
        isSnapshot: false,
      );
      _addLog('下载多媒体消息成功: ${result.toJson()}');
    } catch (e) {
      _addLog('下载多媒体消息失败: $e');
    }
  }

  // 翻译文本
  Future<void> _translateText() async {
    if (_messageContentController.text.isEmpty) {
      _addLog('请输入要翻译的文本');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().translateText(
        texts: [_messageContentController.text],
        targetLanguage: "en",
        sourceLanguage: "zh",
      );
      _addLog('翻译文本: ${result.toJson()}');
    } catch (e) {
      _addLog('翻译文本失败: $e');
    }
  }

  // 搜索云端消息
  Future<void> _searchCloudMessages() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      final searchParam = V2TimMessageSearchParam(
        keywordList: ["测试"],
        type: V2TIMKeywordListMatchType.KEYWORD_LIST_MATCH_TYPE_AND,
        messageTypeList: [MessageElemType.V2TIM_ELEM_TYPE_TEXT],
        searchTimePosition: 0,
        searchTimePeriod: 24 * 60 * 60, // 24小时
        pageSize: 20,
        pageIndex: 0,
        searchCount: 10,
      );
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().searchCloudMessages(
        searchParam: searchParam,
      );
      _addLog('搜索云端消息成功: ${result.toJson()}');
    } catch (e) {
      _addLog('搜索云端消息失败: $e');
    }
  }

  // 添加消息回应
  Future<void> _addMessageReaction() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().addMessageReaction(
        msgID: _messageList[0].msgID ?? "",
        reactionID: "👍", // 使用默认表情作为回应
      );
      _addLog('添加消息回应: ${result.toJson()}');
    } catch (e) {
      _addLog('添加消息回应失败: $e');
    }
  }

  // 移除消息回应
  Future<void> _removeMessageReaction() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().removeMessageReaction(
        msgID: _messageList[0].msgID ?? "",
        reactionID: "👍", // 使用默认表情作为回应
      );
      _addLog('移除消息回应: ${result.toJson()}');
    } catch (e) {
      _addLog('移除消息回应失败: $e');
    }
  }

  // 获取消息回应
  Future<void> _getMessageReactions() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().getMessageReactions(
        msgIDList: [_messageList[0].msgID ?? ""],
        maxUserCountPerReaction: 10,
      );
      _addLog('获取消息回应: ${result.toJson()}');
    } catch (e) {
      _addLog('获取消息回应失败: $e');
    }
  }

  // 获取消息回应的所有用户列表
  Future<void> _getAllUserListOfMessageReaction() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().getAllUserListOfMessageReaction(
        msgID: _messageList[0].msgID ?? "",
        reactionID: "👍", // 使用默认表情作为回应
        nextSeq: 0,
        count: 10,
      );
      _addLog('获取消息回应的所有用户列表成功: ${result.toJson()}');
    } catch (e) {
      _addLog('获取消息回应的所有用户列表失败: $e');
    }
  }

  // 语音转文本
  Future<void> _convertVoiceToText() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().convertVoiceToText(
        msgID: _messageList[0].msgID ?? "",
        language: "zh", // 默认使用中文
      );
      _addLog('语音转文本成功: ${result.toJson()}');
    } catch (e) {
      _addLog('语音转文本失败: $e');
    }
  }

  // 置顶群消息
  Future<void> _pinGroupMessage() async {
    if (_messageList.isEmpty) {
      _addLog('请先获取消息历史');
      return;
    }
    if (_groupIDController.text.isEmpty) {
      _addLog('请输入群组ID');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().pinGroupMessage(
        msgID: _messageList[0].msgID ?? "",
        groupID: _groupIDController.text,
        isPinned: true, // 默认置顶
      );
      _addLog('置顶群消息: ${result.toJson()}');
    } catch (e) {
      _addLog('置顶群消息失败: $e');
    }
  }

  // 获取置顶群消息列表
  Future<void> _getPinnedGroupMessageList() async {
    if (_groupIDController.text.isEmpty) {
      _addLog('请输入群组ID');
      return;
    }
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getMessageManager().getPinnedGroupMessageList(
        groupID: _groupIDController.text,
      );
      _addLog('获取置顶群消息列表成功: ${result.toJson()}');
    } catch (e) {
      _addLog('获取置顶群消息列表失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputFields = [
      // 接收者ID和群组ID输入框
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('接收者ID:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _receiverIDController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入接收者ID',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('群组ID:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _groupIDController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入群组ID',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      
      // 消息内容和消息ID输入框
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('消息内容:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _messageContentController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入消息内容',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('消息ID:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _messageIDController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入消息ID',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      
      // 自定义数据和会话ID输入框
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('自定义数据:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _customDataController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入自定义数据',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('会话ID:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _conversationIDController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入会话ID',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      
      // 表情索引和表情数据输入框
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('表情索引:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _faceIndexController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入表情索引',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('表情数据:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _faceDataController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入表情数据',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      
      // 位置描述和经度输入框
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('位置描述:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _locationDescController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入位置描述',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('经度:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _locationLongitudeController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入经度',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      
      // 纬度和获取数量输入框
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('纬度:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _locationLatitudeController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入纬度',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('获取数量:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _countHistoryController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '默认20',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      
      // 最后消息ID和最后消息时间输入框
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('最后消息ID:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _lastMsgIDHistoryController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入最后一条消息ID(可选)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('最后消息时间:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _lastMsgTimeHistoryController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入最后一条消息时间戳(可选)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      
      // 用户ID和群组ID输入框
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('用户ID:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _userIDHistoryController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入用户ID(可选)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('群组ID:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _groupIDHistoryController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入群组ID(可选)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      
      // 最后序号和消息类型输入框
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('最后序号:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _lastMsgSeqHistoryController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入最后消息序号(可选)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('消息类型:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _messageTypeListHistoryController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入消息类型列表，用逗号分隔(可选)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      
      // 序号列表和开始时间输入框
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('序号列表:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _messageSeqListHistoryController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入消息序号列表，用逗号分隔(可选)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('开始时间:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _timeBeginHistoryController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入开始时间戳(可选)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      
      // 时间范围和视频时长输入框
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('时间范围:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _timePeriodHistoryController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入时间范围(可选)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('视频时长:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _videoDurationController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入视频时长(秒)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      
      // 语音时长和文件名输入框
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('语音时长:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _soundDurationController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入语音时长(秒)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('文件名:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _fileNameController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入文件名',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      
      // 本地自定义数据和本地自定义整数输入框
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('本地自定义数据:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _localCustomDataController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入本地自定义数据',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('本地自定义整数:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _localCustomIntController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '请输入本地自定义整数',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      
      // 消息接收选项下拉框
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('消息接收选项:', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 30,
                  child: DropdownButtonFormField<ReceiveMsgOptEnum>(
                    value: _receiveMessageOpt,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    items: ReceiveMsgOptEnum.values.map((ReceiveMsgOptEnum opt) {
                      return DropdownMenuItem<ReceiveMsgOptEnum>(
                        value: opt,
                        child: Text(
                          opt == ReceiveMsgOptEnum.V2TIM_RECEIVE_MESSAGE ? '接收消息' :
                          opt == ReceiveMsgOptEnum.V2TIM_NOT_RECEIVE_MESSAGE ? '不接收消息' :
                          opt == ReceiveMsgOptEnum.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE ? '接收但不提醒' :
                          opt == ReceiveMsgOptEnum.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE_EXCEPT_AT ? '接收但不提醒(除@消息)' :
                          '不接收消息(除@消息)',
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    }).toList(),
                    onChanged: (ReceiveMsgOptEnum? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _receiveMessageOpt = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ];

    final buttons = [
      // 发送消息按钮
      _buildDynamicButton('发送文本消息', _sendTextMessage),
      _buildDynamicButton('发送自定义消息', _sendCustomMessage),
      _buildDynamicButton('发送表情消息', _sendFaceMessage),
      _buildDynamicButton('发送图片消息', _sendImageMessage),
      _buildDynamicButton('发送视频消息', _sendVideoMessage),
      _buildDynamicButton('发送语音消息', _sendSoundMessage),
      _buildDynamicButton('发送文件消息', _sendFileMessage),
      _buildDynamicButton('发送位置消息', _sendLocationMessage),
      _buildDynamicButton('发送合并消息', _sendMergerMessage),
      _buildDynamicButton('发送转发消息', _sendForwardMessage),
      _buildDynamicButton('发送@消息', _sendTextAtMessage),
      _buildDynamicButton('获取消息历史', _getMessageHistory),
      _buildDynamicButton('撤回消息', _revokeMessage),
      _buildDynamicButton('下载合并消息', _downloadMergerMessage),
      _buildDynamicButton('设置C2C消息接收选项', _setC2CReceiveMessageOpt),
      _buildDynamicButton('获取C2C消息接收选项', _getC2CReceiveMessageOpt),
      _buildDynamicButton('设置群组消息接收选项', _setGroupReceiveMessageOpt),
      _buildDynamicButton('设置全局消息接收选项', _setAllReceiveMessageOpt),
      _buildDynamicButton('设置全局消息接收选项(带时间戳)', _setAllReceiveMessageOptWithTimestamp),
      _buildDynamicButton('获取全局消息接收选项', _getAllReceiveMessageOpt),
      _buildDynamicButton('设置本地自定义数据', _setLocalCustomData),
      _buildDynamicButton('设置本地自定义整数', _setLocalCustomInt),
      _buildDynamicButton('标记C2C消息已读', _markC2CMessageAsRead),
      _buildDynamicButton('标记群组消息已读', _markGroupMessageAsRead),
      _buildDynamicButton('标记所有消息已读', _markAllMessageAsRead),
      _buildDynamicButton('从本地存储删除消息', _deleteMessageFromLocalStorage),
      _buildDynamicButton('删除消息', _deleteMessages),
      _buildDynamicButton('插入本地群组消息', _insertGroupMessageToLocalStorage),
      _buildDynamicButton('插入本地C2C消息', _insertC2CMessageToLocalStorage),
      _buildDynamicButton('清空单聊本地及云端的消息', _clearC2CHistoryMessage),
      _buildDynamicButton('清空群聊本地及云端的消息', _clearGroupHistoryMessage),
      _buildDynamicButton('搜索本地消息', _searchLocalMessages),
      _buildDynamicButton('搜索云端消息', _searchCloudMessages),
      _buildDynamicButton('发送消息已读回执', _sendMessageReadReceipts),
      _buildDynamicButton('获取消息已读回执', _getMessageReadReceipts),
      _buildDynamicButton('获取群消息已读群成员列表', _getGroupMessageReadMemberList),
      _buildDynamicButton('查询本地消息', _findMessages),
      _buildDynamicButton('设置消息扩展', _setMessageExtensions),
      _buildDynamicButton('获取消息扩展', _getMessageExtensions),
      _buildDynamicButton('删除消息扩展', _deleteMessageExtensions),
      _buildDynamicButton('消息变更', _modifyMessage),
      _buildDynamicButton('获取多媒体消息URL', _getMessageOnlineUrl),
      _buildDynamicButton('下载多媒体消息', _downloadMessage),
      _buildDynamicButton('添加消息回应', _addMessageReaction),
      _buildDynamicButton('移除消息回应', _removeMessageReaction),
      _buildDynamicButton('获取消息回应', _getMessageReactions),
      _buildDynamicButton('获取消息回应的所有用户列表', _getAllUserListOfMessageReaction),
      _buildDynamicButton('翻译文本', _translateText),
      _buildDynamicButton('语音转文本', _convertVoiceToText),
      _buildDynamicButton('置顶群消息', _pinGroupMessage),
      _buildDynamicButton('获取置顶群消息列表', _getPinnedGroupMessageList),
    ];

    return BaseAPITest(
      title: '消息管理',
      inputFields: inputFields,
      buttons: buttons,
      onClearLog: _clearLog,
    );
  }

  Widget _buildDynamicButton(String text, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
          minimumSize: Size(text.length * 6.0 + 12.0, 30.0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          textStyle: const TextStyle(fontSize: 12.0),
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        child: Text(text),
      ),
    );
  }

  @override
  void dispose() {
    _receiverIDController.dispose();
    _groupIDController.dispose();
    _messageContentController.dispose();
    _messageIDController.dispose();
    _customDataController.dispose();
    _messageTypeController.dispose();
    _conversationIDController.dispose();
    _countHistoryController.dispose();
    _lastMsgIDHistoryController.dispose();
    _lastMsgTimeHistoryController.dispose();
    _userIDHistoryController.dispose();
    _groupIDHistoryController.dispose();
    _lastMsgSeqHistoryController.dispose();
    _messageTypeListHistoryController.dispose();
    _messageSeqListHistoryController.dispose();
    _timeBeginHistoryController.dispose();
    _timePeriodHistoryController.dispose();
    
    // 释放新添加的控制器
    _faceIndexController.dispose();
    _faceDataController.dispose();
    _locationDescController.dispose();
    _locationLongitudeController.dispose();
    _locationLatitudeController.dispose();
    
    // 释放媒体消息相关控制器
    _videoDurationController.dispose();
    _soundDurationController.dispose();
    _fileNameController.dispose();

    // 释放合并消息和转发消息相关控制器
    _mergerMsgIDListController.dispose();
    _forwardMsgIDListController.dispose();

    // 释放@消息相关控制器
    _atUserIDListController.dispose();
    _atTextController.dispose();

    // 释放本地自定义数据和整数相关控制器
    _localCustomDataController.dispose();
    _localCustomIntController.dispose();

    super.dispose();
  }
} 