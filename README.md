# StratoMesh — Multi-Region GitOps & Self-Healing Cloud Platform

A local-first implementation of a secure, modular Infrastructure-as-Code and GitOps platform using Terraform, Kubernetes, Argo CD, Argo Rollouts, Prometheus, Grafana, Traefik, and cert-manager.

## Project Overview

StratoMesh demonstrates modern DevOps and cloud-native practices without requiring paid cloud infrastructure.

The platform provides:
- Modular Terraform infrastructure
- Remote Terraform state with PostgreSQL and state locking
- Kubernetes orchestration
- Frontend, backend, and PostgreSQL application stack
- NetworkPolicies, ResourceQuota, PDBs, and Sealed Secrets
- Horizontal Pod Autoscaling
- GitOps with Argo CD
- Canary deployments with automated health analysis
- Traefik ingress and cert-manager TLS
- Prometheus and Grafana monitoring
- Terraform drift detection
- Kubernetes self-healing
- Checkov security scanning
- GitHub Actions CI

## Architecture

```text
GitHub Repository
       |
       v
GitHub Actions (Terraform + Checkov)
       |
       v
Argo CD (GitOps / self-healing)
       |
       v
k3d Kubernetes Cluster
       |
       +--> Traefik Ingress
       |
       +--> Frontend Canary / Stable + HPA
                 |
                 v
             Backend + HPA
                 |
                 v
             PostgreSQL

Monitoring: Prometheus + Grafana
Security: NetworkPolicies + ResourceQuota + PDB + Sealed Secrets
Terraform State: PostgreSQL remote backend
```

## Technology Stack

| Technology | Purpose |
|---|---|
| Terraform | Infrastructure as Code |
| Docker | Container runtime |
| k3d / k3s | Local Kubernetes cluster |
| Kubernetes | Container orchestration |
| Argo CD | GitOps continuous delivery |
| Argo Rollouts | Canary deployment |
| Traefik | Ingress |
| cert-manager | TLS certificate management |
| Prometheus | Metrics collection |
| Grafana | Monitoring dashboards |
| PostgreSQL | Application database |
| Checkov | IaC security scanning |
| GitHub Actions | CI validation |
| Sealed Secrets | Kubernetes secret management |

## Repository Structure

```text
iac-free/
├── .github/workflows/terraform-ci.yml
├── envs/dev/
│   ├── main.tf
│   ├── providers.tf
│   ├── variables.tf
│   └── versions.tf
├── modules/
│   ├── network/
│   ├── storage/
│   ├── compute/
│   └── kubernetes/
│       ├── app/
│       │   ├── frontend/
│       │   ├── frontend-v1.1/
│       │   ├── backend/
│       │   └── database/
│       └── manifests/
├── scripts/
│   ├── env.ps1
│   └── env.sh
├── docker-compose.yml
├── .checkov.yaml
├── .gitignore
└── README.md
```

## Terraform Infrastructure

Terraform is organized into reusable network, storage, compute, and Kubernetes modules.

The compute module creates a hardened NGINX container using a non-root user, read-only filesystem, dropped capabilities, no-new-privileges, memory limits, restricted `/tmp`, health checks, and localhost-only port binding.

## Remote Terraform State

Terraform state is stored in PostgreSQL using the PostgreSQL backend with state locking.

```text
PostgreSQL
   |
   +-- terraform_remote_state.states
```

The PostgreSQL state server runs in Docker locally. Local Terraform state files are not stored in the repository.

## Kubernetes Cluster

The platform runs on a 3-node local k3d cluster:

```text
1 Control Plane
2 Worker Nodes
```

Example nodes:

```text
k3d-stratomesh-server-0
k3d-stratomesh-agent-0
k3d-stratomesh-agent-1
```

The cluster includes CoreDNS, Metrics Server, Traefik, and Local Path Provisioner.

## Application

### Frontend

Node.js/Express application on port `8080`. It displays frontend status, backend health, and database connectivity.

### Backend

Node.js/Express API on port `3000`.

Endpoints:

```text
/
/health
/ready
```

The backend connects to PostgreSQL using environment variables.

### Database

PostgreSQL 16 runs inside Kubernetes with persistent storage provided through a PVC.

## Kubernetes Security

### NetworkPolicy

Application traffic follows:

```text
Frontend -> Backend -> PostgreSQL
```

DNS traffic is explicitly allowed and unnecessary application-to-application traffic is blocked.

### ResourceQuota

The namespace limits CPU requests, memory requests, CPU limits, memory limits, and pod count.

### PodDisruptionBudget

PDBs ensure that at least one frontend and backend replica remains available during voluntary disruptions.

### Sealed Secrets

Database credentials are stored as an encrypted SealedSecret rather than a plaintext Kubernetes Secret.

## Horizontal Pod Autoscaling

HPA is configured for frontend and backend:

```text
Minimum replicas: 2
Maximum replicas: 10
CPU target: 70%
Memory target: 70%
```

