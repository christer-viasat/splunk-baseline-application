# splunk-baseline-application

Minimal Splunk scripted input template. Collects data from an external source and writes JSON to stdout for Splunk ingestion.

## Usage

### As a template for new apps

```bash
gh repo create my-new-app --template=christer-viasat/splunk-baseline-application --clone
cd my-new-app
```

Then:
1. Update `app.conf` — fill in `author` and `description`
2. Implement `get_data()` in `bin/collect.py`
3. Update `default/inputs.conf` — set `interval` and `index`
4. Update `default/props.conf` — adjust time parsing if needed

### Test with Docker

```bash
docker run -d \
  -p 8000:8000 -p 8089:8089 \
  -e SPLUNK_START_ARGS='--accept-license' \
  -e SPLUNK_PASSWORD='admin123' \
  -v $(pwd):/opt/splunk/etc/apps/my-new-app \
  splunk/splunk:latest
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
