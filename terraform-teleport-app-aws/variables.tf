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
variable "teleport_version" {
  type        = string
  description = "description"
}
