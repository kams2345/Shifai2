package com.shifai.presentation.navigation

import android.content.Intent
import android.net.Uri

/**
 * Deep Link Router — handles shifai:// URL scheme.
 * Registered in AndroidManifest.xml intent-filter.
 */
object DeepLinkRouter {

    enum class Destination {
        DASHBOARD, TRACKING, INSIGHTS, EXPORT, SETTINGS, SYNC_CONFLICT, AUTH_CALLBACK, UNKNOWN
    }

    data class RouteResult(
        val destination: Destination,
        val params: Map<String, String> = emptyMap()
    )

    /**
     * Parse incoming deep link URI and return routing info.
     * Supported URIs:
     * - shifai://dashboard
     * - shifai://tracking
     * - shifai://insights
     * - shifai://export
     * - shifai://settings
     * - shifai://sync/conflict
     * - shifai://auth/callback?token=xxx
     * - shifai://app (default → dashboard)
     */
    fun parse(uri: Uri): RouteResult {
        if (uri.scheme != "shifai") return RouteResult(Destination.UNKNOWN)

        val host = uri.host ?: ""
        val path = uri.path ?: ""

        return when (host) {
            "dashboard" -> RouteResult(Destination.DASHBOARD)
            "tracking" -> RouteResult(Destination.TRACKING)
            "insights" -> RouteResult(Destination.INSIGHTS)
            "export" -> RouteResult(Destination.EXPORT)
            "settings" -> RouteResult(Destination.SETTINGS)
            "sync" -> {
                if (path == "/conflict") RouteResult(Destination.SYNC_CONFLICT)
                else RouteResult(Destination.UNKNOWN)
            }
            "auth" -> {
                val token = uri.getQueryParameter("token")
                RouteResult(Destination.AUTH_CALLBACK, buildMap {
                    token?.let { put("token", it) }
                })
            }
            "app" -> RouteResult(Destination.DASHBOARD)
            else -> RouteResult(Destination.UNKNOWN)
        }
    }

    fun parseFromIntent(intent: Intent): RouteResult? {
        val uri = intent.data ?: return null
        return parse(uri)
    }

    /** Navigation route names matching Compose NavHost */
    fun destinationToRoute(destination: Destination): String = when (destination) {
        Destination.DASHBOARD -> "dashboard"
        Destination.TRACKING -> "tracking"
        Destination.INSIGHTS -> "insights"
        Destination.EXPORT -> "export"
        Destination.SETTINGS -> "settings"
        Destination.SYNC_CONFLICT -> "sync_conflict"
        Destination.AUTH_CALLBACK -> "dashboard"
        Destination.UNKNOWN -> "dashboard"
    }
}
