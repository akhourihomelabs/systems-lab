
#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "ERROR: Run inside your cloned systems-lab repository."
  exit 1
}
cd "$ROOT"

[[ "$(basename "$ROOT")" == "systems-lab" ]] || {
  echo "ERROR: Expected repository systems-lab; found $ROOT"
  exit 1
}

git remote get-url origin >/dev/null 2>&1 || {
  echo "ERROR: Git remote 'origin' is not configured."
  exit 1
}

if [[ -n "$(git status --porcelain)" ]]; then
  echo "ERROR: Working tree is not clean. Commit or stash changes first."
  git status --short
  exit 1
fi

TARGETS=(
  "diagrams/kong-lab-architecture.mmd"
  "k8s/kong/README.md"
  "k8s/kong/00-namespace.yaml"
  "k8s/kong/01-secret.yaml"
  "k8s/kong/02-configmap.yaml"
  "k8s/kong/03-migration-job.yaml"
  "k8s/kong/04-deployment.yaml"
  "k8s/kong/05-proxy-service.yaml"
  "k8s/kong/06-admin-service.yaml"
  "k8s/kong/kustomization.yaml"
  "k8s/keycloak/README.md"
  "k8s/samples/README.md"
  "k8s/monitoring/README.md"
  "scripts/kong/README.md"
)

for file in "${TARGETS[@]}"; do
  if [[ -e "$file" ]]; then
    echo "ERROR: $file already exists. Nothing changed."
    exit 1
  fi
done

mkdir -p \
  diagrams \
  k8s/kong \
  k8s/keycloak \
  k8s/samples \
  k8s/monitoring \
  scripts/kong

cat > diagrams/kong-lab-architecture.mmd <<'EOF'
flowchart TB
    DEV["Developer on Linux Mint"] --> GIT["GitHub: systems-lab"]

    subgraph MINT["Linux Mint Host"]
        PG[("PostgreSQL 17<br/>Docker container")]
        DATA["Persistent data<br/>/data/postgres"]
        PG --> DATA
    end

    subgraph KVM["KVM Kubernetes Cluster"]
        CP["k8s-cp01<br/>Control plane"]
        W1["k8s-worker01"]
        W2["k8s-worker02"]
        CP --- W1
        CP --- W2

        subgraph KONG["Namespace: kong"]
            JOB["Migration Job"]
            GW["Kong Gateway Deployment"]
            PS["Proxy Service"]
            AS["Admin Service<br/>Internal only"]
            JOB --> GW
            PS --> GW
            AS --> GW
        end

        KC["Keycloak<br/>Future workload"]
        API["Sample API<br/>Future workload"]
        PROM["Prometheus<br/>Future workload"]
        GRAF["Grafana<br/>Future workload"]
    end

    CLIENT["Client / curl"] --> PS
    GW -->|"PostgreSQL TCP 5432"| PG
    KC -. "OIDC" .-> GW
    GW --> API
    PROM -. "Metrics" .-> GW
    GRAF --> PROM
    GIT -. "Reviewed manifests" .-> KONG
EOF

cat > k8s/kong/README.md <<'EOF'
# Kong Gateway on Kubernetes

Target: the KVM/libvirt Kubernetes cluster.

PostgreSQL initially remains in Docker on the Linux Mint host, with
persistent data under /data/postgres.

## Deployment sequence

1. Verify Kubernetes nodes and networking.
2. Establish secure, stable PostgreSQL connectivity from all worker nodes.
3. Create the namespace and configuration.
4. Create credentials without committing real secrets.
5. Run and validate the database migration Job.
6. Deploy Kong Gateway.
7. Expose the Proxy Service using a deliberate access method.
8. Keep the Admin API internal-only.
9. Validate health, logs, connectivity and metrics.

The YAML files are placeholders, not deployable manifests yet.
Implement and validate one resource at a time.
EOF

cat > k8s/kong/00-namespace.yaml <<'EOF'
# TODO: Namespace manifest.
EOF

cat > k8s/kong/01-secret.yaml <<'EOF'
# TODO: Define safe database credential handling.
# Never commit real credentials.
EOF

cat > k8s/kong/02-configmap.yaml <<'EOF'
# TODO: Non-sensitive Kong configuration.
EOF

cat > k8s/kong/03-migration-job.yaml <<'EOF'
# TODO: One-time Kong database migration Job.
EOF

cat > k8s/kong/04-deployment.yaml <<'EOF'
# TODO: Kong Gateway Deployment.
# Initial target: one replica, one container per Pod.
EOF

cat > k8s/kong/05-proxy-service.yaml <<'EOF'
# TODO: Kong Proxy Service.
EOF

cat > k8s/kong/06-admin-service.yaml <<'EOF'
# TODO: Internal-only Kong Admin Service.
EOF

cat > k8s/kong/kustomization.yaml <<'EOF'
# TODO: Add validated manifests to this Kustomization.
# Do not apply this scaffold yet.
EOF

cat > k8s/keycloak/README.md <<'EOF'
# Keycloak
Future independent identity-provider workload.
EOF

cat > k8s/samples/README.md <<'EOF'
# Sample API
Future independent backend API workload.
EOF

cat > k8s/monitoring/README.md <<'EOF'
# Monitoring
Future Prometheus and Grafana workloads.
EOF

cat > scripts/kong/README.md <<'EOF'
# Kong operational scripts

Add small, safe scripts for preflight checks, validation,
deployment and troubleshooting. Avoid one-shot bulk deployment scripts.
EOF

git add \
  diagrams/kong-lab-architecture.mmd \
  k8s/kong \
  k8s/keycloak \
  k8s/samples \
  k8s/monitoring \
  scripts/kong

git diff --cached --check
git diff --cached --stat

git commit -m "Add multi-node Kong lab scaffold"
BRANCH="$(git branch --show-current)"
git push -u origin "$BRANCH"

echo
echo "SUCCESS: Scaffold committed and pushed."
git status --short --branch

