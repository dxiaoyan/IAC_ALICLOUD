# 礼来阿里云 IAC 项目

本仓库是面向礼来在阿里云上的全新 IAC（Terraform + Terragrunt）项目结构。

## 覆盖范围

- 基础设施类服务：OSS、NAS、Backup、RDS PostgreSQL、Redis、ECS、ACS、ALB、CDN
- 平台类服务：KMS、RAM、SLS、ACR、FC、EventBridge、MNS、DataWorks
- 网络与安全：VPC 输入（来自账号工厂）、安全组（SG）、网络 ACL（NACL）

## 目录结构

- `modules/`：按服务拆分的 Terraform 模块
- `live/`：按环境（`dev`、`qa`、`prd`）组织的 Terragrunt 实例配置
- `docs/`：架构说明与运维指南
- `.github/workflows/`：GitHub Actions 流水线
- `pipelines/`：历史占位目录（已弃用）
- `scripts/`：本地执行辅助脚本

## 快速开始

1. 填写 `live/<env>/cn-shanghai/env.hcl` 的环境参数。
2. 在 `terragrunt.hcl` 中更新远端状态后端（backend）占位参数。
3. 对单个组件执行 `plan`：
   - `cd live/dev/cn-shanghai/kms`
   - `terragrunt init`
   - `terragrunt plan`
4. 按分阶段顺序执行：
   - `scripts/run_stage.ps1 -Env dev -Action plan`
   - `scripts/run_stage.ps1 -Env dev -Action apply`

### 默认 VPC 测试网段

- `dev`：`10.210.0.0/20`
- `qa`：`10.210.16.0/20`
- `prd`：`10.210.32.0/20`

## GitHub Actions

### 工作流说明

- `terraform-pr-checks.yml`
  - 触发：`Pull Request`
  - 主要步骤：`terraform fmt -check`、模块级 `terraform validate`、`tfsec` 高危门禁（HIGH/CRITICAL）
  - 安全结果输出：生成 `tfsec.sarif`
    - 当 `ENABLE_CODE_SCANNING_UPLOAD=true` 时上传到 GitHub Code Scanning
    - 否则上传为 workflow artifact

- `terraform-manual-deploy.yml`
  - 触发：手动（`workflow_dispatch`）
  - 输入参数：
    - `environment`：`dev|qa|prd`
    - `action`：`plan|apply|destroy`
    - `component`：组件名或 `all`
    - `confirm_token`：当 `environment=prd` 且 `action=apply` 时必须为 `APPLY_PRD`

- `terraform-kics-scan.yml`
  - 触发：`main` 分支 push + 每周定时 + 手动触发
  - 主要步骤：`KICS` 扫描（非阻断）
  - 安全结果输出：生成 `kics-results/results.sarif`
    - 当 `ENABLE_CODE_SCANNING_UPLOAD=true` 时上传到 GitHub Code Scanning
    - 否则上传为 workflow artifact

### 必需的仓库 Secrets

- `ALICLOUD_ACCESS_KEY`
- `ALICLOUD_SECRET_KEY`
- `ALICLOUD_REGION`（可选，也可由代码默认值提供）

### 可选的仓库 Variables

- `ENABLE_CODE_SCANNING_UPLOAD`
  - 取值：`true` / `false`
  - 建议：若仓库已启用 GitHub Advanced Security，设置为 `true`

## Linux 执行命令

### 安装 Terraform 与 Terragrunt（Ubuntu 示例）

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

### 执行单个组件（Linux）

```bash
cd live/dev/cn-shanghai/kms
terragrunt init --terragrunt-non-interactive
terragrunt plan --terragrunt-non-interactive
```

### 分阶段执行 Plan/Apply（Linux）

```bash
# stage 1
for c in kms ram sls vpc_inputs; do
  (cd "live/dev/cn-shanghai/$c" && terragrunt init --terragrunt-non-interactive && terragrunt plan --terragrunt-non-interactive)
done
```

### 本地安全扫描（Linux）

```bash
# 安装 tfsec
TFSEC_VERSION="v1.28.11"
curl -sSL "https://github.com/aquasecurity/tfsec/releases/download/${TFSEC_VERSION}/tfsec-linux-amd64" -o tfsec
chmod +x tfsec && sudo mv tfsec /usr/local/bin/tfsec

# tfsec 门禁（与 PR 同策略）
tfsec modules --minimum-severity HIGH --no-color
```

```bash
# 使用 Docker 本地执行 KICS（非阻断风格）
docker run --rm -t -v "$(pwd):/path" checkmarx/kics:latest scan \
  -p /path/modules,/path/live \
  --ci \
  --report-formats sarif,json \
  --output-path /path/kics-results
```

## 说明

- 本脚手架保持简洁，且与阿里云 Provider 实践对齐。
- 由账号工厂统一管理的资源应作为输入/数据源引用，不应在此仓库重复创建。
