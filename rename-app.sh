#!/usr/bin/env bash
set -euo pipefail

OLD="splunk-baseline-application"

usage() {
    echo "Usage: $0 <new-app-name>"
    echo "Example: $0 my-new-app"
    exit 1
}

[[ $# -ne 1 ]] && usage
NEW="$1"

if [[ -z "$NEW" || ! "$NEW" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Error: app name must contain only letters, numbers, hyphens, and underscores"
    exit 1
fi

FILES=(
    "app/default/app.conf"
    "app/default/inputs.conf"
    "app/default/props.conf"
    "docker-compose.yml"
)

for f in "${FILES[@]}"; do
    sed -i '' "s/$OLD/$NEW/g" "$f"
    echo "Updated $f"
done

echo
echo "Done. App renamed from '$OLD' to '$NEW'."
echo "Verify changes with: git diff"
