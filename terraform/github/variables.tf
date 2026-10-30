variable "owner" {
  description = "GitHub organization that holds the workspace."
  type        = string
  default     = "toil-lab"
}

variable "approver" {
  description = "GitHub login of the human who approves every merge. Added as maintainer of every team."
  type        = string
  default     = "kevinaroe"
}

variable "ruleset_enforcement" {
  description = "Branch rulesets on every repo. Set to disabled only for the bootstrap apply, before each repo has its first commit."
  type        = string
  default     = "active"

  validation {
    condition     = contains(["active", "disabled"], var.ruleset_enforcement)
    error_message = "ruleset_enforcement must be active or disabled."
  }
}
