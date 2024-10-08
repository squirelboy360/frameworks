package com.example.directnative

import android.app.Activity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import org.json.JSONObject

class DNRenderer(private val activity: Activity) {
    private lateinit var rootView: ViewGroup

    fun initialize() {
        rootView = LinearLayout(activity).apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            orientation = LinearLayout.VERTICAL
        }
        activity.setContentView(rootView)
    }

    fun render(viewDescription: JSONObject) {
        rootView.removeAllViews()
        addViewToParent(viewDescription, rootView)
    }

    private fun addViewToParent(viewDescription: JSONObject, parent: ViewGroup) {
        when (viewDescription.getString("type")) {
            "view" -> {
                val layout = LinearLayout(activity).apply {
                    orientation = LinearLayout.VERTICAL
                    layoutParams = ViewGroup.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.WRAP_CONTENT
                    )
                }
                applyStyle(layout, viewDescription.getJSONObject("style"))
                viewDescription.getJSONArray("children").let { children ->
                    for (i in 0 until children.length()) {
                        addViewToParent(children.getJSONObject(i), layout)
                    }
                }
                parent.addView(layout)
            }
            "text" -> {
                val textView = TextView(activity).apply {
                    text = viewDescription.getString("content")
                    layoutParams = ViewGroup.LayoutParams(
                        ViewGroup.LayoutParams.WRAP_CONTENT,
                        ViewGroup.LayoutParams.WRAP_CONTENT
                    )
                }
                applyStyle(textView, viewDescription.getJSONObject("style"))
                parent.addView(textView)
            }
            "button" -> {
                val button = Button(activity).apply {
                    text = viewDescription.getString("label")
                    layoutParams = ViewGroup.LayoutParams(
                        ViewGroup.LayoutParams.WRAP_CONTENT,
                        ViewGroup.LayoutParams.WRAP_CONTENT
                    )
                }
                applyStyle(button, viewDescription.getJSONObject("style"))
                parent.addView(button)
            }
        }
    }

    private fun applyStyle(view: View, style: JSONObject) {
        style.keys().forEach { key ->
            when (key) {
                "backgroundColor" -> view.setBackgroundColor(android.graphics.Color.parseColor(style.getString(key)))
                "color" -> (view as? TextView)?.setTextColor(android.graphics.Color.parseColor(style.getString(key)))
                "fontSize" -> (view as? TextView)?.textSize = style.getInt(key).toFloat()
                "padding" -> view.setPadding(style.getInt(key), style.getInt(key), style.getInt(key), style.getInt(key))
            }
        }
    }
}
