### Overview

This repo contains a minimal Terraform + Helm solution to provision a dedicated RDS instance in an existing VPC and deploy an application to a Kubernetes cluster (with Istio) using Helm.

### Files

- terraform/: Terraform code to create the RDS instance and store credentials in Secrets Manager. Fill the `envs/*.tfvars` with your environment values.
- helm/app-chart/: Helm chart for the application. It creates a Deployment, Service, ServiceEntry (to allow egress to the DB endpoint under Istio REGISTRY_ONLY), and a DB credentials Secret.
  - the helm contains default values.yaml and specific overrides for `dev` and `prod` environments.
  - the specific value files might be located closer to the application repo or in a separate repo depending on your setup.
- deploy.sh: CI-friendly script that runs Terraform then Helm. Usage: `./deploy.sh <env>`


### Notes & assumptions

- The RDS is created in the provided private subnets; those subnets must belong to the VPC you pass via `vpc_id`.
- The VPC is assumed to be peered with the EKS cluster VPC; the Terraform security group allows traffic from provided `allowed_security_group_ids` or `allowed_cidr_blocks`.
- The script requires AWS CLI, Terraform, Helm, and jq available in the CI runner.

### Next steps / optional improvements

- Separate Terraform and Helm deployments in CI for better control.
- Use centralized secret management (e.g., AWS Secrets Manager, HashiCorp Vault) for DB credentials.
- Use a remote state backend for Terraform (S3 + DynamoDB) for team collaboration.
- Add additional validations and tests in CI (terraform validate, helm lint).
- Consider incorporating Knative for simplified deployment and scaling of the application.
