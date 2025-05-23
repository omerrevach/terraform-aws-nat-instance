variable "amazon_ec2_linux_image" {
  description = "Amazon Linux image for the NAT instance. Used to launch the EC2 instance providing network address translation."
  type        = string
  default     = "amzn2-ami-kernel-5.10-hvm-*"
}

variable "amazon_ec2_instance_virtualization_type" {
  description = "The virtualization type for the Amazon EC2 instance (e.g., 'hvm' for hardware virtual machine)."
  type        = string
  default     = "hvm"
}

variable "amazon_owner_id" {
  description = "The AWS account ID of the AMI owner. Used to ensure you're using official or trusted AMIs."
  type        = string
  default     = "137112412989"
}

variable "aws_vpc_id" {
  description = "The ID of the VPC where the NAT instance and related resources will be deployed."
  type        = string
}

variable "nat_instance_type" {
  description = "The EC2 instance type for the NAT instance (e.g., 't3.micro', 't3.small')."
  type        = string
}

variable "number_of_azs" {
  description = "The number of availability zones to distribute the infrastructure across."
  type        = number
}

variable "private_subnets_ids" {
  description = "A list of IDs for the private subnets that require outbound internet access via the NAT instance."
  type        = list(string)
}

variable "public_subnets_ids" {
  description = "A list of IDs for the public subnets where the NAT instance will be placed."
  type        = list(string)
}

variable "single_nat_instance" {
  description = "Enable Single nat Instance (true) or enable nat instance per AZ (false)"
  type        = bool
  default     = true
}

variable "root_block_device" {
  description = "Root block device configuration for NAT instances"
  type = list(object({
    delete_on_termination = optional(bool, true)
    encrypted             = optional(bool, false)
    volume_size           = optional(number, 10)
  }))
  default = [
    {
      # Default settings are applied via the optional() type constructor above
      # This empty object will use all the defaults:
      # - volume_size: 10 GB
      # - encrypted: false
      # - delete_on_termination: true
    }
  ]
}

variable "enable_ebs_encryption" {
  description = "Enable EBS Encryption"
  type = bool
  default = false
}