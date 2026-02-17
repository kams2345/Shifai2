-- Migration 002: Add size_bytes + medical exports table + analytics events
-- ShifAI Backend — Sprint 9 Gap Fill

-- ─── Add size_bytes to encrypted_user_data ───
ALTER TABLE public.encrypted_user_data
    ADD COLUMN IF NOT EXISTS size_bytes BIGINT DEFAULT 0;

-- ─── Medical Exports Bucket Metadata ───
-- Tracks shareable PDF exports with TTL
CREATE TABLE IF NOT EXISTS public.medical_exports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    file_path TEXT NOT NULL,           -- Storage bucket path
    template TEXT NOT NULL,            -- 'sopk', 'endometriosis', 'custom'
    date_range_start DATE,
    date_range_end DATE,
    share_url TEXT,                    -- Signed URL (nullable until shared)
    expires_at TIMESTAMPTZ,           -- Share link expiry
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.medical_exports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own exports"
    ON public.medical_exports
    FOR ALL
    USING (auth.uid() = user_id);

-- ─── Analytics Events (privacy-safe) ───
-- Zero PII — only aggregate event names + counts
CREATE TABLE IF NOT EXISTS public.analytics_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    event_name TEXT NOT NULL,          -- e.g. 'onboarding_complete', 'export_generated'
    event_data JSONB DEFAULT '{}',    -- Zero PII metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.analytics_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert own events"
    ON public.analytics_events
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Service role can read all for dashboards
CREATE POLICY "Service role can read all events"
    ON public.analytics_events
    FOR SELECT
    USING (auth.role() = 'service_role');

-- ─── Data Deletion Log (GDPR Art. 17) ───
CREATE TABLE IF NOT EXISTS public.deletion_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,             -- Not FK — user will be deleted
    deletion_type TEXT NOT NULL,        -- 'user_request', 'admin', 'retention_policy'
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── Indexes ───
CREATE INDEX IF NOT EXISTS idx_medical_exports_user
    ON public.medical_exports(user_id);

CREATE INDEX IF NOT EXISTS idx_medical_exports_expires
    ON public.medical_exports(expires_at)
    WHERE expires_at IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_analytics_events_user
    ON public.analytics_events(user_id);

CREATE INDEX IF NOT EXISTS idx_analytics_events_name
    ON public.analytics_events(event_name, created_at);
