-- Migration 001: Initial encrypted user data schema
-- ShifAI Backend — Zero-Knowledge Architecture
-- Server stores ONLY encrypted blobs — cannot read health data

-- ============================================================
-- IMPORTANT: This is a ZERO-KNOWLEDGE server.
-- All user health data is encrypted CLIENT-SIDE before storage.
-- The server NEVER sees plaintext health data.
-- Only encrypted blobs + sync metadata are stored.
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── Encrypted User Data ───
-- Stores the full encrypted dataset blob (zero-knowledge)
CREATE TABLE IF NOT EXISTS public.encrypted_user_data (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    data_blob BYTEA NOT NULL,                    -- Full dataset encrypted AES-256-GCM
    blob_version INTEGER NOT NULL DEFAULT 1,     -- Incrementing version number
    checksum TEXT NOT NULL,                       -- SHA-256 for integrity verification
    last_device_sync TIMESTAMPTZ,                -- Last device that synced
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id)
);

-- ─── Sync Metadata ───
-- Tracks sync state per device
CREATE TABLE IF NOT EXISTS public.sync_metadata (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    device_id TEXT NOT NULL,                     -- Unique device identifier
    last_sync_at TIMESTAMPTZ,
    sync_version INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id, device_id)
);

-- ─── Row Level Security ───
-- Users can ONLY access their own data
ALTER TABLE public.encrypted_user_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sync_metadata ENABLE ROW LEVEL SECURITY;

-- RLS Policies: user can only read/write own data
CREATE POLICY "Users can view own encrypted data"
    ON public.encrypted_user_data
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own encrypted data"
    ON public.encrypted_user_data
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own encrypted data"
    ON public.encrypted_user_data
    FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own encrypted data"
    ON public.encrypted_user_data
    FOR DELETE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can view own sync metadata"
    ON public.sync_metadata
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own sync metadata"
    ON public.sync_metadata
    FOR ALL
    USING (auth.uid() = user_id);

-- ─── Updated_at trigger ───
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_encrypted_user_data_updated_at
    BEFORE UPDATE ON public.encrypted_user_data
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ─── Indexes ───
CREATE INDEX IF NOT EXISTS idx_sync_metadata_user_id
    ON public.sync_metadata(user_id);

CREATE INDEX IF NOT EXISTS idx_encrypted_user_data_updated
    ON public.encrypted_user_data(updated_at);
