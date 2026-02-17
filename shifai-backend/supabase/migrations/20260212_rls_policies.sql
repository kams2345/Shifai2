-- ShifAI — Row Level Security Policies
-- Zero-knowledge: users can only access their own encrypted data

-- ─── Enable RLS ───
ALTER TABLE cycle_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE symptom_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE predictions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE encrypted_blobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE share_links ENABLE ROW LEVEL SECURITY;

-- ─── cycle_entries ───
CREATE POLICY "Users can view own cycle entries"
  ON cycle_entries FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cycle entries"
  ON cycle_entries FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own cycle entries"
  ON cycle_entries FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own cycle entries"
  ON cycle_entries FOR DELETE
  USING (auth.uid() = user_id);

-- ─── symptom_logs ───
CREATE POLICY "Users can view own symptom logs"
  ON symptom_logs FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own symptom logs"
  ON symptom_logs FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own symptom logs"
  ON symptom_logs FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own symptom logs"
  ON symptom_logs FOR DELETE
  USING (auth.uid() = user_id);

-- ─── insights ───
CREATE POLICY "Users can view own insights"
  ON insights FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own insights"
  ON insights FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own insights"
  ON insights FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own insights"
  ON insights FOR DELETE
  USING (auth.uid() = user_id);

-- ─── predictions ───
CREATE POLICY "Users can view own predictions"
  ON predictions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own predictions"
  ON predictions FOR ALL
  USING (auth.uid() = user_id);

-- ─── user_profiles ───
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ─── sync_logs ───
CREATE POLICY "Users can view own sync logs"
  ON sync_logs FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sync logs"
  ON sync_logs FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ─── encrypted_blobs (zero-knowledge storage) ───
CREATE POLICY "Users can view own blobs"
  ON encrypted_blobs FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own blobs"
  ON encrypted_blobs FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own blobs"
  ON encrypted_blobs FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own blobs"
  ON encrypted_blobs FOR DELETE
  USING (auth.uid() = user_id);

-- ─── share_links ───
CREATE POLICY "Users can view own share links"
  ON share_links FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own share links"
  ON share_links FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Service role can delete expired links (cleanup function)
CREATE POLICY "Service can delete expired links"
  ON share_links FOR DELETE
  USING (expires_at < NOW());
