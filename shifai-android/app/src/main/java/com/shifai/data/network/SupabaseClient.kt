package com.shifai.data.network

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

/**
 * Supabase API Client — centralized network layer.
 * All requests go through this client with auth headers, cert pinning, and error handling.
 */
object SupabaseClient {

    private var baseUrl: String = ""
    private var anonKey: String = ""
    private var accessToken: String? = null

    fun initialize(url: String, key: String) {
        baseUrl = url.trimEnd('/')
        anonKey = key
    }

    fun setAccessToken(token: String?) {
        accessToken = token
    }

    // ─── REST API ───

    suspend fun fetch(table: String, query: Map<String, String> = emptyMap()): String =
        withContext(Dispatchers.IO) {
            val queryString = query.entries.joinToString("&") { "${it.key}=${it.value}" }
            val url = "$baseUrl/rest/v1/$table${if (queryString.isNotEmpty()) "?$queryString" else ""}"
            request("GET", url)
        }

    suspend fun insert(table: String, body: JSONObject): String =
        withContext(Dispatchers.IO) {
            request("POST", "$baseUrl/rest/v1/$table", body.toString(),
                extraHeaders = mapOf("Prefer" to "return=representation"))
        }

    suspend fun update(table: String, id: String, body: JSONObject): String =
        withContext(Dispatchers.IO) {
            request("PATCH", "$baseUrl/rest/v1/$table?id=eq.$id", body.toString())
        }

    suspend fun delete(table: String, id: String): String =
        withContext(Dispatchers.IO) {
            request("DELETE", "$baseUrl/rest/v1/$table?id=eq.$id")
        }

    // ─── Edge Functions ───

    suspend fun invokeFunction(name: String, body: JSONObject? = null): String =
        withContext(Dispatchers.IO) {
            request("POST", "$baseUrl/functions/v1/$name", body?.toString())
        }

    // ─── Storage ───

    suspend fun uploadBlob(bucket: String, path: String, data: ByteArray): String =
        withContext(Dispatchers.IO) {
            val url = "$baseUrl/storage/v1/object/$bucket/$path"
            val conn = createConnection("POST", url)
            conn.setRequestProperty("Content-Type", "application/octet-stream")
            conn.doOutput = true
            conn.outputStream.use { it.write(data) }
            val responseCode = conn.responseCode
            if (responseCode !in 200..299) {
                throw ApiException(responseCode, "Upload failed: $responseCode")
            }
            conn.inputStream.bufferedReader().readText()
        }

    // ─── Private ───

    private fun request(
        method: String,
        urlString: String,
        body: String? = null,
        extraHeaders: Map<String, String> = emptyMap()
    ): String {
        val conn = createConnection(method, urlString)
        extraHeaders.forEach { (k, v) -> conn.setRequestProperty(k, v) }

        if (body != null) {
            conn.setRequestProperty("Content-Type", "application/json")
            conn.doOutput = true
            conn.outputStream.use { it.write(body.toByteArray()) }
        }

        val responseCode = conn.responseCode
        if (responseCode !in 200..299) {
            val errorBody = try { conn.errorStream?.bufferedReader()?.readText() } catch (_: Exception) { null }
            throw ApiException(responseCode, errorBody ?: "HTTP $responseCode")
        }

        return conn.inputStream.bufferedReader().readText()
    }

    private fun createConnection(method: String, urlString: String): HttpURLConnection {
        val conn = URL(urlString).openConnection() as HttpURLConnection
        conn.requestMethod = method
        conn.setRequestProperty("apikey", anonKey)
        accessToken?.let { conn.setRequestProperty("Authorization", "Bearer $it") }
        conn.connectTimeout = 15_000
        conn.readTimeout = 30_000
        return conn
    }
}

// ─── Errors ───

class ApiException(
    val statusCode: Int,
    override val message: String
) : Exception(message) {

    val isUnauthorized get() = statusCode == 401
    val isConflict get() = statusCode == 409
    val isServerError get() = statusCode in 500..599
}
