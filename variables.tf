locals {
  project_name = "monitor-troubleshooting"
}

variable "region" {
  type        = string
  description = "The AWS region"
}

variable "owner" {
  type        = string
  description = "The owner of the resources"
}


variable "project" {
  default     = "prism"
  description = "name of the project"
  type        = string
}

variable "kube_config" {
  type    = string
  default = "~/.kube/config"
}


variable "cloudwatch_log_retention_days" {
  default     = 30
  description = "days of cloudwatch log retention"
  type        = number
}