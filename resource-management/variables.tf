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

variable "aws_account_id" {
  default     = "005791594643"
  description = "id of aws account"
  type        = string
}

variable "cloudwatch_log_retention_days" {
  default     = 30
  description = "days of cloudwatch log retention"
  type        = number
}


variable "elastic_cloud_endpoint" {
  description = "endpoint of elastic cloud"
  type        = string
  default     = "8f703c473cd644199f4de9ae49e0e6e9.vpce.ap-northeast-1.aws.elastic-cloud.com"
}
