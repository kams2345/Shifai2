-- ShifAI — Database Schema
-- Migration: Initial schema for all tables

-- ─── User Profiles ───
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    cycle_length INTEGER DEFAULT 28,
    conditions TEXT[] DEFAULT '{}',
    onboarding_completed BOOLEAN DEFAULT FALSE,
    biometric_enabled BOOLEAN DEFAULT FALSE,
    sync_enabled BOOLEAN DEFAULT FALSE,
    widget_privacy BOOLEAN DEFAULT FALSE,
    analytics_consent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- ─── Cycle Entries ───
CREATE TABLE IF NOT EXISTS cycle_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    cycle_day INTEGER NOT NULL,
    phase TEXT NOT NULL DEFAULT 'unknown',
    flow_intensity INTEGER DEFAULT 0,
    mood_score INTEGER DEFAULT 5,
    energy_score INTEGER DEFAULT 5,
    sleep_hours REAL DEFAULT 0,
    stress_level INTEGER DEFAULT 5,
    notes TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- ─── Symptom Logs ───
CREATE TABLE IF NOT EXISTS symptom_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    cycle_entry_id UUID REFERENCES cycle_entries(id) ON DELETE CASCADE,
    category TEXT NOT NULL,
    symptom_type TEXT NOT NULL,
    intensity INTEGER NOT NULL CHECK (intensity BETWEEN 1 AND 10),
    body_zone TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Insights ───
CREATE TABLE IF NOT EXISTS insights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    confidence REAL DEFAULT 0,
    is_read BOOLEAN DEFAULT FALSE,
    feedback TEXT,
    source TEXT DEFAULT 'rule_based',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Predictions ───
CREATE TABLE IF NOT EXISTS predictions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    predicted_date DATE NOT NULL,
    confidence REAL DEFAULT 0,
    actual_date DATE,
    source TEXT DEFAULT 'rule_based',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Sync Logs ───
CREATE TABLE IF NOT EXISTS sync_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID NOT NULL,
    status TEXT DEFAULT 'pending',
    error_message TEXT,
    synced_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Encrypted Blobs (zero-knowledge sync) ───
CREATE TABLE IF NOT EXISTS encrypted_blobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    blob_type TEXT NOT NULL,
    encrypted_data BYTEA NOT NULL,
    iv BYTEA NOT NULL,
    version INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Share Links ───
CREATE TABLE IF NOT EXISTS share_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    storage_path TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    access_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Indexes ───
CREATE INDEX idx_cycle_entries_user_date ON cycle_entries(user_id, date);
CREATE INDEX idx_symptom_logs_entry ON symptom_logs(cycle_entry_id);
CREATE INDEX idx_insights_user ON insights(user_id, created_at DESC);
CREATE INDEX idx_predictions_user ON predictions(user_id, predicted_date);
CREATE INDEX idx_sync_logs_user ON sync_logs(user_id, synced_at DESC);
CREATE INDEX idx_encrypted_blobs_user ON encrypted_blobs(user_id, blob_type);
CREATE INDEX idx_share_links_expiry ON share_links(expires_at);

-- ─── Updated_at trigger ───
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at_user_profiles
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER set_updated_at_cycle_entries
  BEFORE UPDATE ON cycle_entries
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER set_updated_at_encrypted_blobs
  BEFORE UPDATE ON encrypted_blobs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
