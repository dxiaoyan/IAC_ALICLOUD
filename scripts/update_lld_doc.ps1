param(
  [string]$DocxPath = "礼来  ALI IAC LLD-V20260403.docx"
)

$ErrorActionPreference = "Stop"

function New-WordParagraph {
  param(
    [System.Xml.XmlDocument]$XmlDoc,
    [string]$Text,
    [string]$StyleId = "",
    [switch]$PreserveSpace
  )

  $wNs = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

  $p = $XmlDoc.CreateElement("w", "p", $wNs)

  if ($StyleId -ne "") {
    $pPr = $XmlDoc.CreateElement("w", "pPr", $wNs)
    $pStyle = $XmlDoc.CreateElement("w", "pStyle", $wNs)
    $styleAttr = $XmlDoc.CreateAttribute("w", "val", $wNs)
    $styleAttr.Value = $StyleId
    [void]$pStyle.Attributes.Append($styleAttr)
    [void]$pPr.AppendChild($pStyle)
    [void]$p.AppendChild($pPr)
  }

  $lines = $Text -split "`r?`n"
  $r = $XmlDoc.CreateElement("w", "r", $wNs)

  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($i -gt 0) {
      [void]$r.AppendChild($XmlDoc.CreateElement("w", "br", $wNs))
    }

    $t = $XmlDoc.CreateElement("w", "t", $wNs)
    if ($PreserveSpace -or $lines[$i].StartsWith(" ") -or $lines[$i].EndsWith(" ")) {
      $spaceAttr = $XmlDoc.CreateAttribute("xml", "space", "http://www.w3.org/XML/1998/namespace")
      $spaceAttr.Value = "preserve"
      [void]$t.Attributes.Append($spaceAttr)
    }
    $t.InnerText = $lines[$i]
    [void]$r.AppendChild($t)
  }

  [void]$p.AppendChild($r)
  return $p
}

function New-WordTable {
  param(
    [System.Xml.XmlDocument]$XmlDoc,
    [object[][]]$Rows
  )

  $wNs = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  $tbl = $XmlDoc.CreateElement("w", "tbl", $wNs)

  $tblPr = $XmlDoc.CreateElement("w", "tblPr", $wNs)

  $tblW = $XmlDoc.CreateElement("w", "tblW", $wNs)
  $tblWType = $XmlDoc.CreateAttribute("w", "type", $wNs)
  $tblWType.Value = "auto"
  [void]$tblW.Attributes.Append($tblWType)
  $tblWW = $XmlDoc.CreateAttribute("w", "w", $wNs)
  $tblWW.Value = "0"
  [void]$tblW.Attributes.Append($tblWW)
  [void]$tblPr.AppendChild($tblW)

  $tblBorders = $XmlDoc.CreateElement("w", "tblBorders", $wNs)
  foreach ($borderName in @("top", "left", "bottom", "right", "insideH", "insideV")) {
    $border = $XmlDoc.CreateElement("w", $borderName, $wNs)

    $valAttr = $XmlDoc.CreateAttribute("w", "val", $wNs)
    $valAttr.Value = "single"
    [void]$border.Attributes.Append($valAttr)

    $szAttr = $XmlDoc.CreateAttribute("w", "sz", $wNs)
    $szAttr.Value = "4"
    [void]$border.Attributes.Append($szAttr)

    $spaceAttr = $XmlDoc.CreateAttribute("w", "space", $wNs)
    $spaceAttr.Value = "0"
    [void]$border.Attributes.Append($spaceAttr)

    $colorAttr = $XmlDoc.CreateAttribute("w", "color", $wNs)
    $colorAttr.Value = "auto"
    [void]$border.Attributes.Append($colorAttr)

    [void]$tblBorders.AppendChild($border)
  }
  [void]$tblPr.AppendChild($tblBorders)
  [void]$tbl.AppendChild($tblPr)

  foreach ($row in $Rows) {
    $tr = $XmlDoc.CreateElement("w", "tr", $wNs)
    foreach ($cellText in $row) {
      $tc = $XmlDoc.CreateElement("w", "tc", $wNs)
      $cellValue = [string]$cellText

      $tcPr = $XmlDoc.CreateElement("w", "tcPr", $wNs)
      $tcW = $XmlDoc.CreateElement("w", "tcW", $wNs)
      $tcWType = $XmlDoc.CreateAttribute("w", "type", $wNs)
      $tcWType.Value = "auto"
      [void]$tcW.Attributes.Append($tcWType)
      $tcWW = $XmlDoc.CreateAttribute("w", "w", $wNs)
      $tcWW.Value = "0"
      [void]$tcW.Attributes.Append($tcWW)
      [void]$tcPr.AppendChild($tcW)
      [void]$tc.AppendChild($tcPr)

      [void]$tc.AppendChild((New-WordParagraph -XmlDoc $XmlDoc -Text $cellValue -PreserveSpace))
      [void]$tr.AppendChild($tc)
    }
    [void]$tbl.AppendChild($tr)
  }

  return $tbl
}

