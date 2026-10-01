#!/usr/bin/env bash
# Deploy ONE stack.
# Usage: scripts/deploy.sh <project> <stack> <env>
# Example: scripts/deploy.sh url-shortener network dev
set -euo pipefail

PROJECT="${1:?project folder name, e.g. url-shortener}"
STACK="${2:?stack name, e.g. network}"
ENV_NAME="${3:-dev}"
REGION="${AWS_REGION:-ap-south-1}"

# projects/url-shortener/01-network.yaml  (the NN- prefix is only for ordering)
TEMPLATE=$(ls projects/"$PROJECT"/[0-9][0-9]-"$STACK".yaml)

# Optional extra parameters, one Key=Value per line:
# projects/<project>/params/<env>/<stack>.params
PARAM_FILE="projects/${PROJECT}/params/${ENV_NAME}/${STACK}.params"
FILE_PARAMS=()
if [ -f "$PARAM_FILE" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in ''|\#*) continue ;; esac
    FILE_PARAMS+=("$line")
  done < "$PARAM_FILE"
fi

aws cloudformation deploy \
  --region "$REGION" \
  --stack-name "${PROJECT}-${ENV_NAME}-${STACK}" \
  --template-file "$TEMPLATE" \
  --parameter-overrides ProjectName="$PROJECT" EnvName="$ENV_NAME" \
    ${FILE_PARAMS[@]+"${FILE_PARAMS[@]}"} \
  --capabilities CAPABILITY_NAMED_IAM \
  --no-fail-on-empty-changeset