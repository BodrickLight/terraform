# Glossary

**Bootstrap**: The one-off, manually run setup of the state backend and the CI identity. Lives outside Terraform because Terraform depends on it.

**State backend**: The Azure Storage container that holds Terraform state.

**CI identity**: The Entra app registration GitHub Actions signs in as, via OIDC.

**Import**: Bringing a resource that already exists in Azure under Terraform management without recreating it.
