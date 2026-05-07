# Product Requirements Document (PRD) & Technical Architecture: Project JOB App (v6.1)

**Source:** Google Drive — "PRD - Project JOB App _ v6" (synced 2026-05-07)
**Changelog v6.1 vs v6:**
- Section 11 (NEW): Prototype Implementation Log — all features built in `prototype.html` as of 2026-05-07
- Section 12 (NEW): Mobile Backlog — known issues pending fix
- Section 13 (NEW): Git History & GitHub deployment status

---

## 1. Executive Summary

**Project Name:** Project JOB App

**Objective:** An Agentic AI SaaS platform for autonomous job/tender discovery and application. The system features modular professional identities, strategy-based reasoning, and a secure "Magic Button" for one-tap or fully autonomous execution, governed by a robust Admin Center with real-time Unit Economics tracking.

---

## 2. Multi-Profile Architecture & Isolation

- **Modular Identities:** Users manage distinct "Professional Agents" (e.g., "Infrastructure PMO", "DJ").
- **Strict Profile Isolation:** Every AI query must include `profile_id` as a mandatory parameter to prevent data leakage between identities.
- **File Security:** Tailored CVs are stored using UUID-based paths: `storage/{user_id}/{profile_id}/{cv_uuid}.pdf`.
- **Asset Integrity:** The system performs a checksum validation between the Profile's Master CV and the data used for tailoring before execution.

---

## 3. The "Agentic Brain" & Autonomy Modes

### 3.1. Reasoning & Execution Logs

- **Reasoning Log (Strategy):** AI explains the "Why" and "How" behind its tailoring strategy. Always generated in the user's chosen UI language (see Section 9).
- **Execution Log (Technical):** Detailed logs of the automation steps (e.g., "Login Success", "Form Filled", "CV Uploaded") for transparency and debugging.

### 3.2. Autonomy Modes & Thresholds

- **Manual:** Scrape & Rank only.
- **Co-Pilot (Hybrid):** AI suggests strategy → User approves → AI executes.
- **Autopilot (Full Agentic):** AI autonomously applies to jobs exceeding a user-defined `match_threshold` (e.g., 92%). This threshold is dynamic and managed per profile.

---

## 4. The "Magic Button" & Scraper Resilience

### 4.1. One-Tap Execution

- **AI CV Tailoring:** Real-time generation of JD-optimized PDFs.
- **Autonomous Submission:** Via Email API (SendGrid) or Web-Form automation (Playwright).
- **Identity Protection:** Use of encrypted session storage for credentials.

### 4.2. Scraper Protocols (Anti-Blocking)

- **IP Rotation & Proxy:** Mandatory use of rotating proxies for LinkedIn and specialized scrapers for government portals (Noga, etc.).
- **Retry Logic:** Exponential backoff mechanism for failed scrapes.
- **Source Raw Data:** Storage of raw JSON data for failed parsing analysis.

---

## 5. Administrative Center (Monday-style) & Cost Control

- **User & Permission Grid:** Manually unlock features (Magic Button, Agentic Reasoning).
- **Unit Economics Dashboard:**
  - **Token Tracking:** Real-time monitoring of `prompt_tokens` vs. `completion_tokens`.
  - **Usage Quotas:** Monthly token limits per user with 80% threshold alerts.
- **Product Intelligence:** AI-driven analysis of UX friction and failure patterns.

---

## 6. Technical Stack & Security

- **Backend:** Python (FastAPI) with Encryption at Rest (AES-256) for all sensitive fields (Credentials, AI Personas).
- **AI Reasoning & Strategy:** Claude Sonnet 4.6 (`claude-sonnet-4-6`)
- **AI Analysis & Context:** Gemini 1.5 Pro
- **Automation:** Playwright (Web Filling) / SendGrid (Email)
- **Frontend:** React + Tailwind CSS (Monday-style high-density UI) with i18n data-attribute convention (see Section 9)
- **Database:** PostgreSQL
- **Security:** Mandatory IDOR checks and UUID-based resource naming.

---

## 7. Database Schema (SQL Architecture — Production Ready)

