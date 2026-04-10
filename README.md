# Snowflake DevOps

Terraform-based infrastructure-as-code for managing Snowflake environments. The project is split into two tiers — **admin** and **developer** — each with its own YAML-driven configuration and Terraform root, so the right people can manage the right resources without stepping on each other.

## Project Structure

```
terraform/
├── config/
│   ├── admin/                  # Admin-managed configs
│   │   ├── databases.yaml      # Database definitions
│   │   ├── warehouses.yaml     # Warehouse definitions
│   │   ├── roles.yaml          # Roles, hierarchy & grants
│   │   └── storage_sources.yaml# Azure storage integrations
│   └── developers/             # Developer-managed configs
│       ├── tables.yaml         # Table & schema definitions
│       ├── views.yaml          # View definitions
│       ├── functions.yaml      # SQL & Snowpark UDFs
│       ├── procedures.yaml     # SQL & Snowpark stored procedures
│       └── tasks.yaml          # Scheduled tasks & DAGs
├── admin/                      # Admin Terraform root
├── snowflake/                  # Developer Terraform root
└── modules/                    # Shared reusable modules
src/
├── functions/                  # External Python/SQL function source files
├── procedures/                 # External procedure source files
└── tasks/                      # External task SQL files
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.3.0
- A Snowflake account with key-pair authentication configured
- An Azure storage account for Terraform remote state (or use local backend for dev)

### Key-Pair Authentication

Generate an RSA key pair for the Terraform service account:

```bash
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out snowflake_key.p8 -nocrypt
openssl rsa -in snowflake_key.p8 -pubout -out snowflake_key.pub
```

Assign the public key to the Snowflake user:

```sql
ALTER USER SVC_CICD SET RSA_PUBLIC_KEY='<contents of snowflake_key.pub without header/footer>';
```

Export the private key so Terraform can authenticate:

```bash
export TF_VAR_snowflake_private_key="$(cat snowflake_key.p8)"
```

---

## For Admins

The admin tier manages account-level infrastructure: databases, warehouses, storage integrations, and roles. Config files live in `terraform/config/admin/`.

### What Admins Own

| Config File            | What It Controls                                                |
| ---------------------- | --------------------------------------------------------------- |
| `databases.yaml`       | Snowflake databases (name derived as `{ENV}_{KEY}_DB`)          |
| `warehouses.yaml`      | Snowflake warehouses (name derived as `{ENV}_{KEY}_WH`)         |
| `roles.yaml`           | Roles, role hierarchy, warehouse/database grants, future grants |
| `storage_sources.yaml` | Azure storage integrations for external stages                  |

### Adding a New Database

Add an entry to `terraform/config/admin/databases.yaml`:

```yaml
risk:
  comment: 'Risk management data'
```

This creates `DEV_RISK_DB` in DEV and `PROD_RISK_DB` in PROD.

### Adding a New Warehouse

Add an entry to `terraform/config/admin/warehouses.yaml`:

```yaml
analytics:
  comment: 'Warehouse for analyst and BI workloads'
  auto_suspend: 120
  auto_resume: true
```

This creates `DEV_ANALYTICS_WH` in DEV and `PROD_ANALYTICS_WH` in PROD.

### Adding a New Role

Add an entry to `terraform/config/admin/roles.yaml`:

```yaml
data_engineer:
  comment: 'Data engineering role with broad write access'
  parent_role: SYSADMIN
  warehouses:
    backoffice: ['USAGE']
  databases:
    backoffice: ['USAGE']
```

The role name is derived as `{ENV}_{KEY}` (e.g. `DEV_DATA_ENGINEER`). For pre-existing roles, set `create: false` and specify `role_name` explicitly.

### Deploying Admin Changes

```bash
cd terraform/admin

# Initialize (first time or after backend changes)
terraform init -backend-config="key=admin/dev/terraform.tfstate"

# Preview changes
terraform plan -var-file=environments/DEV/DEV.tfvars

