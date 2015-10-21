variable "access_key" {
  description = "AWS access key"
}

variable "secret_key" {
  description = "AWS secret access key"
}

variable "region"     {
  description = "AWS region to host your network"
  default     = "us-east-1"
}

variable "ami" {
  description = "Base AMI to launch the instances with"
  /* this is the linux AMI*/
  default = "ami-e3106686"
}
