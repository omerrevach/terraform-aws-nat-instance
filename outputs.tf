output "nat_instance" {
    value = aws_instance.nat_instance
}

output "nat_instance_id" {
    value = aws_instance.nat_instance.id
}