```sql
-- 1. Users Table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subscription_tier VARCHAR(50) DEFAULT 'Free', -- Free, Premium, VIP
    is_admin BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    preferred_locale VARCHAR(10) DEFAULT 'en' -- e.g. 'en', 'he', 'ar'
);

-- 2. Profiles Table (Enhanced Security & Logic)
CREATE TABLE profiles (
    profile_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    profile_name VARCHAR(100),
    target_field VARCHAR(100),
    target_role VARCHAR(100),
    master_cv_url TEXT,
    linkedin_url TEXT,
    credentials_encrypted TEXT, -- Encrypted Session Cookies/API Keys
    ai_persona_instructions TEXT, -- AES-256 Encrypted
    match_threshold INTEGER DEFAULT 92, -- Dynamic threshold for Autopilot
    match_logic_version VARCHAR(20) DEFAULT '1.0',
    autonomy_mode VARCHAR(50) DEFAULT 'Co-Pilot',
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

-- 4. Job Leads Table (Expanded Status & Logs)
CREATE TABLE job_leads (
    job_id SERIAL PRIMARY KEY,
    profile_id INTEGER REFERENCES profiles(profile_id) ON DELETE CASCADE,
    job_title VARCHAR(255),
    company_name VARCHAR(255),
    match_score INTEGER,
    match_explanation TEXT,
    reasoning_log TEXT,         -- AI Strategy (stored in user's preferred locale)
    execution_log TEXT,         -- Automation steps (Playwright logs)
    source_platform VARCHAR(100),
    source_raw_data JSONB,      -- For failed parsing analysis
    source_language VARCHAR(10), -- Original language of the job posting (e.g. 'he', 'en')
    direct_link TEXT,
    application_status VARCHAR(50) DEFAULT 'New', -- Enum: New, Pending_Validation, Sent, Failed_Technical
    automation_triggered BOOLEAN DEFAULT FALSE,    -- Manual vs Autopilot
    tailored_cv_url TEXT,       -- UUID-based secure path
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Analytics & Metadata (Mandatory JSONB)
CREATE TABLE system_analytics (
    log_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    action_type VARCHAR(100),
    metadata JSONB NOT NULL, -- Must contain: error_code, provider_latency, prompt_tokens, completion_tokens
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 8. Scraping Sources

| Source | Language | Notes |
|--------|----------|-------|
| LinkedIn | EN / HE (mixed) | Requires rotating proxies |
| Government Tenders (Noga) | HE | Specialized parser |
| Indeed | EN / HE | Standard scraper |
| Facebook Groups | HE | Group-specific scraper |
| Telegram Channels | HE / EN | Channel subscription |

---

## 9. Internationalization (i18n) — v6

### 9.1. Overview

The application supports multiple languages and RTL (right-to-left) layouts. Initial supported languages: English (EN) and Hebrew (HE), architecture designed for easy addition of future languages.

### 9.2. Hybrid Locale Architecture

| Locale | Loading Strategy | Caching |
|--------|-----------------|---------|
| English (default) | **Inline** — bundled with the app, always instant | N/A |
| Hebrew + future | **On-demand** — loaded once from `locales/<lang>.js` on first selection | Cached in `localStorage` after first load; offline-capable |

**Cache keys:**
- `i18n_cache_<lang>` — UI string translations
- `i18n_reasoning_<lang>` — AI reasoning/strategy content translations

**To add a new language:**
1. Create `locales/<lang>.js` with `window.LOCALE_<LANG> = { ui: {...}, reasoning: {...} }`
2. Add the locale tag to the language switcher cycle

### 9.3. RTL Layout

When `lang === 'he'` (or any RTL language):
- `dir="rtl"` is set on the `<html>` element
- CSS logical properties govern layout (sidebar mirrors to right, margins flip)
- Font switches to Heebo (optimized for Hebrew) as the primary typeface

### 9.4. Job Description Language Policy

| Content Type | Language Displayed |
|-------------|-------------------|
| Job title & description (scraped) | **Original source language** — Hebrew from gov.il, English from LinkedIn, etc. |
| AI Reasoning / Strategy | **User's chosen UI language** — Claude receives an explicit language instruction in the system prompt |
| Execution log | **User's chosen UI language** |

**Rationale:** Target users are bilingual (Hebrew/English). Preserving original job description avoids translation cost and distortion.

**Deliberate non-feature:** "Translate JD" button was considered and rejected.

### 9.5. AI Prompt Language Instruction

Every call to Claude for reasoning/strategy must include:

```
System: Respond in {user.preferred_locale} language only.
         Use {direction} text direction.
