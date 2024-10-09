package com.example.directnative

import android.app.Activity

class DNBridge(private val activity: Activity) {
    private val renderer = DNRenderer(activity)

    external fun initialize(): Long
    external fun render(messageSize: Int)

    fun nativeRender(uiDescription: String) {
        activity.runOnUiThread {
            renderer.render(uiDescription)
        }
    }

    companion object {
        init {
            System.loadLibrary("direct_native")
        }
    }
}