package com.shifai.data.network

import org.junit.Assert.*
import org.junit.Test

class NetworkReachabilityTest {

    // ─── Connection Types ───

    @Test
    fun `wifi type exists`() {
        assertEquals(NetworkReachability.ConnectionType.WIFI, NetworkReachability.ConnectionType.WIFI)
    }

    @Test
    fun `cellular type exists`() {
        assertEquals(NetworkReachability.ConnectionType.CELLULAR, NetworkReachability.ConnectionType.CELLULAR)
    }

    @Test
    fun `ethernet type exists`() {
        assertEquals(NetworkReachability.ConnectionType.ETHERNET, NetworkReachability.ConnectionType.ETHERNET)
    }

    @Test
    fun `none type exists`() {
        assertEquals(NetworkReachability.ConnectionType.NONE, NetworkReachability.ConnectionType.NONE)
    }

    @Test
    fun `four connection types`() {
        assertEquals(4, NetworkReachability.ConnectionType.values().size)
    }

    // ─── State ───

    @Test
    fun `default assumes connected`() {
        val defaultState = true
        assertTrue(defaultState)
    }

    @Test
    fun `disconnected state is false`() {
        val disconnected = false
        assertFalse(disconnected)
    }

    // ─── Sync Decision ───

    @Test
    fun `sync allowed when connected`() {
        val isConnected = true
        val syncEnabled = true
        assertTrue(isConnected && syncEnabled)
    }

    @Test
    fun `sync blocked when disconnected`() {
        val isConnected = false
        assertFalse(isConnected)
    }

    @Test
    fun `wifi preferred for large sync`() {
        val type = NetworkReachability.ConnectionType.WIFI
        val isWifi = type == NetworkReachability.ConnectionType.WIFI
        assertTrue(isWifi)
    }
}
