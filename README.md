# Lilly Alibaba Cloud IAC

This repository is a fresh IAC project structure designed for Lilly on Alibaba Cloud.

## Scope

- Infrastructure services: OSS, NAS, Backup, RDS PostgreSQL, Redis, ECS, ACS, ALB, CDN
- Platform services: KMS, RAM, SLS, ACR, FC, EventBridge, MNS, DataWorks
- Network and security: VPC inputs (from account factory), Security Group, NACL

## Structure

- `modules/`: Terraform modules by service
- `live/`: Terragrunt live configurations by environment (`dev`, `qa`, `prd`)
- `docs/`: architecture and operating guidance
- `.github/workflows/`: GitHub Actions workflows
- `pipelines/`: deprecated placeholder
- `scripts/`: local run helpers

## Quick Start

1. Fill `live/<env>/cn-shanghai/env.hcl` values.
2. Update state backend placeholders in `terragrunt.hcl`.
3. Run plan for one component:
   - `cd live/dev/cn-shanghai/kms`
   - `terragrunt init`
   - `terragrunt plan`
4. Run staged apply in order:
   - `scripts/run_stage.ps1 -Env dev -Action plan`
   - `scripts/run_stage.ps1 -Env dev -Action apply`

### Default VPC Test CIDR

- `dev`: `10.210.0.0/20`
- `qa`: `10.210.16.0/20`
- `prd`: `10.210.32.0/20`

## GitHub Actions

### Workflows

- `terraform-pr-checks.yml`
  - Trigger: Pull Request
  - Steps: `terraform fmt -check`, module `terraform validate`, `tfsec` gate (HIGH/CRITICAL), SARIF upload

- `terraform-manual-deploy.yml`
  - Trigger: manual (`workflow_dispatch`)
  - Inputs:
    - `environment`: `dev|qa|prd`
    - `action`: `plan|apply|destroy`
    - `component`: component name or `all`
    - `confirm_token`: must be `APPLY_PRD` when `environment=prd` and `action=apply`

- `terraform-kics-scan.yml`
  - Trigger: `main` push + weekly schedule + manual
  - Steps: `KICS` scan (non-blocking), SARIF upload

### Required Repository Secrets

- `ALICLOUD_ACCESS_KEY`
- `ALICLOUD_SECRET_KEY`
- `ALICLOUD_REGION` (optional, default can still come from code)

## Linux Commands

### Install Terraform & Terragrunt (Ubuntu example)

```bash
# Terraform
wget -q https://releases.hashicorp.com/terraform/1.8.5/terraform_1.8.5_linux_amd64.zip -O terraform.zip
unzip terraform.zip
sudo mv terraform /usr/local/bin/
terraform version

# Terragrunt
TG_VERSION="0.63.6"
wget -q "https://github.com/gruntwork-io/terragrunt/releases/download/v${TG_VERSION}/terragrunt_linux_amd64"
chmod +x terragrunt_linux_amd64
sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt
terragrunt --version
```

### Run One Component (Linux)

```bash
cd live/dev/cn-shanghai/kms
terragrunt init --terragrunt-non-interactive
terragrunt plan --terragrunt-non-interactive
```

### Run Staged Plan/Apply (Linux)

```bash
# stage 1
for c in kms ram sls vpc_inputs; do
  (cd "live/dev/cn-shanghai/$c" && terragrunt init --terragrunt-non-interactive && terragrunt plan --terragrunt-non-interactive)
done
```

### Local Security Scan (Linux)

```bash
# install tfsec
TFSEC_VERSION="v1.28.11"
curl -sSL "https://github.com/aquasecurity/tfsec/releases/download/${TFSEC_VERSION}/tfsec-linux-amd64" -o tfsec
chmod +x tfsec && sudo mv tfsec /usr/local/bin/tfsec

# tfsec gate (same policy as PR)
tfsec modules --minimum-severity HIGH --no-color
```

```bash
# run KICS locally with docker (non-blocking style)
docker run --rm -t -v "$(pwd):/path" checkmarx/kics:latest scan \
  -p /path/modules,/path/live \
  --ci \
  --report-formats sarif,json \
  --output-path /path/kics-results
```

## Notes

- This scaffold is intentionally clean and provider-aligned for Alibaba Cloud.
- Account factory managed resources should be consumed as inputs/data sources, not recreated.
