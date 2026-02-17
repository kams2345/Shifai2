-- ShifAI — Seed Data for Development
-- Run after initial_schema migration for local development

-- ─── Test User Profile ───
INSERT INTO user_profiles (id, user_id, cycle_length, conditions, onboarding_completed, sync_enabled)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    '11111111-1111-1111-1111-111111111111',
    28,
    ARRAY['SOPK'],
    TRUE,
    FALSE
) ON CONFLICT (user_id) DO NOTHING;

-- ─── Sample Cycle Entries (30 days) ───
INSERT INTO cycle_entries (user_id, date, cycle_day, phase, flow_intensity, mood_score, energy_score, sleep_hours, stress_level, notes)
VALUES
    ('11111111-1111-1111-1111-111111111111', '2026-01-14', 1, 'menstrual', 3, 4, 3, 7.5, 6, 'Premiers jours difficiles'),
    ('11111111-1111-1111-1111-111111111111', '2026-01-15', 2, 'menstrual', 4, 3, 3, 6.0, 7, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-01-16', 3, 'menstrual', 3, 4, 4, 7.0, 5, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-01-17', 4, 'menstrual', 2, 5, 5, 7.5, 4, 'Ça va mieux'),
    ('11111111-1111-1111-1111-111111111111', '2026-01-18', 5, 'menstrual', 1, 6, 5, 8.0, 4, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-01-19', 6, 'follicular', 0, 6, 6, 7.5, 3, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-01-20', 7, 'follicular', 0, 7, 7, 8.0, 3, 'Pleine forme'),
    ('11111111-1111-1111-1111-111111111111', '2026-01-21', 8, 'follicular', 0, 7, 7, 7.5, 3, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-01-22', 9, 'follicular', 0, 8, 8, 8.0, 2, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-01-23', 10, 'follicular', 0, 8, 8, 7.0, 2, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-01-24', 11, 'follicular', 0, 7, 7, 7.5, 3, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-01-25', 12, 'follicular', 0, 8, 8, 8.0, 2, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-01-26', 13, 'ovulatory', 0, 9, 9, 7.5, 2, 'Super énergie'),
    ('11111111-1111-1111-1111-111111111111', '2026-01-27', 14, 'ovulatory', 0, 9, 9, 8.0, 2, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-01-28', 15, 'ovulatory', 0, 8, 8, 7.0, 3, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-01-29', 16, 'luteal', 0, 7, 7, 7.5, 4, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-01-30', 17, 'luteal', 0, 6, 6, 7.0, 4, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-01-31', 18, 'luteal', 0, 6, 5, 6.5, 5, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-02-01', 19, 'luteal', 0, 5, 5, 6.0, 5, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-02-02', 20, 'luteal', 0, 5, 4, 6.5, 6, 'Fatigue'),
    ('11111111-1111-1111-1111-111111111111', '2026-02-03', 21, 'luteal', 0, 4, 4, 6.0, 6, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-02-04', 22, 'luteal', 0, 4, 4, 7.0, 6, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-02-05', 23, 'luteal', 0, 4, 3, 6.5, 7, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-02-06', 24, 'luteal', 0, 3, 3, 6.0, 7, 'SPM commence'),
    ('11111111-1111-1111-1111-111111111111', '2026-02-07', 25, 'luteal', 0, 3, 3, 5.5, 8, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-02-08', 26, 'luteal', 0, 4, 3, 6.0, 7, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-02-09', 27, 'luteal', 0, 3, 3, 6.0, 7, ''),
    ('11111111-1111-1111-1111-111111111111', '2026-02-10', 28, 'luteal', 0, 3, 3, 5.5, 8, '');

-- ─── Sample Symptom Logs ───
INSERT INTO symptom_logs (user_id, category, symptom_type, intensity, body_zone)
VALUES
    ('11111111-1111-1111-1111-111111111111', 'PAIN', 'cramps', 7, 'ABDOMEN'),
    ('11111111-1111-1111-1111-111111111111', 'PAIN', 'headache', 5, 'HEAD'),
    ('11111111-1111-1111-1111-111111111111', 'DIGESTIVE', 'bloating', 6, 'ABDOMEN'),
    ('11111111-1111-1111-1111-111111111111', 'MOOD', 'irritability', 4, NULL),
    ('11111111-1111-1111-1111-111111111111', 'FATIGUE', 'fatigue', 8, NULL),
    ('11111111-1111-1111-1111-111111111111', 'SKIN', 'acne', 3, NULL),
    ('11111111-1111-1111-1111-111111111111', 'PAIN', 'back_pain', 6, 'LOWER_BACK');

-- ─── Sample Insights ───
INSERT INTO insights (user_id, type, title, body, confidence, source)
VALUES
    ('11111111-1111-1111-1111-111111111111', 'correlation',
     'Migraine et stress liés',
     'Tes migraines apparaissent 2× plus souvent les jours de stress élevé (≥7/10).',
     0.82, 'pattern_detection'),
    ('11111111-1111-1111-1111-111111111111', 'prediction',
     'Prochaines règles dans ~5 jours',
     'Basé sur tes 3 derniers cycles (27, 28, 29 jours). Confiance modérée.',
     0.75, 'rule_based'),
    ('11111111-1111-1111-1111-111111111111', 'recommendation',
     'Sommeil et énergie',
     'Les jours où tu dors ≥7.5h, ton énergie est 40% plus haute. Essaie de maintenir ce rythme.',
     0.88, 'pattern_detection');

-- ─── Sample Prediction ───
INSERT INTO predictions (user_id, type, predicted_date, confidence, source)
VALUES
    ('11111111-1111-1111-1111-111111111111', 'period_start', '2026-02-11', 0.75, 'rule_based'),
    ('11111111-1111-1111-1111-111111111111', 'ovulation', '2026-02-24', 0.65, 'rule_based');
