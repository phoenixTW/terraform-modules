output "sg_id" {
  value       = aws_security_group.bastion_ec2_sg.id
  description = "Security group id of bastion"
}

output "instance_id" {
  value       = aws_instance.bastion_ec2.id
  description = "ID of bastion instance"
}
