-- Project JOB App — PostgreSQL Schema (PRD V5)

-- 1. Users
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subscription_tier VARCHAR(50) DEFAULT 'Free', -- Free, Premium, VIP
    is_admin BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE
);

-- 2. Profiles (Professional Agents)
CREATE TABLE profiles (
    profile_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    profile_name VARCHAR(100),
    target_field VARCHAR(100),
    target_role VARCHAR(100),
    master_cv_url TEXT,
    linkedin_url TEXT,
    credentials_encrypted TEXT,          -- AES-256 encrypted session cookies/API keys
    ai_persona_instructions TEXT,        -- AES-256 encrypted
    match_threshold INTEGER DEFAULT 92,  -- Dynamic Autopilot threshold (0-100)
    match_logic_version VARCHAR(20) DEFAULT '1.0',
    autonomy_mode VARCHAR(50) DEFAULT 'Co-Pilot', -- Manual, Co-Pilot, Autopilot
    is_active BOOLEAN DEFAULT TRUE
);

-- 3. Admin Permissions & Cost Tracking
CREATE TABLE admin_permissions (
    permission_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    max_profiles INTEGER DEFAULT 1,
    can_use_magic_button BOOLEAN DEFAULT FALSE,
    can_use_agentic_reasoning BOOLEAN DEFAULT FALSE,
    autopilot_limit_monthly INTEGER DEFAULT 0,
    current_monthly_usage_tokens BIGINT DEFAULT 0, -- Cached for performance
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Job Leads
CREATE TABLE job_leads (
    job_id SERIAL PRIMARY KEY,
    profile_id INTEGER REFERENCES profiles(profile_id) ON DELETE CASCADE,
    job_title VARCHAR(255),
    company_name VARCHAR(255),
    source VARCHAR(100),                 -- linkedin, telegram, noga, indeed, etc.
    source_raw_data JSONB,               -- Raw JSON for failed parsing analysis
    match_score INTEGER,                 -- 0-100
    match_explanation TEXT,
    reasoning_log TEXT,                  -- AI strategy (Why & How)
    execution_log TEXT,                  -- Automation steps (Login success, Form filled, etc.)
    tailored_cv_url TEXT,                -- storage/{user_id}/{profile_id}/{cv_uuid}.pdf
    application_status VARCHAR(50) DEFAULT 'New',
    -- Enum: New, Pending_Validation, Sent, Failed_Technical
    automation_triggered BOOLEAN DEFAULT FALSE, -- Manual click vs Autopilot
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    applied_at TIMESTAMP
);

-- 5. System Analytics (API cost tracking)
CREATE TABLE system_analytics (
    analytics_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    profile_id INTEGER REFERENCES profiles(profile_id),
    action_type VARCHAR(100),            -- cv_tailor, scrape, apply, reasoning
    ai_provider VARCHAR(50),             -- claude, gemini
    prompt_tokens INTEGER DEFAULT 0,
    completion_tokens INTEGER DEFAULT 0,
    cost_usd NUMERIC(10, 6) DEFAULT 0,
    metadata JSONB,                      -- error_code, provider_latency, stack_trace
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
