# Eventgen Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add optional SA-Eventgen configuration as a separate Splunk app directory (`eventgen/`) so template users can generate synthetic data in dev/local environments.

**Architecture:** `eventgen/` is a standalone Splunk app mounted via docker-compose volume. SA-Eventgen (installed separately) auto-discovers `eventgen.conf` from all Splunk apps. Users uncomment one line in docker-compose to enable; delete the directory to remove.

**Tech Stack:** Splunk SA-Eventgen, Splunk Enterprise (Docker), docker-compose

---

### Task 1: Create feature branch

**Files:**
- No file changes — git only

- [ ] **Step 1: Create and switch to feature branch**

```bash
git checkout -b feat/eventgen-support
```

Expected: `Switched to a new branch 'feat/eventgen-support'`

---

### Task 2: Create eventgen app skeleton

**Files:**
- Create: `eventgen/default/eventgen.conf`
- Create: `eventgen/samples/example.log`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p eventgen/default eventgen/samples
```

- [ ] **Step 2: Create eventgen.conf**

Create `eventgen/default/eventgen.conf` with this exact content:

```ini
[example.log]
interval = 60
count = 5
earliest = -60s
latest = now
outputMode = splunk
index = main
sourcetype = splunk-baseline-application
```

- `[example.log]` — matches the sample file name in `eventgen/samples/`
- `interval = 60` — generate events every 60 seconds
- `count = 5` — generate 5 events per interval
- `outputMode = splunk` — write directly to Splunk's index pipeline

- [ ] **Step 3: Create sample data file**

Create `eventgen/samples/example.log` with this exact content (one line):

```json
{"host": "example-host", "status": "ok", "value": 42}
```

SA-Eventgen replays lines from this file to generate synthetic events. Replace with realistic JSON matching your actual `collect.py` output.

- [ ] **Step 4: Verify structure**

```bash
find eventgen/ -type f
```

Expected output:
```
eventgen/default/eventgen.conf
eventgen/samples/example.log
```

- [ ] **Step 5: Commit**

```bash
git add eventgen/
git commit -m "feat(eventgen): add SA-Eventgen config app skeleton"
```

---

### Task 3: Update docker-compose.yml

**Files:**
- Modify: `docker-compose.yml`

Current `docker-compose.yml`:

```yaml
services:
  splunk:
    image: splunk/splunk:latest
    container_name: splunk
    environment:
      SPLUNK_START_ARGS: --accept-license
      SPLUNK_GENERAL_TERMS: --accept-sgt-current-at-splunk-com
      SPLUNK_PASSWORD: admin123
    ports:
      - "8000:8000"
      - "8089:8089"
    volumes:
      - ./app:/opt/splunk/etc/apps/splunk-baseline-application
```

- [ ] **Step 1: Add commented Eventgen volume mount**

Replace the `volumes:` block with:

```yaml
    volumes:
      - ./app:/opt/splunk/etc/apps/splunk-baseline-application
      # Eventgen config — uncomment to enable (requires SA-Eventgen installed)
      # - ./eventgen:/opt/splunk/etc/apps/splunk-baseline-application-eventgen
```

- [ ] **Step 2: Verify docker-compose is valid**

```bash
docker compose config --quiet
```

Expected: no output, exit code 0. If errors appear, check yaml indentation.

- [ ] **Step 3: Commit**

```bash
git add docker-compose.yml
git commit -m "feat(eventgen): add commented Eventgen volume mount to docker-compose"
```

---

### Task 4: Update README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add Eventgen section to README**

Append the following section to `README.md` after the existing "Test with Docker" section (after line 85, before end of file):

```markdown

## Eventgen (optional synthetic data)

[SA-Eventgen](https://splunkbase.splunk.com/app/1924) generates synthetic events from sample data. Use it to develop and test dashboards, alerts, and correlation searches without real data.

> **Never deploy `eventgen/` to production.** It is for local/dev only. Add `eventgen/` to your deployment exclusion list (deployment server, CI pipeline, or `.splunkignore`).

### Prerequisites

1. Download SA-Eventgen from [Splunkbase](https://splunkbase.splunk.com/app/1924)
2. Install it to your Splunk instance via **Apps > Manage Apps > Install app from file**

### Enable

1. Uncomment the Eventgen volume mount in `docker-compose.yml`:
   ```yaml
   - ./eventgen:/opt/splunk/etc/apps/splunk-baseline-application-eventgen
   ```
2. Restart the container:
   ```bash
   docker compose restart splunk
   ```

### Customize

- Edit `eventgen/default/eventgen.conf` — adjust `interval`, `count`, `index`, and `sourcetype`
- Replace `eventgen/samples/example.log` with realistic JSON matching your `collect.py` output

### Remove

Delete the `eventgen/` directory and remove the commented volume line from `docker-compose.yml`.
```

- [ ] **Step 2: Verify README renders correctly**

```bash
cat README.md | grep -A 30 "Eventgen"
```

Expected: the full Eventgen section appears with correct headings and code blocks.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs(eventgen): add Eventgen setup instructions to README"
```

---

### Task 5: Push and open PR

**Files:**
- No file changes — git only

- [ ] **Step 1: Push branch**

```bash
git push -u origin feat/eventgen-support
```

- [ ] **Step 2: Open PR**

```bash
gh pr create \
  --title "feat: add optional SA-Eventgen support" \
  --body "$(cat <<'EOF'
## Summary

- Adds `eventgen/` as a separate Splunk app with SA-Eventgen config and sample data
- Adds commented-out volume mount in `docker-compose.yml` (opt-in)
- Documents setup, customization, and removal in README

Closes #11

## Test plan

- [ ] `docker compose config --quiet` passes with no errors
- [ ] `find eventgen/ -type f` shows both config files
- [ ] README Eventgen section renders correctly on GitHub
EOF
)" \
  --assignee "@me"
```
