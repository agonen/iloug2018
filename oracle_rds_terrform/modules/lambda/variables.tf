variable "runtime" {
  description     = "lambda runtime"
  default         = "python2.7"
}

variable "s3_bucket" {
  description      = "lambda s3 bucket"
}

variable "s3_key" {
  description      = "lambda s3 key"
}

variable "name" {
  description     = "lambda function name"
}

variable "vpc_id" {
  description     = "VPC ID"
}

variable "subnet_ids" {
  description = "A list of subnet IDs"
  type        = "list"
}

variable "timeout" {
  description     = "lambda timeout"
  default         = "30"
}

variable "memory_size" {
  description     = "lambda memory size"
  default         = 256
}

variable "handler" {
  description     = "lambda handler name"
  default = "lambda.handler"
}

variable "env" {
  description     = "environment variables for lambda"
  type            = "map"
}

variable "log_retention" {
  description     = "log retention period for the logs"
  default         = 90
}
