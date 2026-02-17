package com.shifai.data.network

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

/**
 * Network Reachability — monitors connectivity for offline-first UX.
 * Uses ConnectivityManager callbacks.
 * Mirrors iOS NetworkReachability.swift.
 */
class NetworkReachability(context: Context) {

    enum class ConnectionType { WIFI, CELLULAR, ETHERNET, NONE }

    private val connectivityManager =
        context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

    private val _isConnected = MutableStateFlow(checkCurrentState())
    val isConnected: StateFlow<Boolean> = _isConnected

    private val _connectionType = MutableStateFlow(getCurrentType())
    val connectionType: StateFlow<ConnectionType> = _connectionType

    private val callback = object : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) {
            _isConnected.value = true
            _connectionType.value = getCurrentType()
        }

        override fun onLost(network: Network) {
            _isConnected.value = false
            _connectionType.value = ConnectionType.NONE
        }

        override fun onCapabilitiesChanged(network: Network, caps: NetworkCapabilities) {
            _connectionType.value = determineType(caps)
        }
    }

    // ─── Lifecycle ───

    fun start() {
        val request = NetworkRequest.Builder()
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .build()
        connectivityManager.registerNetworkCallback(request, callback)
    }

    fun stop() {
        connectivityManager.unregisterNetworkCallback(callback)
    }

    // ─── Helpers ───

    private fun checkCurrentState(): Boolean {
        val network = connectivityManager.activeNetwork ?: return false
        val caps = connectivityManager.getNetworkCapabilities(network) ?: return false
        return caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
    }

    private fun getCurrentType(): ConnectionType {
        val network = connectivityManager.activeNetwork ?: return ConnectionType.NONE
        val caps = connectivityManager.getNetworkCapabilities(network) ?: return ConnectionType.NONE
        return determineType(caps)
    }

    private fun determineType(caps: NetworkCapabilities): ConnectionType = when {
        caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> ConnectionType.WIFI
        caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> ConnectionType.CELLULAR
        caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> ConnectionType.ETHERNET
        else -> ConnectionType.NONE
    }
}
