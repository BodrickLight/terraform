# terraform

Terraform for my Azure subscription, applied through GitHub Actions.

- Pull requests run `fmt`, `validate` and `plan` as a read-only identity, and comment the plan.
- Merging to `main` runs `apply` as a Contributor identity, after approval on the `production` environment (which only deploys from `main`).
- State lives in Azure Blob Storage (`rg-terraform`), authenticated with Entra ID.
- GitHub authenticates to Azure with OIDC; there are no stored secrets.

## First-time setup

1. `az login`, then run `bootstrap/bootstrap.ps1`.
2. Add the printed `AZURE_*` values as repository variables.
3. Create a `production` environment with a required reviewer, restricted to `main`, and protect `main`.

## Local use

`terraform init` then `terraform plan` (uses your `az login`).
