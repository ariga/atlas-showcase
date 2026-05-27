# tf-role

Minimal Terraform and Atlas example for provisioning PostgreSQL infrastructure on AWS, then applying database roles and schema changes in order.

## Prerequisites

- Terraform
- Atlas CLI
- AWS credentials configured for the profile used in this example

## Run Order

Apply the stacks in this order:

1. `infra`
2. `roles`
3. `schema`

The `roles` and `schema` stacks read local Terraform state from `terraform/infra` and `terraform/roles`, so they must be applied sequentially.

## 1. Get Your Current Public IP

The infra stack requires `allowed_cidr` so the RDS security group can allow PostgreSQL access from your current IP.

```sh
curl https://checkip.amazonaws.com
```

Current response:

```text
183.91.23.114
```

Export it as a `/32` CIDR before planning `infra`:

```sh
export TF_VAR_aws_profile="your-aws-profile"
export ALLOWED_CIDR="183.91.23.114/32"
```

If your public IP changes, fetch it again and update `ALLOWED_CIDR`.

## 2. Apply Infra

```sh
terraform -chdir=terraform/infra init
terraform -chdir=terraform/infra plan -var="allowed_cidr=${ALLOWED_CIDR}" -out=tfplan
terraform -chdir=terraform/infra apply tfplan
```

## 3. Apply Roles

```sh
terraform -chdir=terraform/roles init
terraform -chdir=terraform/roles plan -out=tfplan
terraform -chdir=terraform/roles apply tfplan
```

## 4. Apply Schema

```sh
terraform -chdir=terraform/schema init
terraform -chdir=terraform/schema plan -out=tfplan
terraform -chdir=terraform/schema apply tfplan
```