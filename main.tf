terraform {
  required_version = ">= 1.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    dnsimple = {
      source  = "dnsimple/dnsimple"
      version = "~> 0.9"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

# Configure the IBM Cloud Provider
provider "ibm" {
  ibmcloud_api_key = var.ibm_api_key
  region           = var.ibm_region
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.digitalocean_token
}

# Configure the DNSimple Provider
provider "dnsimple" {
  token   = var.dnsimple_token
  account = var.dnsimple_account
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Generate random password for database
resource "random_password" "db_password" {
  length  = 32
  special = true
}

# Generate random secret key base
resource "random_password" "secret_key_base" {
  length  = 64
  special = true
}

# Generate random hash for non-production mode
resource "random_password" "domain_hash" {
  count   = var.production ? 0 : 1
  length  = var.hash_length
  special = false
  upper   = false
  lower   = true
  numeric = true
}

# Local values for domain construction
locals {
  hash_suffix = var.production ? "" : "-${random_password.domain_hash[0].result}"
  full_domain = "${var.subdomain}${local.hash_suffix}.${var.domain_name}"

  # Non-sensitive domain for outputs (shows the actual domain)
  display_domain = var.production ? "${var.subdomain}.${var.domain_name}" : "${var.subdomain}-${nonsensitive(random_password.domain_hash[0].result)}.${var.domain_name}"

  # Non-sensitive domain for remote-exec provisioners
  remote_domain = var.production ? "${var.subdomain}.${var.domain_name}" : "${var.subdomain}-${nonsensitive(random_password.domain_hash[0].result)}.${var.domain_name}"

  # Validation to ensure at least one SSH key is provided
  ssh_key_validation = var.ssh_public_key != null || var.ibm_ssh_key_id != null ? true : tobool("Error: Either ssh_public_key or ibm_ssh_key_id must be provided")
}

# IBM Cloud Resources
resource "ibm_is_vpc" "campfire_vpc" {
  count = var.cloud_provider == "ibm" ? 1 : 0
  name  = "${var.project_name}-vpc"
  tags  = var.tags
}

# Create public gateway
resource "ibm_is_public_gateway" "campfire_pg" {
  count = var.cloud_provider == "ibm" ? 1 : 0
  name  = "${var.project_name}-pg"
  vpc   = ibm_is_vpc.campfire_vpc[0].id
  zone  = "${var.ibm_region}-${var.zone}"
  tags  = var.tags
}

# Create subnet
resource "ibm_is_subnet" "campfire_subnet" {
  count           = var.cloud_provider == "ibm" ? 1 : 0
  name            = "${var.project_name}-subnet"
  vpc             = ibm_is_vpc.campfire_vpc[0].id
  zone            = "${var.ibm_region}-${var.zone}"
  ipv4_cidr_block = var.subnet_cidr
  public_gateway  = ibm_is_public_gateway.campfire_pg[0].id
  tags            = var.tags
}

# Create security group
resource "ibm_is_security_group" "campfire_sg" {
  count          = var.cloud_provider == "ibm" ? 1 : 0
  name           = "${var.project_name}-sg"
  vpc            = ibm_is_vpc.campfire_vpc[0].id
  resource_group = var.resource_group_id
  tags           = var.tags
}

# Security group rules
resource "ibm_is_security_group_rule" "campfire_http" {
  count     = var.cloud_provider == "ibm" ? 1 : 0
  group     = ibm_is_security_group.campfire_sg[0].id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "campfire_https" {
  count     = var.cloud_provider == "ibm" ? 1 : 0
  group     = ibm_is_security_group.campfire_sg[0].id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "campfire_ssh" {
  count     = var.cloud_provider == "ibm" ? 1 : 0
  group     = ibm_is_security_group.campfire_sg[0].id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "campfire_outbound" {
  count     = var.cloud_provider == "ibm" ? 1 : 0
  group     = ibm_is_security_group.campfire_sg[0].id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

# Create SSH key (only if ssh_public_key is provided)
resource "ibm_is_ssh_key" "campfire_key" {
  count          = var.cloud_provider == "ibm" && var.ssh_public_key != null ? 1 : 0
  name           = "${var.project_name}-key"
  public_key     = var.ssh_public_key
  resource_group = var.resource_group_id
  tags           = var.tags
}

# Local value for SSH key ID
locals {
  ssh_key_id = var.ibm_ssh_key_id != null ? var.ibm_ssh_key_id : (
    length(ibm_is_ssh_key.campfire_key) > 0 ? ibm_is_ssh_key.campfire_key[0].id : null
  )
}

# Create floating IP
resource "ibm_is_floating_ip" "campfire_fip" {
  count  = var.cloud_provider == "ibm" ? 1 : 0
  name   = "${var.project_name}-fip"
  target = ibm_is_instance.campfire_instance[0].primary_network_interface[0].id
  tags   = var.tags
  
  depends_on = [ibm_is_instance.campfire_instance]
}

# Create instance
resource "ibm_is_instance" "campfire_instance" {
  count          = var.cloud_provider == "ibm" ? 1 : 0
  name           = "${var.project_name}-instance"
  vpc            = ibm_is_vpc.campfire_vpc[0].id
  zone           = "${var.ibm_region}-${var.zone}"
  keys           = [local.ssh_key_id]
  image          = var.instance_image
  profile        = var.instance_profile
  resource_group = var.resource_group_id
  tags           = var.tags

  primary_network_interface {
    subnet          = ibm_is_subnet.campfire_subnet[0].id
    security_groups = [ibm_is_security_group.campfire_sg[0].id]
  }

  # Remove user_data since we'll use remote-exec provisioners

  depends_on = [ibm_is_public_gateway.campfire_pg]
}

# DigitalOcean Resources
resource "digitalocean_ssh_key" "campfire_key" {
  count      = var.cloud_provider == "digitalocean" && var.ssh_public_key != null ? 1 : 0
  name       = "${var.project_name}-key"
  public_key = var.ssh_public_key
}

resource "digitalocean_droplet" "campfire_droplet" {
  count    = var.cloud_provider == "digitalocean" ? 1 : 0
  name     = "${var.project_name}-droplet"
  image    = "ubuntu-24-04-x64"
  region   = var.digitalocean_region
  size     = var.digitalocean_size
  ssh_keys = var.digitalocean_ssh_key_id != null ? [var.digitalocean_ssh_key_id] : (var.ssh_public_key != null ? [digitalocean_ssh_key.campfire_key[0].id] : [])
  tags     = var.tags

  # Enable monitoring and backups
  monitoring = true
  backups    = false
}

# Install and configure Campfire using remote-exec
resource "null_resource" "campfire_setup" {
  count      = var.cloud_provider == "ibm" ? 1 : 0
  depends_on = [ibm_is_instance.campfire_instance, ibm_is_floating_ip.campfire_fip]

  connection {
    type        = "ssh"
    user        = "root"
    host        = ibm_is_floating_ip.campfire_fip[0].address
    private_key = file(pathexpand(var.ssh_private_key_path))
  }

  provisioner "remote-exec" {
    inline = [
      "echo '🚀 Starting Campfire installation...'",
      "export DEBIAN_FRONTEND=noninteractive",
      "apt-get update",
      "apt-get upgrade -y",
      "echo '📦 Installing Docker...'",
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sh get-docker.sh",
      "usermod -aG docker root",
      "echo '📦 Installing Docker Compose...'",
      "curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "chmod +x /usr/local/bin/docker-compose",
      "echo '📁 Creating campfire directory...'",
      "mkdir -p /opt/campfire",
      "cd /opt/campfire"
    ]
  }

  provisioner "file" {
    content = templatefile("${path.module}/docker-compose.yml.tpl", {
      domain_name       = local.full_domain
      secret_key_base   = random_password.secret_key_base.result
      vapid_public_key  = var.vapid_public_key
      vapid_private_key = var.vapid_private_key
      sentry_dsn        = var.sentry_dsn
      disable_ssl       = var.disable_ssl
    })
    destination = "/opt/campfire/docker-compose.yml"
  }

  provisioner "file" {
    source      = "${path.module}/setup_campfire.sh"
    destination = "/opt/campfire/setup_campfire.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /opt/campfire/setup_campfire.sh",
      "export DOMAIN_NAME=${local.remote_domain}",
      "/opt/campfire/setup_campfire.sh"
    ]
  }
}

# Install and configure Campfire using remote-exec for DigitalOcean
resource "null_resource" "campfire_setup_do" {
  count      = var.cloud_provider == "digitalocean" ? 1 : 0
  depends_on = [digitalocean_droplet.campfire_droplet]

  connection {
    type        = "ssh"
    user        = "root"
    host        = digitalocean_droplet.campfire_droplet[0].ipv4_address
    private_key = file(pathexpand(var.ssh_private_key_path))
  }

  provisioner "remote-exec" {
    inline = [
      "echo '🚀 Starting Campfire installation...'",
      "export DEBIAN_FRONTEND=noninteractive",
      "apt-get update",
      "apt-get upgrade -y",
      "echo '📦 Installing Docker...'",
      "apt-get install -y docker.io docker-compose",
      "usermod -aG docker root",
      "systemctl start docker",
      "systemctl enable docker",
      "sleep 5",
      "docker --version",
      "echo '✅ Docker installation completed successfully'",
      "echo '📁 Creating campfire directory...'",
      "mkdir -p /opt/campfire",
      "cd /opt/campfire"
    ]
  }

  provisioner "file" {
    content = templatefile("${path.module}/docker-compose.yml.tpl", {
      domain_name       = local.full_domain
      secret_key_base   = random_password.secret_key_base.result
      vapid_public_key  = var.vapid_public_key
      vapid_private_key = var.vapid_private_key
      sentry_dsn        = var.sentry_dsn
      disable_ssl       = var.disable_ssl
    })
    destination = "/opt/campfire/docker-compose.yml"
  }

  provisioner "file" {
    source      = "${path.module}/setup_campfire.sh"
    destination = "/opt/campfire/setup_campfire.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /opt/campfire/setup_campfire.sh",
      "export DOMAIN_NAME=${local.remote_domain}",
      "systemctl start docker",
      "systemctl enable docker",
      "sleep 10",
      "docker --version"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "export DOMAIN_NAME=${local.remote_domain}",
      "docker --version",
      "/opt/campfire/setup_campfire.sh"
    ]
  }
}

# Create DNSimple DNS record
resource "dnsimple_zone_record" "campfire_dns" {
  count     = var.dns_provider == "dnsimple" ? 1 : 0
  zone_name = var.domain_name
  name      = var.production ? var.subdomain : "${var.subdomain}${local.hash_suffix}"
  value     = var.cloud_provider == "ibm" ? ibm_is_floating_ip.campfire_fip[0].address : digitalocean_droplet.campfire_droplet[0].ipv4_address
  type      = "A"
  ttl       = 300
}

resource "cloudflare_dns_record" "campfire_dns" {
  count    = var.dns_provider == "cloudflare" ? 1 : 0
  zone_id  = var.cloudflare_zone_id
  name     = var.production ? var.subdomain : "${var.subdomain}${local.hash_suffix}"
  content  = var.cloud_provider == "ibm" ? ibm_is_floating_ip.campfire_fip[0].address : digitalocean_droplet.campfire_droplet[0].ipv4_address
  type     = "A"
  ttl      = 300
  proxied  = false
}