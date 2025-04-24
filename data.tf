// Get VPC data.
data "aws_vpc" "current_vpc" {
  id = var.aws_vpc_id
}

// Choosing the image for NAT Instance.
data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = [var.amazon_ec2_linux_image]
  }
  filter {
    name   = "virtualization-type"
    values = [var.amazon_ec2_instance_virtualization_type]
  }
  owners = [var.amazon_owner_id]
}

// NAT Instance template.
data "template_file" "nat_instance_setup_template" {
  template = file("${path.module}/nat-instance-setup.sh.tpl")
  vars = {
    cidr_block = "${data.aws_vpc.current_vpc.cidr_block}"
  }
}

// Get NAT Instance data.
data "aws_instance" "nat_instance_data" {
  instance_id = aws_instance.nat_instance.id
}

// Get route tables of private networks in in provided VPC.
data "aws_route_tables" "route_tables_of_private_networks" {
  vpc_id = var.aws_vpc_id

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}