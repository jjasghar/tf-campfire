variable "ibm_api_key" {
  description = "IBM Cloud API key"
  type        = string
  sensitive   = true
}

variable "ibm_region" {
  description = "IBM Cloud region"
  type        = string
  default     = "us-south"
}

variable "zone" {
  description = "IBM Cloud zone within the region"
  type        = string
  default     = "1"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "campfire"
}

variable "domain_name" {
  description = "Domain name for the Campfire instance (e.g., example.com)"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for the Campfire instance (e.g., chat for chat.example.com)"
  type        = string
  default     = "chat"
}

variable "dnsimple_token" {
  description = "DNSimple API token"
  type        = string
  sensitive   = true
}

variable "dnsimple_account" {
  description = "DNSimple account ID"
  type        = string
}

variable "ibm_ssh_key_id" {
  description = "IBM Cloud SSH key ID (alternative to ssh_public_key)"
  type        = string
  default     = null
}

variable "ssh_public_key" {
  description = "SSH public key for instance access (alternative to ibm_ssh_key_id)"
  type        = string
  default     = null
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key for remote-exec provisioners"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "resource_group_id" {
  description = "IBM Cloud resource group ID"
  type        = string
}

variable "instance_image" {
  description = "IBM Cloud instance image ID"
  type        = string
  default     = "r134-4a0a0a0a-4a0a-4a0a-4a0a-4a0a0a0a0a0a" # Ubuntu 22.04 LTS
}

variable "instance_profile" {
  description = "IBM Cloud instance profile"
  type        = string
  default     = "cx2-2x4" # 2 vCPU, 4GB RAM
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.240.0.0/24"
}

variable "vapid_public_key" {
  description = "VAPID public key for Web Push notifications"
  type        = string
  default     = ""
}

variable "vapid_private_key" {
  description = "VAPID private key for Web Push notifications"
  type        = string
  default     = ""
  sensitive   = true
}

variable "sentry_dsn" {
  description = "Sentry DSN for error reporting"
  type        = string
  default     = ""
}

variable "disable_ssl" {
  description = "Disable SSL (set to true for HTTP only)"
  type        = bool
  default     = false
}

variable "production" {
  description = "Production mode - true means no hash added to domain, false means add random hash"
  type        = bool
  default     = true
}

variable "hash_length" {
  description = "Length of random hash for non-production mode (4-12 characters)"
  type        = number
  default     = 6
  validation {
    condition     = var.hash_length >= 4 && var.hash_length <= 12
    error_message = "Hash length must be between 4 and 12 characters."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = list(string)
  default     = ["terraform", "campfire"]
}
