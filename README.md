# Terraform Campfire Deployment on IBM Cloud

Deploy [Basecamp's Once Campfire](https://github.com/basecamp/once-campfire) chat application on IBM Cloud using Terraform with automatic SSL certificate management via Caddy.

## 🚀 Features

- **One-Command Deployment**: Deploy with `terraform apply -auto-approve`
- **Automatic SSL**: Caddy handles SSL certificates via Let's Encrypt
- **Production & Test Modes**: Choose between clean domains or hash-suffixed domains
- **IBM Cloud Integration**: VPC, VMs, Security Groups, Floating IPs
- **DNS Management**: Automatic DNS record creation via DNSimple
- **Security Headers**: HSTS, XSS protection, clickjacking protection
- **High Availability**: Systemd service for auto-restart
- **Remote-Exec Visibility**: See installation progress in real-time

## 🏗️ Architecture

```
Internet → IBM Cloud VPC → Floating IP → Caddy (SSL Termination) → Campfire App
                ↓
         DNSimple DNS Records
```

- **Caddy**: Reverse proxy with automatic SSL certificate management
- **Campfire**: Rails application running on internal port 3000
- **IBM Cloud**: VPC, VM, Security Groups, Floating IP
- **DNSimple**: DNS record management

## 📋 Prerequisites

### Required Accounts
- **IBM Cloud Account** with VPC access
- **DNSimple Account** for DNS management
- **Domain Name** registered with DNSimple

### Required Tools
- [Terraform](https://terraform.io/downloads) >= 1.0
- [IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli)
- SSH key pair for VM access

## 🛠️ Setup

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/tf-campfire.git
cd tf-campfire
```

### 2. Get Required Information

#### IBM Cloud API Key
```bash
ibmcloud login
ibmcloud iam api-key-create terraform-key
```

#### IBM Cloud Resource Group ID
```bash
ibmcloud resource groups
```

#### IBM Cloud SSH Key ID
```bash
ibmcloud is keys
```

#### DNSimple API Token
1. Go to [DNSimple Account Settings](https://dnsimple.com/user)
2. Navigate to "API Tokens"
3. Create a new token

#### DNSimple Account ID
1. Go to [DNSimple Account](https://dnsimple.com/account)
2. Copy the Account ID from the URL or settings

### 3. Configure Variables

Copy the example file and edit:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:
```hcl
# IBM Cloud Configuration
ibm_api_key      = "your-ibm-cloud-api-key"
ibm_region       = "us-south"
zone             = "1"
resource_group_id = "your-resource-group-id"

# Project Configuration
project_name = "campfire"
domain_name  = "example.com"
subdomain    = "chat"

# DNSimple Configuration
dnsimple_token   = "your-dnsimple-api-token"
dnsimple_account = "your-dnsimple-account-id"

# SSH Configuration (choose one)
ibm_ssh_key_id = "your-ibm-cloud-ssh-key-id"
# OR
# ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... your-email@example.com"

# Production Configuration
production   = true  # true = clean domain, false = add random hash
hash_length  = 6     # Length of random hash (4-12 characters)

# Instance Configuration
instance_image   = "r134-4a0a0a0a-4a0a-4a0a-4a0a-4a0a0a0a0a0a" # Ubuntu 22.04 LTS
instance_profile = "cx2-2x4" # 2 vCPU, 4GB RAM

# Campfire Configuration (Optional)
vapid_public_key  = "" # Leave empty to generate automatically
vapid_private_key = "" # Leave empty to generate automatically
sentry_dsn        = "" # Leave empty to disable error reporting

# Network Configuration
subnet_cidr = "10.240.0.0/24"

# Tags
tags = ["terraform", "campfire", "production"]
```

## 🚀 Deployment

### Production Deployment
```bash
terraform init
terraform plan
terraform apply -auto-approve
```

### Test Deployment
```bash
cp terraform.test.tfvars.example terraform.tfvars
terraform apply -auto-approve
```

## 📊 Outputs

After deployment, you'll get:
- **campfire_url**: Your Campfire application URL
- **dns_record**: DNS record created
- **instance_ip**: Server IP address
- **ssh_connection**: SSH command to connect
- **production**: Whether production mode is enabled

## 🔧 Configuration Options

### Production vs Test Mode

| Mode | Domain Example | Use Case |
|------|----------------|----------|
| Production (`production = true`) | `chat.example.com` | Live deployment |
| Test (`production = false`) | `chat-abc123.example.com` | Testing, development |

### Instance Sizes

| Profile | vCPU | RAM | Use Case |
|---------|------|-----|----------|
| `cx2-2x4` | 2 | 4GB | Development, testing |
| `cx2-4x8` | 4 | 8GB | Small production |
| `cx2-8x16` | 8 | 16GB | Medium production |
| `cx2-16x32` | 16 | 32GB | Large production |

## 🔒 Security Features

- **Automatic SSL**: Let's Encrypt certificates via Caddy
- **HSTS**: HTTP Strict Transport Security
- **Security Headers**: XSS protection, clickjacking protection
- **HTTP Redirect**: All HTTP traffic redirects to HTTPS
- **Firewall**: IBM Cloud Security Groups
- **SSH Access**: Key-based authentication only

## 🛠️ Management

### View Application Status
```bash
terraform output
```

### SSH into Server
```bash
ssh root@$(terraform output -raw instance_ip)
```

### View Logs
```bash
ssh root@$(terraform output -raw instance_ip) "cd /opt/campfire && docker-compose logs"
```

### Restart Application
```bash
ssh root@$(terraform output -raw instance_ip) "cd /opt/campfire && docker-compose restart"
```

### Update Application
```bash
ssh root@$(terraform output -raw instance_ip) "cd /opt/campfire && docker-compose pull && docker-compose up -d"
```

## 🗑️ Cleanup

To destroy the infrastructure:
```bash
terraform destroy -auto-approve
```

## 📁 File Structure

```
tf-campfire/
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Variable definitions
├── outputs.tf              # Output definitions
├── versions.tf             # Provider version constraints
├── docker-compose.yml.tpl  # Docker Compose template
├── setup_campfire.sh       # Application setup script
├── terraform.tfvars.example    # Production example
├── terraform.test.tfvars.example # Test example
├── Makefile               # Convenience commands
├── quick-start.sh         # Quick setup script
└── README.md              # This file
```

## 🔧 Troubleshooting

### Common Issues

1. **SSL Certificate Issues**
   - Check DNS propagation: `nslookup your-domain.com`
   - Verify domain points to correct IP
   - Check Caddy logs: `docker-compose logs caddy`

2. **Application Not Starting**
   - Check container status: `docker-compose ps`
   - View logs: `docker-compose logs campfire`
   - Restart: `docker-compose restart`

3. **SSH Connection Issues**
   - Verify SSH key is correct
   - Check security group allows SSH (port 22)
   - Ensure instance is running

4. **DNS Issues**
   - Verify DNSimple token and account ID
   - Check domain is managed by DNSimple
   - Wait for DNS propagation (up to 24 hours)

### Debug Commands

```bash
# Check Terraform state
terraform show

# View all outputs
terraform output -json

# Check instance status
ibmcloud is instances

# Check DNS records
nslookup your-domain.com
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Basecamp](https://github.com/basecamp) for the Once Campfire application
- [Caddy](https://caddyserver.com/) for automatic SSL management
- [IBM Cloud](https://cloud.ibm.com/) for cloud infrastructure
- [DNSimple](https://dnsimple.com/) for DNS management

## 📞 Support

- Create an [issue](https://github.com/yourusername/tf-campfire/issues) for bugs
- Start a [discussion](https://github.com/yourusername/tf-campfire/discussions) for questions
- Check the [Wiki](https://github.com/yourusername/tf-campfire/wiki) for documentation

---

**Happy Chatting! 🎉**