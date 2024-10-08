package com.example.directnative

import android.app.Activity
import org.json.JSONObject

class DNBridge(private val activity: Activity) {
    private val renderer = DNRenderer(activity)

    external fun initialize()
    
    fun nativeRender(uiDescription: String) {
        val jsonDescription = JSONObject(uiDescription)
        activity.runOnUiThread {
            renderer.render(jsonDescription)
        }
    }

    companion object {
        init {
            System.loadLibrary("direct_native")
        }
    }
}
