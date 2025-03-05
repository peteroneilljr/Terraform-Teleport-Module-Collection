variable "prefix" {
  type        = string
  description = "description"
}
# ---------------------------------------------------------------------------- #
# AWS Vars
# ---------------------------------------------------------------------------- #
variable "aws_vpc_id" {
  type        = string
  description = "description"
}
variable "aws_security_group_id" {
  type        = string
  description = "description"
}
variable "aws_subnet_id" {
  type        = string
  description = "description"
}
variable "aws_key_pair" {
  type        = string
  description = "description"
  default     = null
}
variable "aws_iam_role_name" {
  type        = string
  description = "Use an externally managed role to attach to the instance profile"
  default     = null
}
variable "aws_tags" {
  description = "description"
  default     = {}
}
# ---------------------------------------------------------------------------- #
# Teleport Vars
# ---------------------------------------------------------------------------- #
variable "teleport_agent_create" {
  type        = bool
  default     = false
  description = "description"
}
variable "teleport_proxy_address" {
  type        = string
  description = "description"
}
variable "teleport_apps" {
  description = "description"
  default = {
    "awsconsole" = {
      "uri"   = "https://console.aws.amazon.com/"
      "cloud" = "AWS"
      "labels" = {
        "cloud" = "aws"
        "env"   = "dev"
      }
    }
    "awsconsole-admin" = {
      "uri"   = "https://console.aws.amazon.com/"
      "cloud" = "AWS"
      "labels" = {
        "cloud" = "aws"
        "env"   = "prod"
      }
    }
  }
}