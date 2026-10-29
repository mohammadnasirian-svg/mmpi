package com.example.mmpi2_pearson_clinical

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread
import kotlin.math.exp
import kotlin.math.sin

class MainActivity: FlutterActivity() {
    private val CHANNEL = "nahira.mmpi/audio"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "playTone") {
                val freq = call.argument<Int>("freqHz") ?: 660
                val durationMs = call.argument<Int>("durationMs") ?: 70
                playPremiumChime(freq, durationMs)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun playPremiumChime(freqHz: Int, durationMs: Int) {
        thread {
            try {
                val sampleRate = 24000
                val numSamples = (sampleRate * durationMs) / 1000
                val samples = ShortArray(numSamples)
                for (i in 0 until numSamples) {
                    val t = i.toDouble() / sampleRate
                    // Smooth exponential decay envelope for a soft, luxury UI chime
                    val envelope = exp(-t * 22.0)
                    val fundamental = sin(2.0 * Math.PI * freqHz * t)
                    val harmonic = 0.35 * sin(2.0 * Math.PI * (freqHz * 1.5) * t)
                    val value = ((fundamental + harmonic) * 0.55 * envelope * Short.MAX_VALUE).toInt()
                    samples[i] = value.coerceIn(Short.MIN_VALUE.toInt(), Short.MAX_VALUE.toInt()).toShort()
                }

                val bufferSize = samples.size * 2
                val audioTrack = AudioTrack.Builder()
                    .setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_MEDIA)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
                    )
                    .setAudioFormat(
                        AudioFormat.Builder()
                            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                            .setSampleRate(sampleRate)
                            .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                            .build()
                    )
                    .setBufferSizeInBytes(bufferSize.coerceAtLeast(AudioTrack.getMinBufferSize(
                        sampleRate,
                        AudioFormat.CHANNEL_OUT_MONO,
                        AudioFormat.ENCODING_PCM_16BIT
                    )))
                    .setTransferMode(AudioTrack.MODE_STATIC)
                    .build()

                audioTrack.write(samples, 0, samples.size)
                audioTrack.play()
                Thread.sleep((durationMs + 40).toLong())
                audioTrack.release()
            } catch (_: Exception) {
            }
        }
    }
}
