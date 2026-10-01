#!/usr/bin/env bash
# Deploy every stack of a project in numeric order.
# Stacks with no changes finish instantly.
# Usage: scripts/deploy-all.sh <project> <env>
set -euo pipefail

PROJECT="${1:?project}"
ENV_NAME="${2:-dev}"

for FILE in projects/"$PROJECT"/[0-9][0-9]-*.yaml; do
  NAME=$(basename "$FILE" .yaml)   # 01-network
  STACK="${NAME#*-}"               # network
  echo "=== ${PROJECT}-${ENV_NAME}-${STACK} ==="
  "$(dirname "$0")/deploy.sh" "$PROJECT" "$STACK" "$ENV_NAME"
done