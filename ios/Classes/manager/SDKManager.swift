//
//  SDKManager.swift
//  tencent_im_sdk_plugin
//
//  Created by xingchenhe on 2020/12/24.
//

import Foundation
import ImSDK_Plus
import Flutter

class SDKManager {
	private var apnsListener = APNSListener();
    public static var unreadCount:UInt32 = 0;

    public func doBackground(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let unreadCount = CommonUtils.getParam(call: call, result: result, param: "unreadCount") as! UInt32;
        SDKManager.unreadCount = unreadCount
        CommonUtils.resultSuccess(call: call, result: result)
    }
    public func doForeground(call: FlutterMethodCall, result: @escaping FlutterResult) {
        SDKManager.unreadCount = 0
        CommonUtils.resultSuccess(call: call, result: result)
    }

	public func setAPNSListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
		V2TIMManager.sharedInstance().setAPNSListener(apnsListener)
		CommonUtils.resultSuccess(call: call, result: result, data: "setAPNSListener is done")
	}
}
