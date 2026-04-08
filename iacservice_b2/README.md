# IacService B2 Project

This directory is a standalone project template for:

- GitHub Actions direct-to-IacService deployment (`B2` mode)
- Approval model aligned with existing flow: `plan -> manual approval -> apply`
- No changes to the current root Terragrunt deployment workflows

## Structure

- `modules/`: reusable Terraform modules copied from current implemented modules (`vpc_inputs`, `sg`, `ecs`)
- `stacks/`: IacService stack definitions (`tfcomponent.yaml`)
- `deployments/`: per-environment deployment instances (`profile.yaml`, `tfdeploy.yaml`)
- `scripts/`: direct IacService API scripts
- `.github/workflows/iacservice-manual-deploy.yml`: manual deploy workflow template

## Workflow Model

The workflow in this project supports:

1. `action=plan`
- Build package with selected profile
- Upload package to IacService module
- Trigger `terraform plan`
- Poll and export plan result

2. `action=apply`
- Run plan first (same run)
- Wait for GitHub Environment approval
- Trigger `terraform apply` using the same module version from plan
- Poll and export apply result

3. `action=destroy`
- Run normal plan first (same run, action `terraform plan`)
- Wait for GitHub Environment approval
- Trigger `terraform destroy` using the same module version from plan stage
- Poll and export destroy result

4. Approval policy
- `action=plan`: no approval required (plan job does not bind GitHub Environment)
- `action=apply` or `action=destroy`: approval required (single approval at `approval` job)

5. `prd` protection
- When `environment=prd` and `action=apply/destroy`, requires `confirm_token=APPLY_PRD`

## Required GitHub Environment Secrets

Configure these in each Environment (`dev`, `qa`, `prd`):

- `ALICLOUD_ACCESS_KEY`
- `ALICLOUD_SECRET_KEY`
- `IAC_CODE_MODULE_ID` (recommended)
- `ALICLOUD_REGION` (optional; fallback to `profile.yaml` or default `cn-zhangjiakou`)

## Profile Field Rules

- In `deployments/<env>/profile.yaml`, `account_id` / `code_module_id` can be either:
  - literal values, or
  - environment variable names (for example `LILLY_DEV_MODULE_ID`).
- `region` in `profile.yaml` is the **IacService API region** (recommended `cn-zhangjiakou`).
- Terraform resource deployment region is controlled in `tfdeploy.yaml` `deployment[].inputs.region`
  (for this project it stays `cn-shanghai`).

## Notes

- This directory is intentionally isolated; root workflows under `.github/workflows` are untouched.
- If you want to run this workflow in a separate repository, copy this entire directory as project root.
- In this mono-repo, the workflow file is stored under `iacservice_b2/.github/workflows/` as template content.
