# ShifAI Supabase Backend

Backend minimal pour ShifAI — **zero-knowledge encrypted storage** + utilities.

> ⚠️ Le serveur est un "dumb encrypted storage". Toute l'intelligence est on-device.

## Stack

- **Database:** Supabase PostgreSQL (EU region)
- **Auth:** Supabase Auth (email/password + Apple Sign In)
- **Storage:** Supabase Storage (medical export PDFs, 7-day TTL)
- **Functions:** Deno Edge Functions
- **Region:** EU ONLY (GDPR requirement)

## Edge Functions

| Function | Route | Description |
|----------|-------|-------------|
| `sync-data` | POST/GET `/sync-data` | Push/pull encrypted data blobs |
| `generate-share-link` | POST `/generate-share-link` | Create 7-day shareable PDF link |
| `cleanup-expired-exports` | Cron (daily 03:00 UTC) | Delete exports >7 days old |

## Setup

```bash
# Install Supabase CLI
npm install -g supabase

# Login
supabase login

# Link to project (EU region!)
supabase link --project-ref YOUR_PROJECT_REF

# Run migrations
supabase db push

# Deploy functions
supabase functions deploy sync-data
supabase functions deploy generate-share-link
supabase functions deploy cleanup-expired-exports
```

## Environment Variables

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key  # For cron functions only
```

## Security

- Row Level Security (RLS) on ALL tables
- Users can ONLY access their own encrypted data
- 10MB max blob size
- Rate limiting: 100 req/min per user
- Certificate pinning enforced client-side
