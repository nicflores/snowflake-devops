-- =============================================================================
-- Snowflake CI/CD Service Account Setup
-- =============================================================================
-- Run this script as ACCOUNTADMIN in a Snowflake worksheet.
--
-- Before running:
--   1. Generate an RSA key pair:
--        openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out snowflake_key.p8 -nocrypt
--        openssl rsa -in snowflake_key.p8 -pubout -out snowflake_key.pub
--
--   2. Copy the public key content (without the BEGIN/END lines) and paste it
--      into the RSA_PUBLIC_KEY parameter below.
--
--   3. Store the private key (snowflake_key.p8) as a GitHub secret:
--        SNOWFLAKE_PRIVATE_KEY
-- =============================================================================

USE ROLE ACCOUNTADMIN;

-- ---------------------------------------------------------------------------
-- 1. CI/CD Warehouse (XSMALL — used only for DDL operations)
-- ---------------------------------------------------------------------------
CREATE WAREHOUSE IF NOT EXISTS CICD_WH
  WAREHOUSE_SIZE      = 'XSMALL'
  AUTO_SUSPEND        = 60
  AUTO_RESUME         = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT             = 'Dedicated warehouse for CI/CD Terraform operations';

-- ---------------------------------------------------------------------------
-- 2. CI/CD Role
-- ---------------------------------------------------------------------------
CREATE ROLE IF NOT EXISTS CICD_DEPLOY_ROLE
  COMMENT = 'Role for CI/CD Terraform deployments — owns all managed resources';

-- Grant the role to SYSADMIN so admins can see what it owns
GRANT ROLE CICD_DEPLOY_ROLE TO ROLE SYSADMIN;

-- ---------------------------------------------------------------------------
-- 3. CI/CD Service Account User
-- ---------------------------------------------------------------------------
CREATE USER IF NOT EXISTS SVC_CICD
  DEFAULT_ROLE      = 'CICD_DEPLOY_ROLE'
  DEFAULT_WAREHOUSE = 'CICD_WH'
  MUST_CHANGE_PASSWORD = FALSE
  COMMENT           = 'Service account for CI/CD Terraform deployments';

-- Assign the public key (paste your key between the quotes, single line, no headers)
ALTER USER SVC_CICD SET RSA_PUBLIC_KEY = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA19rclJ3VSMn0G4lSSWp2fCSJU3nLxj0pvGAw/WtU4MpKlewK6p7j5eZLy6m2zfcbK3FdfPDU+8M24Vm6YaWXoIQt8YWlPFX8/NSBdt719hIGVMuaDA5VKlIMinicWzXTxm53utxzsjII6peLm+J+i18PA46QvbpvAoAiDQSVdfg+J5+ihLisCqUGJM6crSm5Dc43GxYEYGy2OxWhlGpszdxuI8HcbApeZF48JTzDOHzA3RGmg+9KUdleF3FufyNmAajT+6dB6VwrXKuy+07VIFYhjxzPslNdNuXyewyoYQGeg9wtDX+ILUHbE4u2uUIy541D7QHs2ChdHyF4j/gfmQIDAQAB';

-- Grant the deploy role to the service account
GRANT ROLE CICD_DEPLOY_ROLE TO USER SVC_CICD;

-- ---------------------------------------------------------------------------
-- 4. Warehouse Grants
-- ---------------------------------------------------------------------------
-- CI/CD warehouse — full control for running Terraform DDL
GRANT ALL PRIVILEGES ON WAREHOUSE CICD_WH TO ROLE CICD_DEPLOY_ROLE;

-- ---------------------------------------------------------------------------
-- 5. Account-Level Grants
-- ---------------------------------------------------------------------------
-- The developer tier only manages schemas, tables, stages, pipes, and grants.
-- Warehouses, databases, storage integrations, and roles are created by the
-- admin tier (ACCOUNTADMIN). The CICD role only needs MANAGE GRANTS to assign
-- privileges on those objects.
GRANT MANAGE GRANTS ON ACCOUNT TO ROLE CICD_DEPLOY_ROLE;

-- ---------------------------------------------------------------------------
-- Verification
-- ---------------------------------------------------------------------------
-- Run these to confirm everything was created correctly:
SHOW USERS    LIKE 'SVC_CICD';
SHOW ROLES    LIKE 'CICD_DEPLOY_ROLE';
SHOW WAREHOUSES LIKE 'CICD_WH';

-- Test authentication (should show CICD_DEPLOY_ROLE):
-- USE ROLE CICD_DEPLOY_ROLE;
-- SELECT CURRENT_ROLE(), CURRENT_WAREHOUSE();
