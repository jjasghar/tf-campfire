output "instance_ip" {
  description = "Public IP address of the Campfire instance"
  value       = var.cloud_provider == "ibm" ? ibm_is_floating_ip.campfire_fip[0].address : digitalocean_droplet.campfire_droplet[0].ipv4_address
}

output "ssh_connection" {
  description = "SSH command to connect to the instance"
  value       = var.cloud_provider == "ibm" ? "ssh root@${ibm_is_floating_ip.campfire_fip[0].address}" : "ssh root@${digitalocean_droplet.campfire_droplet[0].ipv4_address}"
}

output "vpc_id" {
  description = "ID of the created VPC (IBM Cloud only)"
  value       = var.cloud_provider == "ibm" ? ibm_is_vpc.campfire_vpc[0].id : "N/A (DigitalOcean)"
}

output "instance_id" {
  description = "ID of the created instance"
  value       = var.cloud_provider == "ibm" ? ibm_is_instance.campfire_instance[0].id : digitalocean_droplet.campfire_droplet[0].id
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
  value       = "${local.display_domain} -> ${var.cloud_provider == "ibm" ? ibm_is_floating_ip.campfire_fip[0].address : digitalocean_droplet.campfire_droplet[0].ipv4_address}"
}

output "actual_domain" {
  description = "The actual domain name with hash (if applicable)"
  value       = local.display_domain
}

output "ssh_key_used" {
  description = "SSH key being used for instance access"
  value       = var.cloud_provider == "ibm" ? (var.ibm_ssh_key_id != null ? "Existing IBM Cloud SSH key: ${var.ibm_ssh_key_id}" : "New IBM Cloud SSH key created: ${ibm_is_ssh_key.campfire_key[0].name}") : (var.digitalocean_ssh_key_id != null ? "Existing DigitalOcean SSH key: ${var.digitalocean_ssh_key_id}" : (var.ssh_public_key != null ? "New DigitalOcean SSH key created: ${digitalocean_ssh_key.campfire_key[0].name}" : "No SSH key provided"))
}
