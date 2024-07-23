output "ec2-1_public_ip" {
  value = aws_instance.ec2-1.public_ip
}
output "ec2-2_public_ip" {
  value = aws_instance.ec2-2.public_ip
}
output "loadbalencerdns" {
  value = aws_lb.LB.dns_name
}
