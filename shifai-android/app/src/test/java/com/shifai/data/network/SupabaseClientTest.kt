package com.shifai.data.network

import org.junit.Assert.*
import org.junit.Before
import org.junit.Test

class SupabaseClientTest {

    @Before
    fun setUp() {
        SupabaseClient.initialize(
            url = "https://test-project.supabase.co",
            key = "test-anon-key"
        )
    }

    // ─── Initialization ───

    @Test
    fun `initialize does not throw`() {
        // Should complete without exception
        SupabaseClient.initialize("https://example.supabase.co", "key")
    }

    @Test
    fun `setAccessToken does not throw`() {
        SupabaseClient.setAccessToken("test-jwt-token")
    }

    @Test
    fun `setAccessToken null clears token`() {
        SupabaseClient.setAccessToken("token")
        SupabaseClient.setAccessToken(null)
        // No exception
    }

    // ─── ApiException ───

    @Test
    fun `ApiException 401 is unauthorized`() {
        val ex = ApiException(401, "Unauthorized")
        assertTrue(ex.isUnauthorized)
        assertFalse(ex.isConflict)
        assertFalse(ex.isServerError)
    }

    @Test
    fun `ApiException 409 is conflict`() {
        val ex = ApiException(409, "Conflict")
        assertFalse(ex.isUnauthorized)
        assertTrue(ex.isConflict)
        assertFalse(ex.isServerError)
    }

    @Test
    fun `ApiException 500 is serverError`() {
        val ex = ApiException(500, "Internal Server Error")
        assertFalse(ex.isUnauthorized)
        assertFalse(ex.isConflict)
        assertTrue(ex.isServerError)
    }

    @Test
    fun `ApiException 502 is also serverError`() {
        val ex = ApiException(502, "Bad Gateway")
        assertTrue(ex.isServerError)
    }

    @Test
    fun `ApiException 200 is not any error type`() {
        val ex = ApiException(200, "OK")
        assertFalse(ex.isUnauthorized)
        assertFalse(ex.isConflict)
        assertFalse(ex.isServerError)
    }

    @Test
    fun `ApiException message is preserved`() {
        val ex = ApiException(404, "Not Found")
        assertEquals("Not Found", ex.message)
        assertEquals(404, ex.statusCode)
    }
}