```

### 9.6. Frontend i18n Convention

All user-visible UI strings use `data-i18n="key"` attribute:

```javascript
function setLocale(lang) {
  document.querySelectorAll('[data-i18n]').forEach(el => {
    el.textContent = t(el.dataset.i18n);
  });
  document.documentElement.dir = lang === 'he' ? 'rtl' : 'ltr';
}
```

In the React frontend: implement via `react-i18next` following the same key-naming convention.

---

## 10. UI Prototype — Decisions Log (v6)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| i18n approach | Hybrid (EN inline, others on-demand + localStorage cache) | Zero cost for default language; one-time load for others |
| Language switcher | EN / עב toggle button in top nav bar | Simple, visible; expandable to dropdown for 3+ languages |
| RTL support | Full CSS logical-property override via `[dir="rtl"]` | Sidebar, margins, flex directions all mirror correctly |
| Job description language | Original scraped language (no auto-translate) | Users are bilingual; avoids API cost and distortion |
| "Translate JD" button | Not implemented | Unnecessary for target user profile |
| Reasoning modal content | Translated per locale (stored in locale files) | Strategy/reasoning must be in user's working language |
| AI model | Claude Sonnet 4.6 | Latest production model as of v6 |
| Prototype tech | Vanilla HTML/JS (single file + locales/ folder) | Fastest iteration; no build tooling needed at this stage |

---

## 11. Prototype Implementation Log — v6.1 (2026-05-07)

All work in `prototype.html` (single-file, vanilla JS). Status: **interactive prototype**.

### 11.1 Dashboard — Job Table
- [x] Muted status badge colors — only Error/New get strong color
- [x] Bold job title + company per row as visual anchor
- [x] RTL icon alignment fix
- [x] Row padding 10–12px for scanability
- [x] Match % as primary element (number larger than bar)
- [x] "Applied" badge visually distinct from "Apply" button

### 11.2 Job Card Modal
- [x] Large job title (20px bold)
- [x] Facts grid with icon + label gap
- [x] Salary bar: P25→P90 gradient, two markers (◆ user salary, ● role target), gap label
- [x] Network connections: interactive buttons (💬 Message / 🤝 Request Referral / + Connect)
- [x] Gap pills clickable → popover with interview tip (13 gap types covered in GAP_TIPS)
- [x] 📋 Create Task button → dropdown: Monday.com / Jira / Trello / Asana → toast on select

### 11.3 Navigation & Filtering
- [x] Filter chips + search bar in same `.filter-group` row
- [x] "Showing X of 47" live filter count
- [x] Match slider replaced by filter chip (≥80%)
- [x] Group By dropdown: Status / Source / Autonomy / Match Range
  - Desktop: `rebuildGroups()` with collapsible group headers
  - Mobile: `rebuildMobileGroups()` with `.mobile-group-header` divs

### 11.4 Power User Features
- [x] **Bulk selection**: checkboxes on all 7 desktop rows + 5 mobile cards
- [x] **Select-all** with indeterminate state
- [x] **Bulk bar**: slides in with Apply / Archive / Change Status
- [x] **Bulk Apply animation**: per-row staged progress (Tailoring CV → Login → Fill → Sent), staggered 400ms, updates status badge
- [x] **Bulk Archive/Status**: toast notification
- [x] **Keyboard shortcuts**: ↑↓ navigate, Enter open card, Space select, A apply, / focus search, ? toggle shortcuts panel, Esc close all

### 11.5 Magic Button Modal
- [x] Redesigned header (title + company + match % prominent)
- [x] Active step spinner (CSS `::before` ring animation)
- [x] Live field counter during step 3 (Filling 1/8... → 8/8)
- [x] Audit trail link in success result
- [x] Error scenario (login fail → steps 3+4 blocked, retry button)

### 11.6 Toast System
- [x] `showToast(icon, title, msg)` — bottom-right, 4s auto-dismiss, fade-out, ✕ close

---

## 12. Mobile Backlog — Known Issues (Pending Fix)

Mobile view (≤767px) shows `.job-cards` instead of `.table-wrap`.

| # | Issue | Priority |
|---|-------|----------|
| 1 | **Toolbar overflow** — chips + search + Group By too cramped; no scroll indicator | High |
| 2 | **filter-count hidden** — user can't see "Showing X of 47" | High |
| 3 | **Bulk bar** — action buttons overflow/wrap badly on narrow widths | Medium |
| 4 | **Create Task dropdown** — may go off-screen on narrow widths | Medium |
| 5 | **Checkbox styling** — "Select" label next to checkbox looks unpolished | Low |
| 6 | **Shortcuts panel** — irrelevant on mobile (no keyboard), wastes space | Low |

---

## 13. Git History & Deployment

**Repo:** `github.com/tsshlomi/vibe-coding-jobapp` | **Branch:** master

| Commit | Description |
|--------|-------------|
| `66a43d4` | fix: task dropdown id collision, mobile filter sync, dropdown direction |
| `025d72f` | feat: mobile bulk+group-by, bulk apply animation, workflow tasks, toasts |
| `432179e` | feat: keyboard shortcuts + magic button UX overhaul |
| `11f4ef0` | feat: group by — status, source, autonomy, match range |
| `97d72b8` | feat: bulk actions — checkbox selection + contextual action bar |
| `2157d86` | feat: live filtering — search input, active chip, showing count |
| `1b8c887` | feat: job card — header, tiles, salary marker, network actions, gap tips |
| `666a23c` | style: dashboard UI/UX improvements — visual hierarchy & noise reduction |

**GitHub Pages:** לא מופעל עדיין
- הפעלה: Settings → Pages → Branch: master → Folder: / → Save
- URL: `https://tsshlomi.github.io/vibe-coding-jobapp/prototype.html`

---

## 14. Next Steps (Priority Order)

### Phase A — Mobile Fix (Immediate)
1. Toolbar overflow → horizontal scroll + sticky search
2. filter-count visible on mobile
3. Bulk bar → wrap-safe layout
4. Checkbox inline with card header score
5. Hide Shortcuts panel on mobile

### Phase B — Backend Bootstrap
1. FastAPI skeleton + PostgreSQL schema (Section 7)
2. JWT Auth
3. Jobs CRUD API
4. Profile management

### Phase C — AI Integration
1. Claude Sonnet 4.6 → CV tailoring
2. Gemini 1.5 Pro → job analysis + match scoring
3. Magic Button → Playwright automation

### Phase D — Scraping
1. LinkedIn scraper (rotating proxies)
2. Gov Tenders / Noga
3. Scheduling + dedup logic

---

*PRD v6.1 — Updated 2026-05-07 | Based on Google Drive PRD v6.0 (2026-05-04)*
