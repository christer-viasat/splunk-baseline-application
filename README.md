# splunk-baseline-application

Minimal Splunk scripted input template. Collects data from an external source and writes JSON to stdout for Splunk ingestion.

## Structure

```
splunk-baseline-application/
├── app/                        # Splunk app — mount this to the container
│   ├── app.conf
│   ├── bin/
│   │   └── collect.py          # Implement get_data() here
│   ├── default/
│   │   ├── inputs.conf
│   │   ├── props.conf
│   │   └── transforms.conf
│   ├── lookups/
│   ├── static/
│   │   ├── appIcon.png         # 36x36 — replace with your icon
│   │   └── appIcon_2x.png      # 72x72 — replace with your icon (retina)
│   └── metadata/
│       └── default.meta
├── docker-compose.yml
├── .editorconfig
├── .gitignore
└── README.md
```

## Usage

### As a template for new apps

```bash
gh repo create my-new-app --template=christer-viasat/splunk-baseline-application --clone
cd my-new-app
```

Then:

**Rename the app** — replace `splunk-baseline-application` with your app name in every location:

| File | Location |
|------|----------|
| `app/app.conf` | `id=` field |
| `app/default/inputs.conf` | script path and `sourcetype =` |
| `app/default/props.conf` | stanza header `[...]` |
| `docker-compose.yml` | volume mount path |

Then configure:
1. Update `app/app.conf` — fill in `author` and `description`
2. Implement `get_data()` in `app/bin/collect.py`
3. Update `app/default/inputs.conf` — set `interval` and `index`
4. Replace `app/static/appIcon.png` (36x36) and `app/static/appIcon_2x.png` (72x72) with your own icon

### App icon

Splunk requires two sizes:

| File | Size |
|------|------|
| `app/static/appIcon.png` | 36×36 px |
| `app/static/appIcon_2x.png` | 72×72 px (retina) |

Placeholder icons are included. Replace both files with PNG images of the correct dimensions.

### Test with Docker

```bash
docker compose up -d
```

> **Apple Silicon (ARM64):** Add `platform: linux/arm64` to the `splunk` service in `docker-compose.yml`.

Verify script runs:
```bash
docker exec splunk /opt/splunk/bin/splunk cmd python3 \
  /opt/splunk/etc/apps/my-new-app/bin/collect.py
```

Verify ingestion:
```bash
docker exec splunk /opt/splunk/bin/splunk search \
  "index=main sourcetype=my-new-app" \
  -auth admin:admin123
```
