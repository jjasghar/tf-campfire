output "instance_ip" {
  description = "Public IP address of the Campfire instance"
  value       = ibm_is_floating_ip.campfire_fip.address
}

output "ssh_connection" {
  description = "SSH command to connect to the instance"
  value       = "ssh root@${ibm_is_floating_ip.campfire_fip.address}"
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = ibm_is_vpc.campfire_vpc.id
}

output "instance_id" {
  description = "ID of the created instance"
  value       = ibm_is_instance.campfire_instance.id
}

output "production" {
  description = "Whether production mode is enabled"
  value       = var.production
}

output "campfire_url" {
  description = "URL to access the Campfire application"
  value       = "https://${local.display_domain}"
}

output "dns_record" {
  description = "DNS record created for the application"
  value       = "${local.display_domain} -> ${ibm_is_floating_ip.campfire_fip.address}"
}

output "actual_domain" {
  description = "The actual domain name with hash (if applicable)"
  value       = local.display_domain
}

output "ssh_key_used" {
  description = "SSH key being used for instance access"
  value       = var.ibm_ssh_key_id != null ? "Existing IBM Cloud SSH key: ${var.ibm_ssh_key_id}" : "New SSH key created: ${ibm_is_ssh_key.campfire_key[0].name}"
}
