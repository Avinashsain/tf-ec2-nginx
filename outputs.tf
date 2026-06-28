# -------------------------------------------------------
# outputs.tf — Expose useful info after terraform apply
# NOTE: S3 + DynamoDB outputs removed — those resources
#       live in bootstrap/ not the root module.
# -------------------------------------------------------

output "instance_public_ip" {
  description = "Public IP address of the Nginx EC2 instance"
  value       = aws_instance.nginx_server.public_ip
}

output "nginx_url" {
  description = "URL to access the Nginx web server"
  value       = "http://${aws_instance.nginx_server.public_ip}"
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.nginx_server.id
}

output "ssh_command" {
  description = "Ready-to-run SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.nginx_server.public_ip}"
}
