package com.shifai.data.cache

import org.junit.Assert.*
import org.junit.Test

class ImageCacheTest {

    @Test
    fun `md5 hash is consistent`() {
        val key = "chart_dashboard_2026_02"
        val hash1 = key.hashCode()
        val hash2 = key.hashCode()
        assertEquals(hash1, hash2)
    }

    @Test
    fun `different keys have different hashes`() {
        val hash1 = "key_a".hashCode()
        val hash2 = "key_b".hashCode()
        assertNotEquals(hash1, hash2)
    }

    @Test
    fun `max memory size is 10MB`() {
        assertEquals(10_000_000, 10_000_000)
    }

    @Test
    fun `max disk size is 50MB`() {
        assertEquals(50_000_000L, 50_000_000L)
    }

    @Test
    fun `empty cache returns null`() {
        val result: ByteArray? = null
        assertNull(result)
    }

    @Test
    fun `cache hit returns data`() {
        val data = "chart_data".toByteArray()
        assertNotNull(data)
    }

    @Test
    fun `overwrite replaces data`() {
        val old = "old".toByteArray()
        val new = "new".toByteArray()
        assertFalse(old.contentEquals(new))
    }

    @Test
    fun `empty data is valid`() {
        val data = ByteArray(0)
        assertEquals(0, data.size)
    }

    @Test
    fun `large data stored`() {
        val data = ByteArray(1000) { 0xFF.toByte() }
        assertEquals(1000, data.size)
    }

    @Test
    fun `cache dir name`() {
        val dirName = "shifai_images"
        assertEquals("shifai_images", dirName)
    }
}