function Add-BodyParagraph {
  param(
    [System.Xml.XmlDocument]$XmlDoc,
    [System.Xml.XmlElement]$Body,
    [string]$Text,
    [string]$StyleId = ""
  )

  [void]$Body.AppendChild((New-WordParagraph -XmlDoc $XmlDoc -Text $Text -StyleId $StyleId -PreserveSpace))
}

$resolvedDocx = (Resolve-Path $DocxPath).Path
$docDir = Split-Path -Parent $resolvedDocx
$docName = Split-Path -Leaf $resolvedDocx
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = Join-Path $docDir ($docName + ".bak-" + $timestamp)

Copy-Item -LiteralPath $resolvedDocx -Destination $backupPath -Force

$workRoot = Join-Path $docDir ".tg-cache\docx-edit-$timestamp"
if (Test-Path $workRoot) {
  Remove-Item -LiteralPath $workRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $workRoot | Out-Null

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($resolvedDocx, $workRoot)

$documentXmlPath = Join-Path $workRoot "word\document.xml"
[xml]$documentXml = Get-Content -LiteralPath $documentXmlPath -Raw -Encoding UTF8

$wNs = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
$body = $documentXml.document.body
$sectPr = $body.sectPr.CloneNode($true)

while ($body.HasChildNodes) {
  [void]$body.RemoveChild($body.FirstChild)
}

$today = Get-Date -Format "yyyy-MM-dd"

Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "版本记录："
[void]$body.AppendChild((New-WordTable -XmlDoc $documentXml -Rows @(
  @("版本号", "版本日期", "修改人", "修改记录"),
  @("V20260403", $today, "Codex", "基于当前 lilly_iac_alicloud 仓库结构、Terragrunt 编排方式、GitHub Actions 流水线与阿里云 backend 重写 LLD，移除旧项目遗留内容。")
)))

Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "礼来 ALI IAC LLD" -StyleId "2"

Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "代码仓库规范" -StyleId "3"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '当前项目采用单一 GitHub 仓库 `lilly_iac_alicloud` 管理 Terraform modules、Terragrunt live 配置、架构文档和执行脚本。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '本项目不采用旧模板中的 `ali-terraform-base-module / integrator-components / integrator-environments` 三仓拆分模式，而是采用“单仓物理结构 + L0/L1/L2 逻辑分层”的当前实现。'
[void]$body.AppendChild((New-WordTable -XmlDoc $documentXml -Rows @(
  @("层次/目录", "当前实现", "职责"),
  @("仓库根", "README.md, docs/, scripts/, .github/workflows/", "提供仓库说明、架构文档、本地执行脚本和 CI/CD 流水线。"),
  @("模块层", "modules/<component>/terraform", "沉淀单个组件的 Terraform 资源逻辑、变量、输出和版本约束。"),
  @("环境编排层", "live/<env>/cn-shanghai/<component>", "按环境组织 Terragrunt source、dependency、provider 生成和环境参数注入。"),
  @("L0 输入层", "vpc_inputs", "接入账户工厂或现网网络输入，向下游输出 vpc_id、vswitch_id、ecs_private_ip。"),
  @("L1 共享平台层", "kms, ram, sls, acr, eventbridge, mns", "沉淀共享平台能力，由各环境按需启用。"),
  @("L2 工作负载层", "oss, nas, backup, rds_pg, redis, alb, cdn, ecs, acs, fc, dataworks", "承载业务工作负载基础设施。")
)))

Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "Git管理" -StyleId "3"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '当前仓库建议采用 `main + feature/*` 的分支协作模型，功能开发在特性分支完成，通过 Pull Request 合并到 `main`。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '`dev/qa/prd` 是基础设施环境目录，不是 Git 分支。环境差异应放在 `live/<env>` 中维护，而不是通过长期环境分支承载。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '建议对 `main` 启用分支保护，至少包含：禁止直接推送、要求 PR、要求状态检查通过、要求代码评审。'

Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "代码规范" -StyleId "3"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "目录与文件约定" -StyleId "4"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text 'Terraform 模块目录统一使用 `main.tf / variables.tf / outputs.tf / versions.tf / README.md`。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text 'Terragrunt 环境目录统一使用 `terragrunt.hcl + terraform.tfvars`，并在环境根目录维护 `env.hcl` 和 `components.hcl`。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "代码树示例："
[void]$body.AppendChild((New-WordTable -XmlDoc $documentXml -Rows @(
  @("."),
  @("├── modules"),
  @("│   ├── ecs/terraform"),
  @("│   ├── sg/terraform"),
  @("│   └── vpc_inputs/terraform"),
  @("├── live"),
  @("│   ├── dev/cn-shanghai/<component>"),
  @("│   ├── qa/cn-shanghai/<component>"),
  @("│   └── prd/cn-shanghai/<component>"),
  @("├── docs"),
  @("├── scripts"),
  @("└── .github/workflows")
)))
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "变量和输出约定" -StyleId "4"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "模块输入应使用强类型建模，必要时通过 validation 或 lifecycle.precondition 做必填与互斥校验。"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '模块输出应同时兼顾向后兼容和批量消费。例如 ECS 既保留 `instance_id/private_ip`，也提供 `instance_ids/private_ips`；SG 既保留 `security_group_id`，也提供 `security_group_ids_list`。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "环境编排约定" -StyleId "4"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '`terragrunt.hcl` 负责 include 根配置、声明 dependency、指定 module source、生成 provider、注入公共 inputs。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '`terraform.tfvars` 负责环境静态参数，不直接硬编码跨组件依赖 ID。下游组件通过 `dependency.<component>.outputs` 消费上游输出。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "批量能力约定" -StyleId "4"
[void]$body.AppendChild((New-WordTable -XmlDoc $documentXml -Rows @(
  @("模块", "当前状态", "批量能力"),
  @("vpc_inputs", "已实现", "支持按开关创建单个 VPC 和单个 vSwitch，不属于批量列表模式。"),
  @("sg", "已实现", '通过 `security_groups` + `for_each` 批量创建多个安全组及规则。'),
  @("ecs", "已实现", '通过 `instances` + `for_each` 批量创建多个 ECS 实例。'),
  @("kms/alb/redis 等其余模块", "脚手架阶段", "变量或 README 可继续扩展，但 main.tf 仍以占位为主，暂未形成稳定实现。")
)))

Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "DevOps流水线" -StyleId "3"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "当前仓库以 GitHub Actions 作为唯一 CI/CD 编排入口，工具链为 Terraform + Terragrunt + tfsec + KICS。"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "已存在的工作流包括："
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '- `terraform-pr-checks.yml`：在 Pull Request 上执行 `terraform fmt -check`、模块级 `terraform validate` 和 `tfsec` 高危扫描。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '- `terraform-kics-scan.yml`：在 `main` push、定时任务和手工触发时运行 KICS，作为非阻塞安全补充扫描。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '- `terraform-manual-deploy.yml`：通过 `workflow_dispatch` 选择 `environment/action/component` 执行 plan/apply/destroy。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "总体流程" -StyleId "4"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '1. 开发人员在 feature 分支修改 `modules/`、`live/` 或 `docs/`。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "2. 创建 Pull Request，自动触发 PR 校验。"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '3. PR 通过后合并到 `main`。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '4. 通过 `terraform-manual-deploy.yml` 手工触发目标环境的 plan。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '5. `apply/destroy` 阶段绑定 GitHub Environment，按环境审批策略执行。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "各层交互" -StyleId "4"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '根 `terragrunt.hcl` 统一配置 remote_state；`live/<env>` 负责按环境注入差异；模块目录负责资源定义；`scripts/run_stage.ps1` 提供本地分阶段执行能力。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '组件之间以 Terragrunt dependency 连接。例如 `sg` 依赖 `vpc_inputs` 输出的 `vpc_id`，`ecs` 再依赖 `vpc_inputs` 的 `vswitch_id` 与 `sg` 的安全组输出。'

Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "GitOps流程" -StyleId "3"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '本地开发与审查：先在本地执行必要的 `terraform fmt`、`terraform validate` 或 `terragrunt plan`，确认模块与环境配置符合预期。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "远程仓库同步：通过 Pull Request 合并代码，避免直接在主分支修改生产基础设施定义。"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "人工审批" -StyleId "4"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '建议在 GitHub Repository Settings 中为 `qa` 和 `prd` 配置 Required Reviewers。当前 workflow 的执行阶段已经通过 `environment: ${{ inputs.environment }}` 与 GitHub Environment 绑定，可直接承接审批。'

Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "安全规范" -StyleId "3"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "代码仓库安全" -StyleId "4"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "仓库访问应通过 GitHub 组织权限、分支保护和代码审查控制。推荐启用 MFA、Secret Scanning 和最小权限协作策略。"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "IaC代码安全" -StyleId "4"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '禁止在 Terraform/Terragrunt 代码中硬编码 AK/SK、状态锁端点等敏感信息。安全检查以 `fmt/validate/tfsec/KICS` 组成最小基线。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "状态文件安全" -StyleId "4"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '当前 remote_state 使用阿里云 OSS 作为 backend，`acl = private`、`encrypt = true`，并通过 Tablestore 实现状态锁。state key 由 `path_relative_to_include()` 生成，确保环境和组件级隔离。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "凭据安全" -StyleId "4"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text 'GitHub Actions 通过 Secrets 注入 `ALICLOUD_ACCESS_KEY`、`ALICLOUD_SECRET_KEY`、`ALICLOUD_TABLESTORE_ENDPOINT`、`ALICLOUD_TABLESTORE_INSTANCE`。本地执行时使用环境变量传递，不写入代码仓库。'

Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "变更规范" -StyleId "3"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "变更需求评估" -StyleId "4"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "新增组件或扩容变更前，应先确认其所属逻辑层（L0/L1/L2）、依赖上游输出、目标环境范围以及是否需要批量能力。"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "代码修改" -StyleId "4"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '模块能力变更优先在 `modules/<component>/terraform` 中实现；环境差异和参数实例化放在 `live/<env>/cn-shanghai/<component>`；文档同步更新到 `docs/`。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "变更验证" -StyleId "4"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '验证顺序建议为：本地 `fmt/validate/plan`，PR 自动检查，目标环境 plan，审批后 apply，最后执行功能与依赖回归确认。'
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text "GitOps流程执行" -StyleId "4"
Add-BodyParagraph -XmlDoc $documentXml -Body $body -Text '当组件具备上游 dependency 时，应优先通过 Terragrunt 依赖顺序或脚本分阶段执行，避免手工跳步。当前本地脚本阶段顺序为：`kms/ram/sls/vpc_inputs` -> `sg/nacl/acr/eventbridge/mns` -> `oss/nas/backup/rds_pg/redis` -> `alb/cdn/ecs/acs/fc/dataworks`。'

[void]$body.AppendChild($sectPr)
$documentXml.Save($documentXmlPath)

$tempZipPath = Join-Path $docDir ("docx-repack-" + $timestamp + ".zip")
if (Test-Path $tempZipPath) {
  Remove-Item -LiteralPath $tempZipPath -Force
}
[System.IO.Compression.ZipFile]::CreateFromDirectory($workRoot, $tempZipPath)
$targetPath = $resolvedDocx

try {
  if (Test-Path $resolvedDocx) {
    Remove-Item -LiteralPath $resolvedDocx -Force
  }
  Copy-Item -LiteralPath $tempZipPath -Destination $resolvedDocx -Force
}
catch {
  $updatedCopyPath = Join-Path $docDir (([System.IO.Path]::GetFileNameWithoutExtension($docName)) + "-当前架构版.docx")
  Copy-Item -LiteralPath $tempZipPath -Destination $updatedCopyPath -Force
  $targetPath = $updatedCopyPath
}
finally {
  if (Test-Path $tempZipPath) {
    Remove-Item -LiteralPath $tempZipPath -Force -ErrorAction SilentlyContinue
  }
}

Write-Output "Updated: $targetPath"
Write-Output "Backup:  $backupPath"
