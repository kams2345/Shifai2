# Performance Budget — ShifAI

## App Size

| Metric | iOS Target | Android Target |
|--------|-----------|----------------|
| Download size | < 25 MB | < 20 MB |
| Install size | < 50 MB | < 40 MB |
| ML Model (CoreML/TFLite) | < 5 MB | < 5 MB |

## Startup

| Metric | Target | Measurement |
|--------|--------|-------------|
| Cold start → Dashboard | < 1.5s | Time-to-interactive |
| Warm start → Dashboard | < 0.5s | Time-to-interactive |
| Database open (SQLCipher) | < 200ms | Instrumentation |
| Widget refresh | < 1s | Background task |

## Responsiveness

| Action | Target | Notes |
|--------|--------|-------|
| Tab switch | < 100ms | No loading spinner |
| Save daily log | < 200ms | Local write, sync async |
| Load 30-day chart | < 300ms | Cached data |
| ML prediction | < 500ms | On-device inference |
| PDF generation | < 3s | 12-month report |
| Sync (100 entries) | < 5s | Encrypted upload |

## Memory

| Metric | Target |
|--------|--------|
| Idle memory | < 80 MB |
| Active tracking | < 120 MB |
| Peak (PDF gen) | < 200 MB |
| Widget memory | < 30 MB |

## Battery

| Metric | Target |
|--------|--------|
| Background sync | < 1% per sync |
| Widget updates | < 0.5% per day |
| No GPS / Bluetooth / Camera | Zero background drain |

## Network

| Metric | Target |
|--------|--------|
| Sync payload (per flush) | < 50 KB (encrypted) |
| Analytics (per event) | < 1 KB |
| API calls (daily) | < 10 (batched sync) |
| Offline capability | 100% (read+write) |

## Database

| Metric | Target |
|--------|--------|
| Query: today's entry | < 5ms |
| Query: 30-day range | < 20ms |
| Query: symptom by category | < 10ms |
| Insert: daily log + symptoms | < 15ms |
| Full DB size (1 year) | < 5 MB |

## Monitoring

- **iOS**: MetricKit + custom PerformanceMonitor
- **Android**: PerformanceMonitor (existing) + Firebase Perf (optional)
- **Plausible**: Page load events (bucketed, no PII)
