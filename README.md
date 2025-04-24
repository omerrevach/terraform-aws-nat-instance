# NAT Instance Terraform Module

## Overview
This Terraform module provisions a NAT instance in AWS to enable outbound internet access for private subnets. The module sets up an Amazon Linux EC2 instance with appropriate IAM roles, security groups, and routing configurations to function as a NAT instance.

## Features
- Creates an EC2 NAT instance with Amazon Linux
- Configures security groups to allow necessary traffic
- Sets up IAM roles for instance management via AWS Systems Manager (SSM)
- Provisions a network interface with source/destination check disabled
- Configures route tables to direct private subnet traffic through the NAT instance

## Usage
```hcl
module "nat_instance" {
  source = "./modules/nat-instance"

  aws_vpc_id                            = "vpc-12345678"
  nat_instance_type                     = "t3.micro"
  number_of_azs                          = 2
  private_subnets_ids                    = ["subnet-abcdef12", "subnet-abcdef34"]
  public_subnets_ids                     = ["subnet-12345678", "subnet-87654321"]
  amazon_ec2_linux_image                 = "amzn2-ami-kernel-5.10-hvm-*"
  amazon_ec2_instance_virtualization_type = "hvm"
  amazon_owner_id                        = "137112412989"
  ssm_agent_policy                       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  single_nat_instance                     = false  # Set to true to use only one NAT instance (cost-saving), or false for high availability (one per AZ)
}
```

## Inputs

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `aws_vpc_id` | The ID of the VPC where the NAT instance will be deployed | `string` | n/a |
| `nat_instance_type` | The EC2 instance type (e.g., `t3.micro`, `t3.small`) | `string` | n/a |
| `number_of_azs` | The number of availability zones to distribute the infrastructure across | `number` | n/a |
| `private_subnets_ids` | A list of private subnet IDs that require outbound internet access | `list(string)` | n/a |
| `public_subnets_ids` | A list of public subnet IDs where the NAT instance will be placed | `list(string)` | n/a |
| `amazon_ec2_linux_image` | Amazon Linux image for the NAT instance | `string` | `amzn2-ami-kernel-5.10-hvm-*` |
| `amazon_ec2_instance_virtualization_type` | Virtualization type for the EC2 instance | `string` | `hvm` |
| `amazon_owner_id` | AWS account ID of the AMI owner | `string` | `137112412989` |
| `ssm_agent_policy` | IAM policy ARN for SSM agent management | `string` | `arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore` |

## Outputs

| Output | Description |
|--------|-------------|
| `nat_instance_id` | The ID of the NAT EC2 instance |
| `nat_instance_security_group_id` | The security group ID assigned to the NAT instance |
| `nat_instance_private_ip` | The private IP address of the NAT instance |
| `nat_instance_public_ip` | The public IP address (if assigned) |

## Security
- The instance profile allows management via AWS Systems Manager (SSM) without requiring SSH access.
- Security groups restrict inbound traffic to the VPC’s CIDR block.

## License
This module is licensed under the MIT License.

---

## 🤝 Contributing
Contributions are welcome!
Fork the repository and submit a pull request with bug fixes, improvements, or new features.

For more details, reach out to the repository owner.
Visit [Senora.dev](https://Senora.dev)💜 for more platform-related services.