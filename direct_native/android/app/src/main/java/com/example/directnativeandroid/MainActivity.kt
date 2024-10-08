package com.example.directnativeandroid

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    private lateinit var bridge: DNBridge

    companion object {
        init {
            System.loadLibrary("direct_native")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        bridge = DNBridge(this)
        bridge.initialize()
    }
}