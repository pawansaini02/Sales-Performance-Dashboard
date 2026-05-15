-- ============================================================
-- VRT Sales Intelligence — KPI & Analytics Queries
-- ============================================================

-- ── 1. Total Revenue by Month ────────────────────────────────
SELECT
    DATE_FORMAT(close_date, '%Y-%m') AS month,
    SUM(deal_value)                  AS total_revenue,
    COUNT(*)                         AS deals_closed
FROM deals
WHERE stage = 'Closed Won'
  AND YEAR(close_date) = YEAR(CURDATE())
GROUP BY DATE_FORMAT(close_date, '%Y-%m')
ORDER BY month;


-- ── 2. Revenue by Program (for donut chart) ──────────────────
SELECT
    p.program_name,
    SUM(d.deal_value)                AS revenue,
    COUNT(d.deal_id)                 AS deal_count,
    ROUND(SUM(d.deal_value) * 100.0
        / SUM(SUM(d.deal_value)) OVER(), 1) AS pct_share
FROM deals d
JOIN programs p ON d.program_id = p.program_id
WHERE d.stage = 'Closed Won'
GROUP BY p.program_name
ORDER BY revenue DESC;


-- ── 3. Revenue by Region ──────────────────────────────────────
SELECT
    c.region,
    c.state,
    SUM(d.deal_value)   AS revenue,
    COUNT(d.deal_id)    AS deals,
    AVG(d.deal_value)   AS avg_deal
FROM deals d
JOIN clients c ON d.client_id = c.client_id
WHERE d.stage = 'Closed Won'
GROUP BY c.region, c.state
ORDER BY revenue DESC
LIMIT 10;


-- ── 4. Sales Funnel (pipeline stage counts) ──────────────────
SELECT
    stage,
    COUNT(*)            AS deal_count,
    SUM(deal_value)     AS pipeline_value,
    AVG(deal_value)     AS avg_deal
FROM deals
WHERE YEAR(created_at) = YEAR(CURDATE())
GROUP BY stage
ORDER BY FIELD(stage,
    'Lead','Qualified','Proposal',
    'Negotiation','Closed Won','Closed Lost');


-- ── 5. Win Rate by Rep ────────────────────────────────────────
SELECT
    r.full_name                         AS rep,
    COUNT(CASE WHEN d.stage='Closed Won'  THEN 1 END)  AS won,
    COUNT(CASE WHEN d.stage='Closed Lost' THEN 1 END)  AS lost,
    COUNT(*)                                            AS total,
    ROUND(
        COUNT(CASE WHEN d.stage='Closed Won' THEN 1 END) * 100.0
        / NULLIF(COUNT(CASE WHEN d.stage IN ('Closed Won','Closed Lost') THEN 1 END),0)
    ,1)                                                 AS win_rate_pct,
    SUM(CASE WHEN d.stage='Closed Won' THEN d.deal_value ELSE 0 END) AS total_revenue
FROM deals d
JOIN sales_reps r ON d.rep_id = r.rep_id
GROUP BY r.rep_id, r.full_name
ORDER BY win_rate_pct DESC;


-- ── 6. Month-over-Month Growth ───────────────────────────────
WITH monthly AS (
    SELECT
        DATE_FORMAT(close_date, '%Y-%m') AS month,
        SUM(deal_value)                  AS revenue
    FROM deals
    WHERE stage = 'Closed Won'
    GROUP BY DATE_FORMAT(close_date, '%Y-%m')
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month)  AS prev_month_rev,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0)
    , 1)                                AS mom_growth_pct
FROM monthly
ORDER BY month;


-- ── 7. KPI Summary View (used for Power BI direct query) ─────
CREATE OR REPLACE VIEW vw_kpi_summary AS
SELECT
    YEAR(close_date)  AS yr,
    QUARTER(close_date) AS qtr,
    COUNT(*)          AS deals_won,
    SUM(deal_value)   AS total_revenue,
    AVG(deal_value)   AS avg_deal_size,
    COUNT(DISTINCT client_id) AS unique_clients
FROM deals
WHERE stage = 'Closed Won'
GROUP BY YEAR(close_date), QUARTER(close_date);


-- ── 8. Client Retention (New vs Churned) ─────────────────────
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    COUNT(*)                          AS new_clients
FROM clients
GROUP BY DATE_FORMAT(created_at, '%Y-%m')
ORDER BY month;
