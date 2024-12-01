include "root" {
  path = find_in_parent_folders("root.hcl")
}

#include "envcommon" {
#  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/mysql.hcl"
#  expose = true
#}

terraform {
  source = "${get_repo_root()}/terragrunt/modules//cloudflare/account"
}

inputs = {
  account_name = "Personal Account"
}