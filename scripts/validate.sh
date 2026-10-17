#!/usr/bin/env bash
# Render every environment + the app-of-apps and validate against Kubernetes / Argo CD schemas.
set -euo pipefail
cd "$(dirname "$0")/.."
K8S_VERSION="${K8S_VERSION:-1.31.0}"
CRD_SCHEMAS='https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'
out="$(mktemp -d)"; trap 'rm -rf "$out"' EXIT

for env in environments/*/; do
  name="$(basename "$env")"
  echo "==> rendering web-service for ${name}"
  helm template web-service charts/web-service \
    --namespace "web-${name}" -f "${env}values.yaml" > "${out}/${name}.yaml"
done
echo "==> rendering app-of-apps"
helm template apps argocd/apps --namespace argocd > "${out}/apps.yaml"
cp argocd/root-app.yaml "${out}/root-app.yaml"

kubeconform -strict -summary -kubernetes-version "${K8S_VERSION}" \
  -schema-location default -schema-location "${CRD_SCHEMAS}" \
  "${out}"/*.yaml
