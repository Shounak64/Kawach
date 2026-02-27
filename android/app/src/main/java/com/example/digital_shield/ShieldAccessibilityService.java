package com.example.digital_shield;

import android.accessibilityservice.AccessibilityService;
import android.view.accessibility.AccessibilityEvent;
import android.util.Log;

public class ShieldAccessibilityService extends AccessibilityService {
    @Override
    public void onAccessibilityEvent(AccessibilityEvent event) {
        if (event.getEventType() == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            String packageName = event.getPackageName() != null ? event.getPackageName().toString() : "";
            
            // Check risk score from SharedPreferences
            android.content.SharedPreferences prefs = getSharedPreferences("FlutterSharedPreferences", android.content.Context.MODE_PRIVATE);
            float riskScore = prefs.getFloat("flutter.risk_score", 0.0f);

            if (riskScore > 70.0f) {
                if (isUPIApp(packageName)) {
                    Log.w("ShieldService", "Blocking UPI App: " + packageName + " due to high risk: " + riskScore);
                    // Perform GLOBAL_ACTION_HOME to "close" the app
                    performGlobalAction(GLOBAL_ACTION_HOME);
                }
            }
        }
    }

    private boolean isUPIApp(String packageName) {
        return packageName.equals("com.google.android.apps.nbu.paisa.user") || 
               packageName.equals("com.phonepe.app") || 
               packageName.equals("com.paytm.app") ||
               packageName.equals("in.org.npci.upiapp");
    }

    @Override
    public void onInterrupt() {
    }

    @Override
    protected void onServiceConnected() {
        super.onServiceConnected();
        Log.d("ShieldService", "Accessibility Service Connected");
    }
}
