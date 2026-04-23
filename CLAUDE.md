# CLAUDE.md — Project JOB App

This file provides guidance to Claude Code when working in this repository.

## Git Workflow — Commit and Push After Every Change

After every code change, always commit **and push** to the remote so work is never lost.

1. Stage only the changed files (never `git add -A` blindly)
2. Commit with a clear, descriptive message:
   ```
   <type>: <short summary>
   ```
   Common types: `feat`, `fix`, `style`, `refactor`
3. Push immediately: `git push origin master`

---

## Project Overview

**Project JOB App** is an Agentic AI SaaS platform for autonomous job/tender discovery and application. It manages multiple professional identities, reasons through opportunities using AI, and executes applications via a "Magic Button" — either on user command or fully autonomously.

PRD source: Google Drive → "PRD - Project Job App _ v5"

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Python 3.11 + FastAPI |
| AI Reasoning | Claude Sonnet (strategy & tailoring) |
| AI Analysis | Gemini 1.5 Pro (context & analysis) |
| Automation | Playwright (web form filling) |
| Email | SendGrid |
| Frontend | React + Tailwind CSS (Monday-style high-density UI) |
| Database | PostgreSQL |
| Scraping | LinkedIn, Facebook, Telegram, Gov Tenders (Noga), Indeed |

---

## Folder Structure

```
JOBAPP/
├── CLAUDE.md
├── .gitignore
├── backend/
│   ├── main.py                    # FastAPI app entry point
│   ├── requirements.txt
│   ├── .env.example               # Required env vars (copy to .env)
│   └── app/
│       ├── api/routes/
│       │   ├── users.py           # User CRUD
│       │   ├── profiles.py        # Profile management
│       │   ├── jobs.py            # Job leads + Magic Button trigger
│       │   └── admin.py           # Admin center endpoints
│       ├── models/
│       │   ├── user.py
│       │   ├── profile.py
│       │   └── job_lead.py
│       ├── services/
│       │   ├── ai_service.py      # Claude + Gemini API calls
│       │   ├── scraper_service.py # Multi-source scraping
│       │   └── automation_service.py # Playwright automation
│       └── db/
│           └── schema.sql         # PostgreSQL schema (PRD V5)
└── frontend/
    ├── package.json
    ├── tailwind.config.js
    ├── index.html
    └── src/
        ├── App.jsx
        ├── main.jsx
        ├── components/
        │   ├── Dashboard/         # 13-column job grid
        │   ├── MagicButton/       # One-tap execution
        │   ├── ReasoningLog/      # AI strategy display
        │   └── AdminCenter/       # User mgmt + cost tracking
        └── pages/
            ├── Dashboard.jsx
            ├── Profile.jsx
            └── Admin.jsx
```

---

## Key Concepts (from PRD V5)

### Multi-Profile Architecture
Each user manages distinct "Professional Agents" (e.g., "Infrastructure PMO", "DJ"). Every AI query **must** include `profile_id` as a mandatory parameter to prevent data leakage between identities.

### Autonomy Modes
- **Manual** — scrape & rank only
- **Co-Pilot** — AI suggests strategy → user approves → AI executes
- **Autopilot** — AI auto-applies to jobs with `match_score >= match_threshold` (default 92%)

### Magic Button Flow
1. AI tailors CV to the specific job description
2. Submits via Email (SendGrid) or Web form (Playwright)
3. Logs every step to `execution_log`
4. Updates `application_status` to `Sent`

### Security Rules
- All sensitive fields (credentials, AI persona) must be AES-256 encrypted at rest
- CV file paths must use UUID format: `storage/{user_id}/{profile_id}/{cv_uuid}.pdf`
- IDOR checks mandatory on all file access

---

## Environment Variables

Copy `backend/.env.example` to `backend/.env` and fill in:

```
DATABASE_URL=postgresql://user:password@localhost:5432/jobapp
ANTHROPIC_API_KEY=
GEMINI_API_KEY=
SENDGRID_API_KEY=
SECRET_KEY=
```
