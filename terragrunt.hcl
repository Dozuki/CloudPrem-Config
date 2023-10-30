locals {
  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  aws_region   = local.region_vars.locals.aws_region

  # If we are NOT in managed private cloud, do not generate the DNS provider.
  disable_managed_provider = !local.environment_vars.locals.managed_private_cloud

  dns_role = local.aws_region == "us-gov-west-1" ? "arn:aws-us-gov:iam::446787640263:role/Route53AccessRole" : "arn:aws:iam::010601635461:role/Route53AccessRole"
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
}
EOF
}

generate "managed_provider" {
  path = "managed_provider.tf"
  if_exists = "overwrite_terragrunt"
  disable = locals.disable_managed_provider
  contents  = <<EOF
provider "aws" {
  alias  = "dns"
  region = "${local.aws_region}"

  assume_role {
    role_arn = "${local.dns_role}"
  }
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "${get_env("TG_BUCKET_PREFIX", "")}dozuki-terraform-state-${local.aws_region}-${get_aws_account_id()}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "dozuki-terraform-lock"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.region_vars.locals,
  local.environment_vars.locals,
)