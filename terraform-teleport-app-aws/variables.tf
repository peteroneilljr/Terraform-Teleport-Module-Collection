variable "prefix" {
  type        = string
  description = "description"
}
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
variable "teleport_proxy_address" {
  type        = string
  description = "description"
}
variable "teleport_edition" {
  type        = string
  description = "Edition of Teleport, cloud, enterprise or oss"
  default     = "cloud"
}
variable "teleport_cdn_address" {
  type        = string
  description = "Download script for Teleport"
  default     = "https://cdn.teleport.dev/install-v16.4.2.sh"
}
variable "teleport_version" {
  type        = string
  description = "Version of Teleport to install on each agent"
  default     = "16.4.2"
}