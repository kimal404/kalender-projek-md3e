package com.example.quest_kalender

import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "quest_kalender/sound"
    private var mediaPlayer: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "playPreview" -> {
                        val soundId = call.argument<String>("soundId") ?: "default"
                        playSoundPreview(soundId)
                        result.success(true)
                    }
                    "stopPreview" -> {
                        stopCurrentSound()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun stopCurrentSound() {
        try {
            mediaPlayer?.let { player ->
                if (player.isPlaying) {
                    player.stop()
                }
                player.release()
            }
        } catch (_: Exception) {
        } finally {
            mediaPlayer = null
        }
    }

    private fun playSoundPreview(soundId: String) {
        stopCurrentSound()
        if (soundId == "silent") return

        try {
            val attrs = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()

            val resId = when (soundId) {
                "bell" -> R.raw.bell
                "chime" -> R.raw.chime
                "horn" -> R.raw.horn
                "pulse" -> R.raw.pulse
                else -> null
            }

            val player = MediaPlayer()
            player.setAudioAttributes(attrs)

            if (resId != null) {
                val afd = resources.openRawResourceFd(resId) ?: return
                player.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                afd.close()
            } else {
                // Nada sistem default perangkat
                val defaultUri: Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                    ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
                player.setDataSource(applicationContext, defaultUri)
            }

            player.setOnCompletionListener { mp ->
                mp.release()
                if (mediaPlayer === mp) {
                    mediaPlayer = null
                }
            }
            player.prepare()
            player.start()
            mediaPlayer = player
        } catch (_: Exception) {
            // Fallback ke RingtoneManager jika MediaPlayer gagal pada URI sistem tertentu
            try {
                val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                RingtoneManager.getRingtone(applicationContext, uri)?.play()
            } catch (_: Exception) {
            }
        }
    }

    override fun onDestroy() {
        stopCurrentSound()
        super.onDestroy()
    }
}
