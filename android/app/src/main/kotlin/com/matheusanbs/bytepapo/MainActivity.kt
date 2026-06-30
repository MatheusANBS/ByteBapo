package com.matheusanbs.bytepapo

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.util.UUID

class MainActivity : FlutterActivity() {
    private var pendingAvatarResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "byte_papo/avatar_picker"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickAvatar" -> pickAvatar(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun pickAvatar(result: MethodChannel.Result) {
        if (pendingAvatarResult != null) {
            result.error("busy", "An avatar picker is already open.", null)
            return
        }
        pendingAvatarResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "image/*"
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        startActivityForResult(intent, AVATAR_REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != AVATAR_REQUEST_CODE) {
            return
        }
        val result = pendingAvatarResult ?: return
        pendingAvatarResult = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return
        }
        try {
            result.success(copyAvatarToAppFiles(uri))
        } catch (error: Exception) {
            result.error("copy_failed", error.message, null)
        }
    }

    private fun copyAvatarToAppFiles(uri: Uri): String {
        val avatarsDir = File(filesDir, "avatars")
        avatarsDir.mkdirs()
        val extension = when (contentResolver.getType(uri)) {
            "image/png" -> "png"
            "image/webp" -> "webp"
            else -> "jpg"
        }
        val target = File(avatarsDir, "${UUID.randomUUID()}.$extension")
        contentResolver.openInputStream(uri).use { input ->
            if (input == null) {
                throw IllegalStateException("Could not open selected image.")
            }
            FileOutputStream(target).use { output ->
                input.copyTo(output)
            }
        }
        return target.absolutePath
    }

    companion object {
        private const val AVATAR_REQUEST_CODE = 4201
    }
}
