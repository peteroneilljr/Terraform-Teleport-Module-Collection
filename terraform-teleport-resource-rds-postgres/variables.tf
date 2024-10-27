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
variable "aws_key_name" {
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
variable "teleport_proxy_address" {
  type        = string
  description = "description"
}
variable "teleport_version" {
  type        = string
  description = "description"
}

