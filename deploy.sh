#!/usr/bin/env bash
set -euo pipefail

# Usage: ./deploy.sh <env>
# GitOps mode: image tag and other environment-specific app configuration should live in
# helm/app-chart/values-<env>.yaml (or in the chart's values.yaml).
ENV=${1:-dev}
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR="$ROOT_DIR/tmp"
mkdir -p "$TMP_DIR"

# In a real-world scenario, consider separating infra provisioning and app deployment steps.
# This is a simplified example for demonstration purposes.
cd "$ROOT_DIR/terraform"
terraform init -input=false
terraform apply -var-file="envs/${ENV}.tfvars" -auto-approve

terraform output -json > "$TMP_DIR/terraform_outputs.json"

DB_HOST=$(jq -r '.db_host.value' "$TMP_DIR/terraform_outputs.json")
DB_PORT=$(jq -r '.db_port.value' "$TMP_DIR/terraform_outputs.json")
DB_SECRET_ARN=$(jq -r '.db_secret_arn.value' "$TMP_DIR/terraform_outputs.json")

# retrieve password from secrets manager only for the sake of the example
DB_PASSWORD_JSON=$(aws secretsmanager get-secret-value --secret-id "$DB_SECRET_ARN" --query SecretString --output text)
DB_PASSWORD=$(echo "$DB_PASSWORD_JSON" | jq -r '.password')
DB_USER=$(echo "$DB_PASSWORD_JSON" | jq -r '.username')

# deploy helm chart
HELM_CHART_DIR="$ROOT_DIR/helm/app-chart"
HELM_BASE_VALUES_FILE="$HELM_CHART_DIR/values.yaml"
HELM_ENV_VALUES_FILE="$HELM_CHART_DIR/values-${ENV}.yaml"
# build a simple space-separated string of -f args (simpler syntax)
HELM_VALUES_ARGS=""
if [ -f "$HELM_BASE_VALUES_FILE" ]; then
  HELM_VALUES_ARGS="$HELM_VALUES_ARGS -f $HELM_BASE_VALUES_FILE"
fi
if [ -f "$HELM_ENV_VALUES_FILE" ]; then
  HELM_VALUES_ARGS="$HELM_VALUES_ARGS -f $HELM_ENV_VALUES_FILE"
fi

# Value files from Helm are "source of truth" for image tags (GitOps-style).
# We still inject DB connection info only for the sake of the example.
# In a real-world scenario, consider using Kubernetes Secrets for sensitive info like DB passwords.
# The best use ConfigMaps and Secrets for such configurations synchronized with central Vault or AWS Secrets Manager.

helm upgrade --install feature-app "$HELM_CHART_DIR" \
  --namespace "$ENV" --create-namespace \
  $HELM_VALUES_ARGS \
  --set db.host="$DB_HOST" \
  --set db.port="$DB_PORT" \
  --set db.user="$DB_USER" \
  --set-string db.password="$DB_PASSWORD"

echo "Deployment complete. App deployed to namespace '$ENV' and connected to DB at $DB_HOST:$DB_PORT"
