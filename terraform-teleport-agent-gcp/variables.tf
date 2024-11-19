
# ---------------------------------------------------------------------------- #
# Agent settings
# ---------------------------------------------------------------------------- #
variable "teleport_nodename" {
  type        = string
  description = "Name to appear in Teleport resource manager"
}

# ---------------------------------------------------------------------------- #
# Teleport settings
# ---------------------------------------------------------------------------- #
variable "teleport_proxy_address" {
  type        = string
  description = "Host and HTTPS port of the Teleport Proxy Service"
}
variable "teleport_cdn_address" {
  type        = string
  description = "Download script for Teleport"
  default     = "https://cdn.teleport.dev/install-v16.2.0.sh"
}
variable "teleport_version" {
  type        = string
  description = "Version of Teleport to install on each agent"
}
variable "teleport_enhanced_recording" {
  # https://goteleport.com/docs/enroll-resources/server-access/guides/bpf-session-recording/
  type        = bool
  default     = false
  description = "Enables enhanced recording on the Teleport Agent"
}
variable "teleport_agent_roles" {
  type        = list(string)
  description = "Roles to enable on Teleport Agent, Node is already added by default"
}
variable "teleport_ssh_labels" {
  type        = map(string)
  description = "Teleport ssh labels"
  default = {
    "createdBy" = "IAC"
  }
}
# ---------------------------------------------------------------------------- #
# Windows
# ---------------------------------------------------------------------------- #

variable "teleport_windows_hosts" {
  type = map(object({
    env  = string
    addr = string
  }))
  description = "Windows hosts to add"
  default     = {}
}
# ---------------------------------------------------------------------------- #
# AWS
# ---------------------------------------------------------------------------- #

variable "teleport_aws_apps" {
  type = map(object({
    uri    = string
    labels = map(string)
  }))
  description = "AWS Appps to add"
  default     = {}
}
# ---------------------------------------------------------------------------- #
# GCP
# ---------------------------------------------------------------------------- #

variable "teleport_gcp_apps" {
  type = map(object({
    labels = map(string)
  }))
  description = "GCP Appps to add"
  default     = {}
}
# ---------------------------------------------------------------------------- #
# RDS
# ---------------------------------------------------------------------------- #

variable "teleport_rds_hosts" {
  type = map(object({
    endpoint = string
    env      = string
  }))
  description = "RDS connects to add to teleprot"
  default     = {}
}
# ---------------------------------------------------------------------------- #
# Module settings
# ---------------------------------------------------------------------------- #
variable "prefix" {
  type        = string
  description = "String prefix to add to names"
  default     = ""
}
variable "public_ip" {
  type        = bool
  description = "Assign public IP to this Agent's node"
  default     = false
}
# ---------------------------------------------------------------------------- #
# GCP
# ---------------------------------------------------------------------------- #
variable "gcp_service_account_email" {
  type        = string
  description = "Service Account with ability to impersonate other service accounts"
  default = null
}
variable "gcp_machine_type" {
  type        = string
  description = "Machine type for GCP VM Instance"
  default     = "e2-micro"
}
variable "gcp_region" {
  type        = string
  description = "Region to deploy VM instance, zone is always -a"
  default     = "us-central1"
}