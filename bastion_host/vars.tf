variable "service_name" {
  description = "Name of the service"
  type        = string
}

variable "env" {
  description = "Deployment Environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC id in which the bastion instance is to be created"
  type        = string
}

variable "bastion_subnet_id" {
  description = "ID of the subnet in which bastion is to be kept"
  type        = string
}

variable "bastion_logs_kms_key_id" {
  description = "KMS key ID or ARN to encrypt the bastion CloudWatch log group"
  type        = string
}
