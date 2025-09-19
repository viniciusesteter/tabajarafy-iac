# TabajaraFy IaC

## Requirements

You must have the following tools installed to use this project:
- **Terraform**: 1.13.2
- **AWS CLI**: 2.x (I used 2.30.1)
- **kubectl**: 1.29+ (I used 1.34.1)
- **Helm**: 3.x (I used 3.19.0)
- **Python**: 3.10+ (for stress tests) (I used 3.13.7)
- **GNU Bash**: 5.x+ (for node faileure test) (I used 5.2.37 - Git Bash)

Terraform providers:
- **aws**: 6.13.0
- **kubernetes**: 2.38.0

You also need an S3 bucket for remote Terraform state (see Quickstart).

## Overview
TabajaraFy IaC provisions a robust, production-grade AWS EKS infrastructure using Terraform, with automated application and monitoring deployment via Helm and GitHub Actions. The stack is designed for high availability, security, cost optimization and observability.

## Features
- **Infrastructure as Code:** All AWS resources (VPC, subnets, NAT, EKS, IAM, etc.) provisioned via Terraform.
- **Kubernetes Workloads:** TabajaraFy app (Nginx) deployed with Helm, including rolling updates, HPA, resource requests/limits, and anti-affinity.
- **Monitoring:** Prometheus and Grafana deployed via Helm, with pre-configured dashboards and ServiceMonitors.
- **Autoscaling:** Cluster Autoscaler and HPA for dynamic scaling.
- **CI/CD:** Automated pipeline with GitHub Actions for infra and app deployment. Is possible use for Deploy and Destroy.
- **Cost Optimization:** Spot node groups, right-sized resources, and scaling policies.
- **Security:** IAM roles with least privilege, restricted Security Groups, and RBAC.

## Project Structure
- `terraform/` – All Terraform code for AWS infra.
- `helm/` – Helm charts and values for app and monitoring.
- `k8s-tests/` – Stress and failure simulation scripts.
- `docs/` – Architecture.

## Quickstart

### 1. Bootstrap (run locally ONCE)

1.1. **Clone the repository and temporarily configure root/admin credentials:**
```sh
export AWS_ACCESS_KEY_ID=<ROOT_OR_ADMIN_KEY>
export AWS_SECRET_ACCESS_KEY=<ROOT_OR_ADMIN_SECRET>
export AWS_REGION=us-east-1
```

1.2. **Run the bootstrap to create the S3 bucket and CI/CD IAM user:**
```sh
cd terraform/bootstrap
terraform init
terraform plan
terraform apply --auto-approve
```
> This will create:
> - Remote S3 bucket for Terraform state
> - IAM user "tabajarafy-cicd" and access key
> - Minimal policy for CI/CD

1.3. **Copy the access key/secret from the output and save them in your GitHub secrets (or local .env):**
```
AWS_ACCESS_KEY_ID=<output cicd_access_key_id>
AWS_SECRET_ACCESS_KEY=<output cicd_secret_access_key>
```

### 2. Migrate Terraform backend to S3 (if needed)

2.1. **Change the Terraform backend to S3 in provider.tf:**
```hcl
terraform {
  backend "s3" {
    bucket = "tabajarafy-tf-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
```

2.2. **Migrate the local state to S3:**
```sh
cd terraform
terraform init -migrate-state
```

### 3. Full provisioning

3.1. **Configure the CI/CD user credentials:**
```sh
export AWS_ACCESS_KEY_ID=<tabajarafy-cicd>
export AWS_SECRET_ACCESS_KEY=<tabajarafy-cicd-secret>
export AWS_REGION=us-east-1
export GRAFANA_ADMIN_PASSWORD=<grafana-password> (default=admin)
```

3.2. **Full provisioning IaC:**
```sh
cd terraform
terraform init
terraform plan
terraform apply --auto-approve
```

3.3. **Update kubeconfig:**
```sh
aws eks update-kubeconfig --region us-east-1 --name tabajarafy-eks
```

### 4. Deploy Kubernetes components

4.1. **Cluster AutoScaler:**
```sh
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm repo update
helm upgrade --install cluster-autoscaler autoscaler/cluster-autoscaler \ 
  --namespace kube-system \
  --set autoDiscovery.clusterName=tabajarafy-eks \
  --set awsRegion=us-east-1 \
  --set awsAccessKeyID=$AWS_ACCESS_KEY_ID \
  --set awsSecretAccessKey=$AWS_SECRET_ACCESS_KEY
```

4.2. **Deploy monitoring:**
```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace --values helm/prometheus-grafana-values.yaml --set grafana.adminPassword=$GRAFANA_ADMIN_PASSWORD
```

4.3. **Install cluster metrics-server:**
```sh
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

4.4. **Deploy TabajaraFy application:**
```sh
helm upgrade --install tabajarafy helm/tabajarafy-chart --namespace tabajarafy --create-namespace
```

4.5. **Rollout TabajaraFy chart (after update):**
```sh
kubectl rollout restart deployment/tabajarafy-chart -n tabajarafy
kubectl rollout status deployment/tabajarafy-chart -n tabajarafy --timeout=60s
```

4.6. **Get LoadBalancer endpoint:**
```sh
kubectl get svc -n tabajarafy
```

### How to destroy everything

To completely remove all infrastructure and Kubernetes components created by this project, follow these steps (can be done manually or via CI/CD):

1. **Uninstall Helm applications:**
  ```sh
  helm uninstall tabajarafy --namespace tabajarafy
  helm uninstall monitoring --namespace monitoring
  helm uninstall cluster-autoscaler --namespace kube-system
  ```

2. **Destroy all infrastructure with Terraform:**
  ```sh
  cd terraform
  terraform init
  terraform plan
  terraform destroy -auto-approve
  ```

This will remove all AWS resources (EKS, node groups, VPC, IAM, etc.) and all Kubernetes workloads and monitoring stacks. Make sure you have the correct credentials and region set before running these commands.

## Observability

- **Grafana:** Access via LoadBalancer or port-forward. Get admin password:
  ```sh
  kubectl --namespace monitoring get secrets monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo
  ```
- **Prometheus:** Pre-configured as Grafana data source.
- **Metrics Cluster:** Get metrics of pods inside cluster.

## Testing & Validation

- **Stress Test:** Run the Python script in `k8s-tests/stress_test.py` to generate external load and trigger HPA.
- **Node Failure Simulation:** Use the script in `k8s-tests/node_failure_test.sh` to use kill one node (if necessary, example running together with stress test), simulating a node failure and validating pod rescheduling and cluster recovery. Run `bash k8s-tests/node_failure_test.sh`
- **Metrics Server:** The metrics-server is automatically installed via CI/CD to enable resource metrics for HPA and `kubectl top` commands. Validate with: `kubectl top pods -n tabajarafy`


## Cost Optimization Tips

- Use spot instances for node groups.
- Tune HPA and resource requests/limits.
- Scale down during off-peak hours. **Not deployed.**

## Terraform Outputs

The following outputs will be available after applying the Terraform configuration:

- `cluster_endpoint`
- `cluster_name`