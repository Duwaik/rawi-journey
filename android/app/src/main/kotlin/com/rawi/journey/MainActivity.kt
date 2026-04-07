package com.rawi.journey

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Force the window background to navy BEFORE Flutter renders.
        // This prevents any green/white flash between the Android splash
        // and Flutter's first frame on Samsung/Android 12+ devices.
        window.setBackgroundDrawableResource(R.color.navy_bg)
        super.onCreate(savedInstanceState)
    }
}
