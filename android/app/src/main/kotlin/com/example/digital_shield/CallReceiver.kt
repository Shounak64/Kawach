package com.example.digital_shield

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class CallReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
            val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
            if (state == TelephonyManager.EXTRA_STATE_RINGING) {
                // Incoming call
                sendCallEvent(context, "CALL_RINGING")
            } else if (state == TelephonyManager.EXTRA_STATE_OFFHOOK) {
                // Call started
                sendCallEvent(context, "CALL_STARTED")
            } else if (state == TelephonyManager.EXTRA_STATE_IDLE) {
                // Call ended
                sendCallEvent(context, "CALL_ENDED")
            }
        }
    }

    private fun sendCallEvent(context: Context, event: String) {
        // Broadcasters for local app components
        val intent = Intent("com.example.digital_shield.CALL_EVENT")
        intent.putExtra("type", event)
        context.sendBroadcast(intent)
        
        // Ensure the background service is running if it's a call start or ringing
        if (event == "CALL_STARTED" || event == "CALL_RINGING") {
           val serviceIntent = Intent(context, id.flutter.flutter_background_service.BackgroundService::class.java)
           context.startForegroundService(serviceIntent)
        }
        
        try {
            val json = org.json.JSONObject()
            json.put("action", event)
            id.flutter.flutter_background_service.FlutterBackgroundServicePlugin.servicePipe.invoke(json)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
