# iacservice_b2 执行流程图 / 调用链

## 1. 总览流程

```text
GitHub Actions
  -> 手动触发 workflow_dispatch
  -> 选择 environment(dev/qa/prd) + action(plan/apply) + stacks
  -> plan 作业
      -> make build-package PROFILE=<env>
      -> 生成 code-<env>.zip
      -> scripts/upload_iac_module.py
      -> 上传到 IaCService ModuleVersion
      -> scripts/trigger_stack.py(action="terraform plan")
      -> scripts/get_trigger_result.py
      -> 输出 execution_result_plan.md
  -> 如果 action=apply
      -> approval 作业
      -> GitHub Environment 人工审批
      -> apply 作业
          -> 复用 plan 阶段的 version_id + changed_folders
          -> scripts/trigger_stack.py(action="terraform apply")
          -> scripts/get_trigger_result.py
          -> 输出 execution_result_apply.md
```

## 2. 文件调用链

### 2.1 入口

`.github/workflows/iacservice-manual-deploy.yml`
- 整个项目主入口
- 接收输入：
  - `environment`
  - `action`
  - `stacks`
  - `confirm_token`

### 2.2 构包链路

`Makefile`
- `check-profile`
- `replace-placeholders`
  - 读取 `deployments/<env>/profile.yaml`
  - 用 `scripts/yq` 解析 YAML
  - 替换 `deployments/<env>/**/tfdeploy.yaml` 中占位符
- `prepare-package`
  - 复制 `modules/` `scripts/` `stacks/` `deployments/` 到 `.build/<env>/`
  - 把 `deployments/<env>/*` 合并到 `.build/<env>/stacks/`
- `build-package`
  - 打包生成 `code-<env>.zip`

### 2.3 上传链路

`scripts/upload_iac_module.py`
- 读取环境变量/参数：
  - `IAC_ACCESS_KEY_ID`
  - `IAC_ACCESS_KEY_SECRET`
  - `IAC_REGION`
  - `CODE_MODULE_ID` 或 `--code_module_id`
- 调用阿里云 IaCService OpenAPI
- 上传 zip 到 `ModuleVersion`
- 返回 `Version ID`

### 2.4 触发执行链路

`scripts/trigger_stack.py`
- 输入：
  - `region`
  - `code_module_id`
  - `action(terraform plan / terraform apply)`
  - `code_module_version`
  - `change_folders`
- 调用 `TriggerStackExecution` API
- 返回 `Trigger ID`

### 2.5 结果查询链路

`scripts/get_trigger_result.py`
- 根据 `result-path` 中的 `<env>@<trigger_id>`
- 轮询 `get_stack_execution_result`
- 直到 `Success / Errored`
- 格式化为 markdown 报告
- 输出 `execution_result_*.md`

## 3. IaC 资源调用链

`stacks/core/tfcomponent.yaml`
- 定义 stack 的组件编排顺序

调用顺序：

```text
core stack
  -> component.vpc_inputs
      -> modules/vpc_inputs/terraform
      -> 输出:
         - vpc_id
         - vswitch_id
         - ecs_private_ip
  -> component.sg
      -> modules/sg/terraform
      -> 输入:
         - vpc_id = component.vpc_inputs.vpc_id
      -> 输出:
         - security_group_id
  -> component.ecs
      -> modules/ecs/terraform
      -> 输入:
         - vswitch_id = component.vpc_inputs.vswitch_id
         - security_group_ids = [component.sg.security_group_id]
         - private_ip = component.vpc_inputs.ecs_private_ip
      -> 输出:
         - instance_ids
  -> component.mysql_user
      -> modules/mysql_user/terraform
      -> 输入:
         - db_instance_id
         - kms_secret_name
         - db_names
         - privilege
      -> 输出:
         - created
         - account_name
```

依赖关系：
- `sg` 依赖 `vpc_inputs`
- `ecs` 依赖 `vpc_inputs + sg`
- `mysql_user` 相对独立

## 4. 环境参数注入链

`deployments/<env>/profile.yaml`
- 提供控制面参数
  - `account_id`
  - `code_module_id`
  - `region`
  - `access_key_id`
  - `access_key_secret`

`deployments/<env>/core/tfdeploy.yaml`
- 提供资源面参数
  - `create_vpc / existing_vpc_id`
  - `create_vswitch / existing_vswitch_id`
  - `create_security_group`
  - `ingress_rules / egress_rules`
  - `create_instance / instances`
  - `create_mysql_user / rds_mysql_instance_id` 等

实际生效路径：

```text
profile.yaml
  -> workflow/bash 解析
  -> 导出 IAC_* 凭证和 module_id/region
  -> 给 upload_iac_module.py / trigger_stack.py / get_trigger_result.py 用

tfdeploy.yaml
  -> 在构包后合并进 stacks/
  -> 交给 IaCService 执行
  -> 驱动 tfcomponent.yaml 中各 module 的 inputs
```

## 5. 按 action 分支的调用链

### 5.1 plan

```text
workflow
  -> make build-package
  -> upload_iac_module.py
  -> trigger_stack.py(terraform plan)
  -> get_trigger_result.py
  -> artifact: execution_result_plan.md
```

### 5.2 apply

```text
workflow
  -> 先完整执行一次 plan
  -> approval
  -> trigger_stack.py(terraform apply)
  -> get_trigger_result.py
  -> artifact: execution_result_apply.md
```

## 6. 简版 ASCII 流程图

```text
workflow_dispatch
  |
  v
选择 env/action/stacks
  |
  v
Plan Job
  |
  +--> Makefile: build-package
  |      |
  |      +--> profile.yaml
  |      +--> tfdeploy.yaml
  |      +--> tfcomponent.yaml
  |      +--> code-<env>.zip
  |
  +--> upload_iac_module.py
  |      |
  |      +--> IaCService ModuleVersion
  |      +--> Version ID
  |
  +--> trigger_stack.py(terraform plan)
  |      |
  |      +--> Trigger ID
  |
  +--> get_trigger_result.py
         |
         +--> execution_result_plan.md

if action=apply
  |
  v
Approval Job
  |
  v
Apply Job
  |
  +--> trigger_stack.py(terraform apply)
  |
  +--> get_trigger_result.py
         |
         +--> execution_result_apply.md
```

## 7. 资源模块内部调用链

```text
tfdeploy.yaml inputs
  -> tfcomponent.yaml variables
  -> vpc_inputs
  -> sg
  -> ecs
  -> mysql_user
  -> outputs(vpc_id/vswitch_id/security_group_id/ecs_instance_ids/mysql_user_*)
```
