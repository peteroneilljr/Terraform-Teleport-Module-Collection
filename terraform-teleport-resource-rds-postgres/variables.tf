variable "prefix" {
  type        = string
  description = "description"
}
variable "rds_users" {
  type        = list(string)
  description = "description"
}
# ---------------------------------------------------------------------------- #
# AWS
# ---------------------------------------------------------------------------- #
variable "aws_vpc_id" {
  type        = string
  description = "description"
}
variable "aws_security_group_id" {
  type        = string
  description = "description"
}
variable "aws_key_pair" {
  type        = string
  description = "description"
}
variable "aws_subnet_ids" {
  type        = list(string)
  description = "description"
}
variable "aws_tags" {
  description = "description"
  default     = {}
}
# ---------------------------------------------------------------------------- #
# Teleport
# ---------------------------------------------------------------------------- #
variable "teleport_proxy_address" {
  type        = string
  description = "description"
}
variable "teleport_version" {
  type        = string
  description = "description"
}
variable "teleport_agent_enable" {
  type        = bool
  default     = false
  description = "description"
}
# ---------------------------------------------------------------------------- #
# SSH Access
# ---------------------------------------------------------------------------- #
variable "private_key_file" {
  type        = string
  description = "Private key for the ssh connection"
}
variable "public_key_file" {
  type        = string
  description = "Public key for the ssh connection"
  default     = null
}
