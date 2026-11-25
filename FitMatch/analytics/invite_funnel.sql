-- Load an exported Event log CSV with the SQLite shell:
-- sqlite3 :memory: < analytics/invite_funnel.sql
.bail on
.headers on
.mode column
CREATE TABLE invite_events (
  event_name TEXT NOT NULL,
  invite_id INTEGER NOT NULL,
  friend TEXT NOT NULL,
  occurred_at TEXT NOT NULL,
  outfit TEXT
);

.import --csv --skip 1 events.csv invite_events

WITH sent AS (
  SELECT DISTINCT invite_id FROM invite_events WHERE event_name = 'invite_sent'
),
accepted AS (
  SELECT DISTINCT invite_id FROM invite_events WHERE event_name = 'invite_accepted'
),
voted AS (
  SELECT DISTINCT invite_id FROM invite_events WHERE event_name = 'outfit_voted'
)
SELECT
  COUNT(sent.invite_id) AS invites_sent,
  COUNT(accepted.invite_id) AS invites_accepted,
  COUNT(voted.invite_id) AS votes_cast,
  ROUND(100.0 * COUNT(accepted.invite_id) / NULLIF(COUNT(sent.invite_id), 0), 1)
    AS acceptance_rate_pct
FROM sent
LEFT JOIN accepted USING (invite_id)
LEFT JOIN voted ON voted.invite_id = accepted.invite_id;
