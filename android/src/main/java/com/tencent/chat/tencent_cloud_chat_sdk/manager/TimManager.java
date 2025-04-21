package com.tencent.chat.tencent_cloud_chat_sdk.manager;

import android.content.Context;
import android.util.Log;
import com.tencent.imsdk.common.NetworkInfoCenter;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import org.json.JSONObject;

public class TimManager {
    public void getNetworkInfo(MethodCall methodCall, final MethodChannel.Result result) {
        HashMap<String, Object> networkInfo = new HashMap<String, Object>();
        networkInfo.put("networkType", NetworkInfoCenter.getInstance().getNetworkType());
        networkInfo.put("ipType", NetworkInfoCenter.getInstance().getIPType());
        networkInfo.put("networkId", NetworkInfoCenter.getInstance().getNetworkID());
        networkInfo.put("wifiNetworkHandle", NetworkInfoCenter.getInstance().getWifiNetworkHandle());
        networkInfo.put("xgNetworkHandle", NetworkInfoCenter.getInstance().getXgNetworkHandle());
        networkInfo.put("initializeCostTime", NetworkInfoCenter.getInstance().getInitializeCostTime());
        networkInfo.put("networkConnected", NetworkInfoCenter.getInstance().isNetworkConnected());

        result.success(networkInfo);
    }
}
