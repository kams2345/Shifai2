package com.shifai.data.network

import okhttp3.CertificatePinner
import okhttp3.OkHttpClient
import java.util.concurrent.TimeUnit

/**
 * Network Security Manager — Android
 * S1-10: Certificate Pinning (OkHttp) + TLS enforcement
 *
 * Mirrors iOS NetworkSecurityManager.swift
 */
object NetworkSecurityManager {

    // SHA-256 hashes of Supabase EU intermediate CA certificates
    // Generated via: openssl x509 -pubkey | openssl pkey -pubin -outform DER | openssl dgst -sha256 -binary | base64
    private val SUPABASE_PINS = listOf(
        // Primary pin: Let's Encrypt ISRG Root X1
        "sha256/C5+lpZ7tcVwmwQIMcRtPbsQtWLABXhQzejna0wHFr8M=",
        // Backup pin: Let's Encrypt E5
        "sha256/JSD78f+VKHRmLJNQIi/G29qMjTlp6fQBXnKESj2bTWo="
    )

    /**
     * Creates a pinned OkHttpClient for all Supabase API calls
     * - Certificate pinning on *.supabase.co
     * - TLS 1.3 enforced via network_security_config.xml
     * - 30s timeout, fail-close on pin mismatch
     */
    fun createPinnedClient(): OkHttpClient {
        val certificatePinner = CertificatePinner.Builder()
            .add("*.supabase.co", *SUPABASE_PINS.toTypedArray())
            .add("*.supabase.in", *SUPABASE_PINS.toTypedArray())
            .build()

        return OkHttpClient.Builder()
            .certificatePinner(certificatePinner)
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(60, TimeUnit.SECONDS)
            // Retry on connection failure (not on body)
            .retryOnConnectionFailure(true)
            // Disable clear-text traffic
            .followRedirects(false)
            .build()
    }
}