The frontend HPA targets the Argo Rollout, while the backend HPA targets the Deployment.

### HPA Test

A CPU load test caused the frontend to scale from 2 replicas to 4+ replicas. After the load was removed, it returned to 2 replicas. This demonstrated both scale-up and scale-down behavior.

## GitOps with Argo CD

Argo CD synchronizes Kubernetes manifests from GitHub.

Application:

```text
stratomesh
```

Repository:

```text
iac-modularity-security
```

Branch:

```text
stratomesh-upgrade
```

Argo CD uses automated sync, self-healing, and pruning.

## Canary Deployment

Argo Rollouts manages frontend canary deployment.

```text
Stable version
      |
      v
Canary version
      |
      v
Prometheus health analysis
      |
      v
Progressive promotion
```

The current canary image is:

```text
stratomesh-frontend:1.1
```

The health analysis checks frontend pod readiness through Prometheus.

### Canary Limitation

The current local implementation uses replica-based canary weighting. With a small number of replicas, the actual request distribution may not exactly equal the configured percentage. Production traffic splitting would be more precise with ingress or service-mesh traffic routing.

## Ingress

Traefik is the Kubernetes ingress controller.

The local k3d load balancer exposes:

```text
HTTP  -> localhost:8081
HTTPS -> localhost:8443
```

## TLS

cert-manager is installed and includes:

- Let's Encrypt staging ClusterIssuer
- Self-signed ClusterIssuer
- Kubernetes TLS Certificate

The local environment uses the self-signed issuer for demonstration.

## Monitoring

The monitoring stack includes:

```text
Prometheus
Grafana
Alertmanager
kube-state-metrics
Node Exporter
```

Prometheus collects Kubernetes metrics and is also used by the Argo Rollouts canary analysis.

## Drift Detection

Terraform drift detection was tested with:

```powershell
terraform plan -detailed-exitcode
```

A Docker container's memory was manually changed from the declared `128 MB` to `256 MB`.

Terraform detected the drift and an apply restored the declared `128 MB` configuration.

## Self-Healing / Chaos Test

A running frontend pod was deliberately deleted. Kubernetes automatically created a replacement pod and returned the workload to the desired replica count.

```text
Running Pod
    |
    | delete
    v
Pod removed
    |
    v
Controller detects missing replica
    |
    v
Replacement Pod created
    |
    v
Pod becomes Ready
```

## Checkov Security Scan

Final Checkov result:

```text
26 passed
0 failed
0 skipped
```

## GitHub Actions

The CI workflow performs:

1. Terraform formatting check
2. Terraform initialization
3. Terraform validation
4. Checkov installation
5. Checkov security scan

The latest workflow run is green.

## Infracost

Infracost was installed and verified locally.

The current platform primarily uses Docker, k3d, local Kubernetes, and local PostgreSQL, so cloud-provider pricing is not directly representative of this local deployment.

No API credentials are stored in Git.

## Useful Commands

### Start Terraform State Database

```powershell
docker compose up -d
```

### Load Environment

```powershell
. .\scripts\env.ps1
```

### Terraform

```powershell
cd envs/dev
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

### Kubernetes

```powershell
kubectl get nodes
kubectl get pods -A
kubectl get pods -n stratomesh
```

### Argo CD

```powershell
kubectl get applications -n argocd
```

### Argo Rollouts

```powershell
kubectl argo rollouts get rollout stratomesh-frontend -n stratomesh
```

### HPA

```powershell
kubectl get hpa -n stratomesh
```

### Monitoring

```powershell
kubectl get pods -n monitoring
```

## Local Application Access

Frontend:

```text
http://127.0.0.1:8081
```

Terraform-managed NGINX test application:

```text
http://127.0.0.1:8080
```

## Important Local-vs-Cloud Limitation

This project intentionally uses a local-first architecture so the complete platform can be demonstrated without paid cloud resources.

Therefore:

- Kubernetes is local k3d.
- Terraform state PostgreSQL is local Docker infrastructure.
- Cloud-provider managed services are not used.
- Local TLS uses a self-signed certificate for demonstration.
- Infracost cloud pricing is not representative of the local setup.

The architecture can be migrated to a cloud Kubernetes platform later.

## Project Evidence

The implementation was tested with:

- Terraform apply
- Terraform drift detection
- Checkov scan
- Kubernetes health checks
- HPA scale-up
- HPA scale-down
- Argo CD synchronization
- Canary rollout
- Prometheus analysis
- Kubernetes pod self-healing
- GitHub Actions CI

## Conclusion

StratoMesh demonstrates a local-first DevOps platform combining:

```text
Infrastructure as Code
        +
Containerization
        +
Kubernetes
        +
GitOps
        +
Canary Deployment
        +
Autoscaling
        +
Security
        +
Monitoring
        +
Drift Detection
        +
Self-Healing
```

The project is designed to be reproducible, modular, security-focused, and suitable for demonstrating modern cloud-native engineering practices without requiring paid cloud infrastructure.
