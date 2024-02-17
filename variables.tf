variable "aws_region" {
  type = string
}

variable "domain_name" { type = string }

variable "forward_to_perso_email" { type = string }

variable "active_rule_set_already_exists" {
  type    = bool
  default = false
}