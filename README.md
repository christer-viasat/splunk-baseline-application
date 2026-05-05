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
1. Update `app/app.conf` — fill in `author` and `description`
2. Implement `get_data()` in `app/bin/collect.py`
3. Update `app/default/inputs.conf` — set `interval` and `index`
4. Update `docker-compose.yml` — change app name in the volume path

### Test with Docker

```bash
docker compose up -d
```

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
