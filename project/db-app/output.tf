output "instance_dns_name" {
    value = aws_instance.web.public_dns
}

# output "application_properties" {
#     value = local_file.sb-config.content
# }