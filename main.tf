// Create security groups that allows all traffic from VPC's cidr to NAT-Instance.
resource "aws_security_group" "nat_instance_sg" {
  vpc_id = var.aws_vpc_id
  name   = "nat-instance"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "all"
    cidr_blocks     = [data.aws_vpc.current_vpc.cidr_block]
    prefix_list_ids = []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "sg-nat-instance"
  }
}

// Create role.
resource "aws_iam_role" "ssm_agent_role" {
  name = "iam-role-ssm-agent"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : {
      "Effect" : "Allow",
      "Principal" : { "Service" : "ec2.amazonaws.com" },
      "Action" : "sts:AssumeRole"
    }
  })
}

// Attach role to policy.
resource "aws_iam_role_policy_attachment" "attach_ssm_role" {
  policy_arn = var.ssm_agent_policy
  role       = aws_iam_role.ssm_agent_role.name
}

// Create instance profile.
resource "aws_iam_instance_profile" "nat_instance_profile" {
  name = "iam-profile-nat-instance"
  role = aws_iam_role.ssm_agent_role.name
}

resource "tls_private_key" "nat_instance_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "nat_instance_key_pair" {
  key_name   = "ec2-nat-instance"
  public_key = tls_private_key.nat_instance_private_key.public_key_openssh
}

resource "aws_ssm_parameter" "nat_instance_ssm" {
  name        = "/infra/ec2-nat-instance/key"
  description = "ec2-nat-instance ssh key"
  type        = "SecureString"
  value       = tls_private_key.nat_instance_private_key.private_key_pem

  tags = {
  }
}

# condition ? value_if_true : value_if_false

# If var.single_nat_instance is true, then nat_instance_count will be 1.
# If var.single_nat_instance is false, then nat_instance_count will be the number of public subnets, i.e., length(var.public_subnets_ids).

locals {
  nat_instance_count = var.single_nat_instance ? 1 : length(var.public_subnets_ids)
  subnets_to_use     = var.single_nat_instance ? [var.public_subnets_ids[0]] : var.public_subnets_ids
}


resource "aws_network_interface" "network_interface" {
  count             = local.nat_instance_count
  source_dest_check = false
  subnet_id         = local.subnets_to_use[count.index]
  security_groups   = [aws_security_group.nat_instance_sg.id]
  tags = {
    Name = "nat-instance-network-interface-${count.index + 1}"
  }
}

// Route private networks through NAT-Instance network interface.
resource "aws_route" "route_to_nat_instace" {
  destination_cidr_block = "0.0.0.0/0"
  count                  = var.number_of_azs
  # Select the network interface to route traffic through:
  # - If using a single NAT instance, always use the first network interface (index 0)
  # - If using multiple NAT instances (one per AZ), use modulo (%) to evenly assign each private subnetss route 
  #   to one of the NAT interfaces — this maps private route tables to available NAT interfaces as round robin
  network_interface_id = var.single_nat_instance ? aws_network_interface.network_interface[0].id : aws_network_interface.network_interface[count.index % local.nat_instance_count].id
  route_table_id       = tolist(data.aws_route_tables.route_tables_of_private_networks.ids[*])[count.index]
}

// Creating NAT Instance.
resource "aws_instance" "nat_instance" {
  // Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs.
  count                       = local.nat_instance_count
  instance_type               = var.nat_instance_type
  key_name                    = aws_key_pair.nat_instance_key_pair.key_name
  ami                         = data.aws_ami.amazon_linux.id
  iam_instance_profile        = aws_iam_instance_profile.nat_instance_profile.name
  user_data                   = data.template_file.nat_instance_setup_template.rendered
  associate_public_ip_address = false
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.network_interface[count.index].id
  }

  tags = {
    Name = "ec2-nat-instance-${count.index + 1}"
  }
}