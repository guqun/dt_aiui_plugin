package com.zhejianglab.dt_aiui_plugin

import android.content.Context
import android.content.res.AssetManager
import android.text.TextUtils
import androidx.annotation.NonNull
import com.google.gson.Gson
import com.iflytek.aiui.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import java.io.IOException
import java.nio.charset.Charset
import java.util.logging.Logger


/** DtAiuiPlugin */
class DtAiuiPlugin: FlutterPlugin, MethodCallHandler{
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private val mLogger = Logger.getLogger(DtAiuiPlugin::channel.name)
  private var mAIUIState: Int = AIUIConstant.STATE_IDLE
  private var mAIUIAgent: AIUIAgent? = null
  private var mContext: Context? = null
  private var mEventSink: EventChannel.EventSink? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "dt_aiui_plugin")
    channel.setMethodCallHandler(this)
    mContext = flutterPluginBinding.applicationContext

    val eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "dt_aiui_plugin_event");
    eventChannel.setStreamHandler(object: EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this@DtAiuiPlugin.mEventSink = events
      }

      override fun onCancel(arguments: Any?) {
        this@DtAiuiPlugin.mEventSink = null
      }
    })

  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "initAIUIAgent") {
      val appId = call.argument<String>("appId")
      result.success(appId?.let { initAIUIAgent(it) })
    } else if (call.method == "startVoiceNlp"){
      startVoiceNlp()
//      result.success(null)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun initAIUIAgent(appId: String): Boolean {

    if (null == mAIUIAgent) {
      mLogger.info("create aiui agent")

      //创建AIUIAgent
      mAIUIAgent = AIUIAgent.createAgent(mContext, getAIUIParams(appId), mAIUIListener)
    }
    if (null == mAIUIAgent) {
      val strErrorTip = "创建 AIUI Agent 失败！"
      mLogger.info(strErrorTip)
    }
    return null != mAIUIAgent
  }
  private fun getAIUIParams(appId: String): String? {
    var params = ""
    val assetManager: AssetManager? = mContext?.getResources()?.getAssets()
    if (assetManager == null){
      return ""
    }
    try {
      val ins = assetManager.open("cfg/aiui_phone.cfg")
      val buffer = ByteArray(ins.available())
      ins.read(buffer)
      ins.close()
      params = String(buffer)
//      val cfg = JSON.parseObject(params, CFG::class.java)
//      cfg.login.appid = appId
//      params = JSON.toJSONString(cfg)
      val cfg = Gson().fromJson(params, CFG::class.java)
      cfg.login.appid = appId
      params = Gson().toJson(cfg)
    } catch (e: IOException) {
      e.printStackTrace()
    }
    return params
  }
  //开始录音
  private fun startVoiceNlp() {
    mLogger.info("start voice nlp")

    // 先发送唤醒消息，改变AIUI内部状态，只有唤醒状态才能接收语音输入
    // 默认为oneshot 模式，即一次唤醒后就进入休眠，如果语音唤醒后，需要进行文本语义，请将改段逻辑copy至startTextNlp()开头处
    if (AIUIConstant.STATE_WORKING !== this.mAIUIState) {
      val wakeupMsg = AIUIMessage(AIUIConstant.CMD_WAKEUP, 0, 0, "", null)
      mAIUIAgent?.sendMessage(wakeupMsg)
    }

    // 打开AIUI内部录音机，开始录音
    val params = "sample_rate=16000,data_type=audio"
    val writeMsg = AIUIMessage(AIUIConstant.CMD_START_RECORD, 0, 0, params, null)
    mAIUIAgent?.sendMessage(writeMsg)
  }

  //AIUI事件监听器
  private val mAIUIListener: AIUIListener = object : AIUIListener {
    override fun onEvent(event: AIUIEvent) {
      when (event.eventType) {
        AIUIConstant.EVENT_WAKEUP -> {
          //唤醒事件
          mLogger.info("on event: " + event.eventType)
          this@DtAiuiPlugin.mEventSink?.success(getResultJson(event.eventType));

        }
        AIUIConstant.EVENT_RESULT -> {

          //结果事件
          mLogger.info("on event: " + event.eventType)
          try {

            val bizParamJson = JSONObject(event.info)
            val data: JSONObject = bizParamJson.getJSONArray("data").getJSONObject(0)
            val params = data.getJSONObject("params")
            val content = data.getJSONArray("content").getJSONObject(0)

            if (content.has("cnt_id")) {
              val cnt_id = content.getString("cnt_id")
              val cntJson = JSONObject(event.data.getByteArray(cnt_id)?.let { String(it, Charset.forName("utf-8")) })
              val sub = params.optString("sub")
              val result = cntJson.optJSONObject("intent")
              this@DtAiuiPlugin.mEventSink?.success(getResultJson(event.eventType, result.toString()));

              if ("nlp" == sub && result.length() > 2) {
                // 解析得到语义结果
                var str = ""
                //在线语义结果
                if (result.optInt("rc") == 0) {
                  val answer = result.optJSONObject("answer")
                  if (answer != null) {
                    str = answer.optString("text")
//                    this@DtAiuiPlugin.mEventSink?.success(getResultJson(event.eventType, str));

                  }
                } else {
                  str = "rc4，无法识别"
                }
                if (!TextUtils.isEmpty(str)) {
                  // TODO by niuqun

                }
              }
            }
          } catch (e: Throwable) {
            e.printStackTrace()
            mLogger.info(e.message)
          }
        }
        AIUIConstant.EVENT_ERROR -> {

          //错误事件
          mLogger.info("on event: " + event.eventType)
          this@DtAiuiPlugin.mEventSink?.success(getResultJson(event.eventType));

        }
        AIUIConstant.EVENT_VAD -> {

          //vad事件
          if (AIUIConstant.VAD_BOS === event.arg1) {
            //找到语音前端点
            // TODO by niuqun
            this@DtAiuiPlugin.mEventSink?.success(getResultJson(event.eventType * 10 + AIUIConstant.VAD_BOS));

          } else if (AIUIConstant.VAD_EOS === event.arg1) {
            //找到语音后端点
            // TODO by niuqun
            this@DtAiuiPlugin.mEventSink?.success(getResultJson(event.eventType * 10 + AIUIConstant.VAD_EOS));

          } else {
            // TODO by niuqun
          }
        }
        AIUIConstant.EVENT_START_RECORD -> {
          this@DtAiuiPlugin.mEventSink?.success(getResultJson(event.eventType));

          //开始录音事件
          mLogger.info("on event: " + event.eventType)
        }
        AIUIConstant.EVENT_STOP_RECORD -> {
          this@DtAiuiPlugin.mEventSink?.success(getResultJson(event.eventType));

          //停止录音事件
          mLogger.info("on event: " + event.eventType)
        }
        AIUIConstant.EVENT_STATE -> {
          // 状态事件
          mAIUIState = event.arg1
          if (AIUIConstant.STATE_IDLE === mAIUIState) {
            // 闲置状态，AIUI未开启
            this@DtAiuiPlugin.mEventSink?.success(getResultJson(event.eventType * 10 + AIUIConstant.STATE_IDLE));

          } else if (AIUIConstant.STATE_READY === mAIUIState) {
            // AIUI已就绪，等待唤醒
            this@DtAiuiPlugin.mEventSink?.success(getResultJson(event.eventType * 10 + AIUIConstant.STATE_READY));

          } else if (AIUIConstant.STATE_WORKING === mAIUIState) {
            // AIUI工作中，可进行交互
            this@DtAiuiPlugin.mEventSink?.success(getResultJson(event.eventType * 10 + AIUIConstant.STATE_WORKING));

          }
        }
        else -> {
        }
      }
    }
  }

  private fun getResultJson(code: Int, data: String = ""): String{
    return "{\"code\": " + code + ", \"data\":\"" + data + "\"}"
  }
}
