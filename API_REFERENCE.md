# API Reference — ShifAI Backend

## Base URL
```
https://<project-ref>.supabase.co
```

## Authentication
All requests require:
```
Authorization: Bearer <access_token>
apikey: <anon_key>
```

---

## REST API (PostgREST)

### Cycle Entries

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/rest/v1/cycle_entries?select=*` | List all entries |
| GET | `/rest/v1/cycle_entries?date=gte.2026-01-01&date=lte.2026-01-31` | Date range |
| POST | `/rest/v1/cycle_entries` | Create entry |
| PATCH | `/rest/v1/cycle_entries?id=eq.<id>` | Update entry |
| DELETE | `/rest/v1/cycle_entries?id=eq.<id>` | Delete entry |

### Symptom Logs

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/rest/v1/symptom_logs?cycle_entry_id=eq.<id>` | By entry |
| POST | `/rest/v1/symptom_logs` | Create log |
| DELETE | `/rest/v1/symptom_logs?id=eq.<id>` | Delete log |

### Insights

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/rest/v1/insights?select=*&order=created_at.desc` | List insights |
| GET | `/rest/v1/insights?is_read=eq.false` | Unread only |
| PATCH | `/rest/v1/insights?id=eq.<id>` | Update (read/feedback) |

### Predictions

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/rest/v1/predictions?predicted_date=gte.now()` | Upcoming |
| PATCH | `/rest/v1/predictions?id=eq.<id>` | Verify (set actual_date) |

---

## Edge Functions

### POST `/functions/v1/sync-data`
Batch sync encrypted data.

**Request:**
```json
{
  "entries": [...],
  "symptoms": [...],
  "insights": [...],
  "predictions": [...],
  "lastSyncTimestamp": "2026-02-13T00:00:00Z"
}
```

**Response (200):**
```json
{
  "synced": { "entries": 5, "symptoms": 12, "insights": 2, "predictions": 1 },
  "conflicts": [],
  "serverTimestamp": "2026-02-13T12:00:00Z"
}
```

### POST `/functions/v1/generate-share-link`
Generate temporary share link for medical export.

**Request:**
```json
{
  "exportId": "uuid",
  "expiresInHours": 24,
  "template": "SOPK"
}
```

**Response (200):**
```json
{
  "shareUrl": "https://app.shifai.com/share/<token>",
  "expiresAt": "2026-02-14T12:00:00Z"
}
```

### POST `/functions/v1/delete-account`
GDPR Article 17 — Right to erasure.

**Request:** _(empty body, uses auth token)_

**Response (200):**
```json
{
  "deleted": true,
  "tables": ["cycle_entries", "symptom_logs", "insights", "predictions", "profiles"],
  "storage": ["encrypted-sync/<user_id>", "shared-exports/<user_id>"]
}
```

### POST `/functions/v1/cleanup-expired`
Cron-triggered cleanup of expired share links and orphaned storage.

**Request:** _(service role only)_

**Response (200):**
```json
{
  "expiredLinks": 3,
  "orphanedBlobs": 1,
  "freedBytes": 245760
}
```

---

## RLS Policies
All tables enforce Row Level Security:
- Users can only access their own data (`auth.uid() = user_id`)
- Zero-knowledge: server never sees plaintext health data
- Service role bypasses RLS for admin operations

## Rate Limits
| Endpoint | Limit |
|----------|-------|
| REST API | 100 req/min |
| Edge Functions | 30 req/min |
| Sync | 10 req/min |

## Error Codes
| Code | Meaning |
|------|---------|
| 401 | Unauthorized (expired/invalid token) |
| 403 | Forbidden (RLS violation) |
| 404 | Resource not found |
| 409 | Conflict (sync collision) |
| 429 | Rate limited |
| 500 | Server error |
