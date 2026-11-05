package com.catqueens.cat_queens

import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.SoundPool
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.catqueens/sound"
    private var soundPool: SoundPool? = null
    private val soundMap = mutableMapOf<String, Int>()
    private var isMuted = false
    private var bgmPlayer: MediaPlayer? = null
    private var isMusicEnabled = true

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        initSoundPool()
        initBgm()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "play" -> {
                    val sound = call.argument<String>("sound")
                    if (!isMuted && sound != null) {
                        playSound(sound)
                    }
                    result.success(true)
                }
                "setMuted" -> {
                    isMuted = call.argument<Boolean>("muted") ?: false
                    result.success(true)
                }
                "startBgm" -> {
                    startBgm()
                    result.success(true)
                }
                "stopBgm" -> {
                    stopBgm()
                    result.success(true)
                }
                "setMusicEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: true
                    isMusicEnabled = enabled
                    if (enabled) {
                        startBgm()
                    } else {
                        pauseBgm()
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun initSoundPool() {
        val attributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_GAME)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

        soundPool = SoundPool.Builder()
            .setMaxStreams(8)
            .setAudioAttributes(attributes)
            .build()

        loadSound("tap", R.raw.sfx_tap)
        loadSound("queen", R.raw.sfx_queen)
        loadSound("meow", R.raw.sfx_meow)
        loadSound("error", R.raw.sfx_error)
        loadSound("win", R.raw.sfx_win)
        loadSound("click", R.raw.sfx_click)
    }

    private fun loadSound(key: String, resId: Int) {
        soundPool?.let { pool ->
            try {
                val id = pool.load(this, resId, 1)
                soundMap[key] = id
            } catch (_: Exception) {}
        }
    }

    private fun playSound(key: String) {
        val soundId = soundMap[key] ?: return
        soundPool?.play(soundId, 1.0f, 1.0f, 1, 0, 1.0f)
    }

    private fun initBgm() {
        try {
            if (bgmPlayer == null) {
                bgmPlayer = MediaPlayer.create(this, R.raw.bgm_cozy)?.apply {
                    isLooping = true
                    setVolume(0.45f, 0.45f)
                }
            }
            if (isMusicEnabled && bgmPlayer?.isPlaying == false) {
                bgmPlayer?.start()
            }
        } catch (_: Exception) {}
    }

    private fun startBgm() {
        if (!isMusicEnabled) return
        try {
            if (bgmPlayer == null) {
                initBgm()
            } else if (!bgmPlayer!!.isPlaying) {
                bgmPlayer?.start()
            }
        } catch (_: Exception) {}
    }

    private fun pauseBgm() {
        try {
            if (bgmPlayer?.isPlaying == true) {
                bgmPlayer?.pause()
            }
        } catch (_: Exception) {}
    }

    private fun stopBgm() {
        try {
            bgmPlayer?.stop()
            bgmPlayer?.release()
            bgmPlayer = null
        } catch (_: Exception) {}
    }

    override fun onResume() {
        super.onResume()
        if (isMusicEnabled) {
            startBgm()
        }
    }

    override fun onPause() {
        pauseBgm()
        super.onPause()
    }

    override fun onDestroy() {
        soundPool?.release()
        soundPool = null
        stopBgm()
        super.onDestroy()
    }
}
