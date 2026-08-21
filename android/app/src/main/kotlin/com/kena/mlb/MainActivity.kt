package com.kena.mlb

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		createNotificationChannel()
	}

	private fun createNotificationChannel() {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

		val channel = NotificationChannel(
			"kena_notifications_v2",
			"Kena notifications",
			NotificationManager.IMPORTANCE_HIGH,
		).apply {
			description = "Important updates and reminders from Kena"
			enableVibration(true)
		}

		getSystemService(NotificationManager::class.java)
			?.createNotificationChannel(channel)
	}
}
