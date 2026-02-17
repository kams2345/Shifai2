-- ShifAI — Storage Bucket Policies
-- Secure encrypted blob storage for sync and share exports

-- ─── Create Storage Buckets ───
INSERT INTO storage.buckets (id, name, public)
VALUES ('encrypted-sync', 'encrypted-sync', FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES ('shared-exports', 'shared-exports', FALSE)
ON CONFLICT (id) DO NOTHING;

-- ─── encrypted-sync: User-owned encrypted blobs ───

-- Users can upload their own encrypted data
CREATE POLICY "Users can upload own sync blobs"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'encrypted-sync'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Users can read their own blobs
CREATE POLICY "Users can read own sync blobs"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'encrypted-sync'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Users can update their own blobs
CREATE POLICY "Users can update own sync blobs"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'encrypted-sync'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Users can delete their own blobs
CREATE POLICY "Users can delete own sync blobs"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'encrypted-sync'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- ─── shared-exports: Temporary share links ───

-- Users can upload exports for sharing
CREATE POLICY "Users can upload exports"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'shared-exports'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Signed URLs allow temporary public access (24h)
-- No SELECT policy needed — generate-share-link Edge Function
-- creates signed URLs via service role

-- Service role can delete expired exports
CREATE POLICY "Service can delete expired exports"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'shared-exports'
  );

-- ─── Size Limits ───
-- Enforced via config.toml: file_size_limit = "10MB"
-- Additional validation in Edge Functions
