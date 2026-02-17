package com.shifai.presentation.navigation

import android.net.Uri
import org.junit.Assert.*
import org.junit.Test

class DeepLinkRouterTest {

    @Test
    fun `dashboard deep link routes correctly`() {
        val result = DeepLinkRouter.parse(Uri.parse("shifai://dashboard"))
        assertEquals(DeepLinkRouter.Destination.DASHBOARD, result.destination)
    }

    @Test
    fun `tracking deep link routes correctly`() {
        val result = DeepLinkRouter.parse(Uri.parse("shifai://tracking"))
        assertEquals(DeepLinkRouter.Destination.TRACKING, result.destination)
    }

    @Test
    fun `insights deep link routes correctly`() {
        val result = DeepLinkRouter.parse(Uri.parse("shifai://insights"))
        assertEquals(DeepLinkRouter.Destination.INSIGHTS, result.destination)
    }

    @Test
    fun `export deep link routes correctly`() {
        val result = DeepLinkRouter.parse(Uri.parse("shifai://export"))
        assertEquals(DeepLinkRouter.Destination.EXPORT, result.destination)
    }

    @Test
    fun `settings deep link routes correctly`() {
        val result = DeepLinkRouter.parse(Uri.parse("shifai://settings"))
        assertEquals(DeepLinkRouter.Destination.SETTINGS, result.destination)
    }

    @Test
    fun `sync conflict deep link routes correctly`() {
        val result = DeepLinkRouter.parse(Uri.parse("shifai://sync/conflict"))
        assertEquals(DeepLinkRouter.Destination.SYNC_CONFLICT, result.destination)
    }

    @Test
    fun `auth callback extracts token`() {
        val result = DeepLinkRouter.parse(Uri.parse("shifai://auth/callback?token=jwt123"))
        assertEquals(DeepLinkRouter.Destination.AUTH_CALLBACK, result.destination)
        assertEquals("jwt123", result.params["token"])
    }

    @Test
    fun `shifai app defaults to dashboard`() {
        val result = DeepLinkRouter.parse(Uri.parse("shifai://app"))
        assertEquals(DeepLinkRouter.Destination.DASHBOARD, result.destination)
    }

    @Test
    fun `unknown host returns UNKNOWN`() {
        val result = DeepLinkRouter.parse(Uri.parse("shifai://nonexistent"))
        assertEquals(DeepLinkRouter.Destination.UNKNOWN, result.destination)
    }

    @Test
    fun `wrong scheme returns UNKNOWN`() {
        val result = DeepLinkRouter.parse(Uri.parse("https://shifai.app"))
        assertEquals(DeepLinkRouter.Destination.UNKNOWN, result.destination)
    }

    @Test
    fun `destinationToRoute maps all destinations`() {
        for (dest in DeepLinkRouter.Destination.values()) {
            val route = DeepLinkRouter.destinationToRoute(dest)
            assertTrue("Route should not be empty", route.isNotEmpty())
        }
    }

    @Test
    fun `auth callback without token has empty params`() {
        val result = DeepLinkRouter.parse(Uri.parse("shifai://auth/callback"))
        assertEquals(DeepLinkRouter.Destination.AUTH_CALLBACK, result.destination)
        assertFalse(result.params.containsKey("token"))
    }
}
