# Eventgen Integration Design

**Date:** 2026-05-08
**Issue:** #11
**Status:** Approved

## Summary

Add optional SA-Eventgen configuration to the template as a separate Splunk app directory (`eventgen/`). Users delete it if not needed. Targets Splunk Enterprise only. SA-Eventgen installed manually by the user.

## Directory Structure

```
splunk-baseline-application/
├── app/                                # main app (unchanged)
├── eventgen/                           # delete this dir if not needed
│   ├── default/
│   │   └── eventgen.conf
│   └── samples/
│       └── example.log
└── docker-compose.yml
```

`eventgen/` is a valid Splunk app. SA-Eventgen reads `eventgen.conf` from all installed apps automatically — no code required.

## docker-compose Changes

Add a commented-out volume mount. Users uncomment to enable:

```yaml
volumes:
  - ./app:/opt/splunk/etc/apps/splunk-baseline-application
  # Eventgen config — uncomment to enable (requires SA-Eventgen installed)
  # - ./eventgen:/opt/splunk/etc/apps/splunk-baseline-application-eventgen
```

SA-Eventgen itself is not managed by docker-compose — user installs it to the Splunk instance manually.

## eventgen.conf

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

## samples/example.log

One line of representative JSON matching what `collect.py` produces:

```json
{"host": "example-host", "status": "ok", "value": 42}
```

Users replace with realistic sample data for their sourcetype.

## README Section

New section: **Eventgen (optional synthetic data)**

1. Prerequisites: download SA-Eventgen from Splunkbase, install to Splunk instance
2. Enable: uncomment volume mount in `docker-compose.yml`, restart
3. Customize: edit `eventgen/default/eventgen.conf` and `eventgen/samples/`
4. Remove: delete `eventgen/` dir and remove commented volume line

Includes prominent production safety callout:
> Never deploy `eventgen/` to production. It is for local/dev only. Add `eventgen/` to your deployment exclusion list.

No separate `docs/eventgen.md` — README is sufficient for a template repo this size.

## Production Safety

- `eventgen/` is never deployed to prod by default — it requires an explicit opt-in volume mount
- README callout makes the risk explicit
- Users deleting the dir removes all risk

## Out of Scope

- Splunk Cloud support
- Automatic SA-Eventgen download/install
- docker-compose.override.yml pattern
