-- ============================================================
-- VRT Sales Intelligence — Database Schema
-- Author: [Your Name]
-- DB: PostgreSQL / MySQL compatible
-- ============================================================

CREATE DATABASE IF NOT EXISTS vrt_sales;
USE vrt_sales;

-- Clients master table
CREATE TABLE clients (
    client_id     SERIAL PRIMARY KEY,
    client_name   VARCHAR(150) NOT NULL,
    industry      VARCHAR(80),
    region        VARCHAR(50),
    state         VARCHAR(50),
    country       VARCHAR(50) DEFAULT 'USA',
    created_at    DATE,
    is_active     BOOLEAN DEFAULT TRUE
);

-- Programs / Products
CREATE TABLE programs (
    program_id    SERIAL PRIMARY KEY,
    program_name  VARCHAR(100) NOT NULL,  -- EGA, EGOS, Entrepreneurial Edge
    base_price    NUMERIC(10,2),
    category      VARCHAR(50)
);

-- Sales Reps
CREATE TABLE sales_reps (
    rep_id        SERIAL PRIMARY KEY,
    full_name     VARCHAR(100),
    email         VARCHAR(150),
    region        VARCHAR(50),
    hire_date     DATE
);

-- Deals / Opportunities
CREATE TABLE deals (
    deal_id       SERIAL PRIMARY KEY,
    client_id     INT REFERENCES clients(client_id),
    program_id    INT REFERENCES programs(program_id),
    rep_id        INT REFERENCES sales_reps(rep_id),
    deal_value    NUMERIC(12,2),
    stage         VARCHAR(30),     -- Lead, Qualified, Proposal, Negotiation, Closed Won, Closed Lost
    close_date    DATE,
    created_at    DATE,
    notes         TEXT
);

-- Monthly KPI snapshots (for trend charts)
CREATE TABLE monthly_kpis (
    kpi_id        SERIAL PRIMARY KEY,
    month_year    DATE,           -- First day of each month
    total_revenue NUMERIC(14,2),
    new_clients   INT,
    churned       INT,
    deals_won     INT,
    deals_lost    INT,
    avg_deal_size NUMERIC(10,2)
);

-- Insert sample programs
INSERT INTO programs (program_name, base_price, category) VALUES
('EGA',                  8500.00, 'Growth'),
('EGOS',                 12000.00,'Systems'),
('Entrepreneurial Edge', 6500.00, 'Starter');
