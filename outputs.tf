output "public_instance_dns" {
  description = "This is the public instance dns for ssh connection"
  value = aws_instance.public_ec2.public_dns
}

output "ssh_command" {
    description = "command for ssh access"
    value = "ssh -i public-instance.pem ubuntu@${aws_instance.public_ec2.public_dns}"
  
}

output "public_instance_ip" {
    description = "public ip of default instance in public subnet"
    value = aws_instance.public_ec2.public_ip
  
}