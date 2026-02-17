package com.shifai.data.cache

import android.content.Context
import java.io.File
import java.security.MessageDigest

/**
 * Image Cache — LRU memory + disk caching for chart images.
 * Mirrors iOS ImageCache.swift.
 */
class ImageCache(context: Context) {

    private val memoryCache = object : LinkedHashMap<String, ByteArray>(50, 0.75f, true) {
        private val maxMemorySize = 10_000_000  // 10 MB
        private var currentSize = 0

        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, ByteArray>?): Boolean {
            return currentSize > maxMemorySize
        }

        override fun put(key: String, value: ByteArray): ByteArray? {
            currentSize += value.size
            return super.put(key, value)
        }
    }

    private val cacheDir = File(context.cacheDir, "shifai_images").also { it.mkdirs() }
    private val maxDiskSize = 50_000_000L  // 50 MB

    // ─── Read ───

    fun get(key: String): ByteArray? {
        memoryCache[key]?.let { return it }

        val file = File(cacheDir, key.md5())
        if (file.exists()) {
            val data = file.readBytes()
            memoryCache[key] = data
            return data
        }
        return null
    }

    // ─── Write ───

    fun set(key: String, data: ByteArray) {
        memoryCache[key] = data
        File(cacheDir, key.md5()).writeBytes(data)
    }

    // ─── Clear ───

    fun clearMemory() = memoryCache.clear()

    fun clearDisk() {
        cacheDir.deleteRecursively()
        cacheDir.mkdirs()
    }

    fun clearAll() {
        clearMemory()
        clearDisk()
    }

    // ─── Stats ───

    val diskSize: Long
        get() = cacheDir.walkTopDown().filter { it.isFile }.sumOf { it.length() }

    private fun String.md5(): String {
        val digest = MessageDigest.getInstance("MD5")
        return digest.digest(toByteArray()).joinToString("") { "%02x".format(it) }
    }
}
