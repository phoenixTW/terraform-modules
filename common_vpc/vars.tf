variable "service_name" {
  type        = string
  description = "The name of the service"
  default     = "common"
}

variable "env" {
  type = string
}

variable "cidr" {
  description = "The CIDR block for the VPC."
}

variable "public_subnets" {
  description = "List of public subnets"
}

variable "private_subnets" {
  description = "List of private subnets"
}

variable "database_subnets" {
  type        = list(string)
  default     = []
  description = "A list all the database subnets in the VPC"
}

variable "availability_zones" {
  description = "List of availability zones"
}

variable "tags" {
  type        = map(string)
  description = "Tags for resources"
  default     = {}
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Should be true to enable DNS hostnames in the VPC"
  default     = false
}

variable "enable_flow_logs" {
  type        = bool
  description = "Should be true to enable flow logs in the VPC"
  default     = false
}

variable "flow_log_retention_days" {
  type        = number
  description = "The number of days to retain flow logs"
  default     = 30
}

