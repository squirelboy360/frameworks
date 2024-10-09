package com.example.directnative

import android.app.Activity
import android.view.View
import android.view.ViewGroup
import android.widget.*
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

    fun render(uiDescription: String) {
        val jsonDescription = JSONObject(uiDescription)
        rootView.removeAllViews()
        addViewToParent(jsonDescription, rootView)
    }

    private fun addViewToParent(viewDescription: JSONObject, parent: ViewGroup) {
        when (viewDescription.getString("type")) {
            "view" -> renderView(viewDescription, parent)
            "text" -> renderText(viewDescription, parent)
            "button" -> renderButton(viewDescription, parent)
            "image" -> renderImage(viewDescription, parent)
        }
    }

    private fun renderView(viewDescription: JSONObject, parent: ViewGroup) {
        val layout = LinearLayout(activity).apply {
            orientation = if (viewDescription.optString("style.flexDirection") == "row")
                LinearLayout.HORIZONTAL else LinearLayout.VERTICAL
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }
        applyStyle(layout, viewDescription.optJSONObject("style"))
        viewDescription.optJSONArray("children")?.let { children ->
            for (i in 0 until children.length()) {
                addViewToParent(children.getJSONObject(i), layout)
            }
        }
        parent.addView(layout)
    }

    private fun renderText(viewDescription: JSONObject, parent: ViewGroup) {
        val textView = TextView(activity).apply {
            text = viewDescription.getString("content")
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }
        applyStyle(textView, viewDescription.optJSONObject("style"))
        parent.addView(textView)
    }

    private fun renderButton(viewDescription: JSONObject, parent: ViewGroup) {
        val button = Button(activity).apply {
            text = viewDescription.getString("label")
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }
        applyStyle(button, viewDescription.optJSONObject("style"))
        parent.addView(button)
    }

    private fun renderImage(viewDescription: JSONObject, parent: ViewGroup) {
        val imageView = ImageView(activity).apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }
        // TODO: Implement image loading
        applyStyle(imageView, viewDescription.optJSONObject("style"))
        parent.addView(imageView)
    }

    private fun applyStyle(view: View, style: JSONObject?) {
        style?.let { 
            it.keys().forEach { key ->
                when (key) {
                    "backgroundColor" -> view.setBackgroundColor(android.graphics.Color.parseColor(it.getString(key)))
                    "color" -> (view as? TextView)?.setTextColor(android.graphics.Color.parseColor(it.getString(key)))
                    "fontSize" -> (view as? TextView)?.textSize = it.getInt(key).toFloat()
                    "padding" -> view.setPadding(it.getInt(key), it.getInt(key), it.getInt(key), it.getInt(key))
                    // Add more style properties as needed
                }
            }
        }
    }
}