# Apply
terraform apply -var-file=environments/DEV/DEV.tfvars
```

For production, swap `DEV` for `PROD`:

```bash
terraform init -backend-config="key=admin/prod/terraform.tfstate"
terraform plan  -var-file=environments/PROD/PROD.tfvars
terraform apply -var-file=environments/PROD/PROD.tfvars
```

The admin tier runs as `ACCOUNTADMIN` by default.

---

## For Developers

The developer tier manages database objects: schemas, tables, views, functions, procedures, and tasks. Config files live in `terraform/config/developers/`.

> **Note:** Databases, warehouses, and roles must already exist (created by the admin tier) before the developer tier can run.

### What Developers Own

| Config File       | What It Controls                                          |
| ----------------- | --------------------------------------------------------- |
| `tables.yaml`     | Schemas (auto-derived) and tables with column definitions |
| `views.yaml`      | Standard and secure views                                 |
| `functions.yaml`  | SQL and Snowpark (Python) UDFs                            |
| `procedures.yaml` | SQL and Snowpark stored procedures                        |
| `tasks.yaml`      | Scheduled tasks and task DAGs                             |

### Adding a New Table

Add an entry to `terraform/config/developers/tables.yaml`:

```yaml
bloomberg_positions:
  schema: bloomberg
  source: bloomberg_xform # links to admin/storage_sources.yaml for auto-ingest
  comment: 'Bloomberg end-of-day position data'
  columns:
    - { name: AS_OF_DATE, type: DATE, nullable: false }
    - { name: SECURITY_ID, type: 'VARCHAR(50)', nullable: false }
    - { name: POSITION_QTY, type: 'NUMBER(18,4)', nullable: false }
```

Schemas are created automatically from the `schema` field.

### Adding a New View

Add an entry to `terraform/config/developers/views.yaml`:

```yaml
bloomberg_trade_summary:
  schema: bloomberg
  comment: 'Daily trade summary by security'
  is_secure: false
  statement: |
    SELECT TRADE_DATE, SECURITY_ID, COUNT(*) AS TRADE_COUNT
    FROM {database}.BLOOMBERG.BLOOMBERG_TRADES
    GROUP BY TRADE_DATE, SECURITY_ID
```

Use `{database}` as a placeholder — it gets replaced with the environment-specific database name.

### Adding a New Function

Add an entry to `terraform/config/developers/functions.yaml`. Inline body:

```yaml
calculate_trade_value:
  schema: bloomberg
  comment: 'Calculate total trade value'
  return_type: 'NUMBER(18,6)'
  language: SQL
  arguments:
    - { name: qty, type: 'NUMBER(18,4)' }
    - { name: price, type: 'NUMBER(18,6)' }
  body: |
    qty * price
```

Or reference an external file for Python UDFs:

```yaml
normalize_security_id:
  schema: bloomberg
  comment: 'Normalize security identifiers'
  return_type: VARCHAR
  language: PYTHON
  runtime_version: '3.11'
  packages: ['snowflake-snowpark-python']
  handler: normalize
  arguments:
    - { name: sec_id, type: VARCHAR }
  body_file: src/functions/normalize_security_id.py
```

### Adding a New Task

Add an entry to `terraform/config/developers/tasks.yaml`:

```yaml
daily_trade_cleanup:
  schema: bloomberg
  comment: 'Remove trades older than 2 years'
  warehouse: '{warehouse}'
  schedule: 'USING CRON 0 2 * * * UTC'
  enabled: false
  sql_statement: |
    DELETE FROM {database}.BLOOMBERG.BLOOMBERG_TRADES
    WHERE TRADE_DATE < DATEADD(YEAR, -2, CURRENT_DATE())
```

Child tasks use `after` instead of `schedule` to form DAGs.

### Deploying Developer Changes

```bash
cd terraform/snowflake

# Initialize (first time or after backend changes)
terraform init -backend-config="key=snowflake/dev/terraform.tfstate"

# Preview changes
terraform plan -var-file=environments/DEV/DEV.tfvars

# Apply
terraform apply -var-file=environments/DEV/DEV.tfvars
```

The developer tier runs as `CICD_DEPLOY_ROLE`.

---

## Placeholders

YAML configs support these placeholders, replaced at apply time:

| Placeholder   | Replaced With                                                  |
| ------------- | -------------------------------------------------------------- |
| `{database}`  | Environment-specific database name (e.g. `DEV_BACKOFFICE_DB`)  |
| `{warehouse}` | Environment-specific warehouse name (e.g. `DEV_BACKOFFICE_WH`) |

## Environments

Each tier has per-environment variable files under `environments/`:

```
terraform/admin/environments/DEV/DEV.tfvars
terraform/admin/environments/PROD/PROD.tfvars
terraform/snowflake/environments/DEV/DEV.tfvars
terraform/snowflake/environments/PROD/PROD.tfvars
```
