# Terraform Campfire Deployment - Multi-Cloud

Deploy [Basecamp's Once Campfire](https://github.com/basecamp/once-campfire) chat application on **IBM Cloud** or **DigitalOcean** using Terraform with automatic SSL certificate management via Caddy.

## 🚀 Features

- **One-Command Deployment**: Deploy with `terraform apply -auto-approve` - no manual intervention required!
- **Automatic SSL**: Caddy handles SSL certificates via Let's Encrypt with automatic HTTP→HTTPS redirect
- **Production & Test Modes**: Choose between clean domains or hash-suffixed domains for testing
- **Multi-Cloud Support**: IBM Cloud (VPC, VMs, Security Groups) or DigitalOcean (Droplets)
- **DNS Management**: Automatic DNS record creation via DNSimple
- **Security Headers**: HSTS, XSS protection, clickjacking protection, and more
- **High Availability**: Systemd service for auto-restart on boot
- **Real-Time Installation**: See installation progress in terminal via remote-exec provisioners
- **Race Condition Handling**: Built-in delays and restart logic to ensure reliable startup
- **Flexible SSH Keys**: Use existing cloud provider SSH keys or provide public keys

## ⚡ Quick Start

```bash
# 1. Clone and configure
git clone https://github.com/jjasghar/tf-campfire.git
cd tf-campfire
cp terraform.tfvars.example terraform.tfvars

# 2. Edit terraform.tfvars with your settings
# Set cloud_provider = "ibm" or "digitalocean"
# Add your API keys and domain settings

# 3. Deploy
terraform init
terraform apply -auto-approve

# 4. Access your Campfire instance
# Check the output for your URL!
```

**That's it!** Your Campfire instance will be running with automatic SSL certificates.

## 🏗️ Architecture

```
Internet → Cloud Provider → Instance → Caddy (SSL Termination) → Campfire App
                ↓
         DNSimple DNS Records
```

- **Caddy**: Reverse proxy with automatic SSL certificate management and HTTP→HTTPS redirect
- **Campfire**: Rails application running on internal port 3000 (SSL disabled, handled by Caddy)
- **Cloud Provider**: IBM Cloud (VPC, VM, Security Groups) or DigitalOcean (Droplet)
- **DNSimple**: DNS record management with automatic A record creation
- **Systemd**: Service management for automatic startup and restart

## 📋 Prerequisites

### Required Accounts
- **Cloud Provider Account**: IBM Cloud (with VPC access) OR DigitalOcean
- **DNSimple Account** for DNS management
- **Domain Name** registered with DNSimple

### Required Tools
- [Terraform](https://terraform.io/downloads) >= 1.0
- SSH key pair for VM access
- **For IBM Cloud**: [IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli)
- **For DigitalOcean**: [DigitalOcean CLI](https://docs.digitalocean.com/reference/doctl/) (optional)

## 🛠️ Setup

### 1. Clone Repository
```bash
git clone https://github.com/jjasghar/tf-campfire.git
cd tf-campfire
```

### 2. Choose Cloud Provider

#### Option A: IBM Cloud
- **Pros**: Enterprise-grade, VPC networking, advanced security
- **Cons**: More complex setup, higher cost
- **Best for**: Production deployments, enterprise use

#### Option B: DigitalOcean
- **Pros**: Simple setup, lower cost, fast deployment
- **Cons**: Less enterprise features
- **Best for**: Development, testing, small production

### 3. Get Required Information

#### IBM Cloud API Key (if using IBM Cloud)
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

#### DigitalOcean API Token (if using DigitalOcean)
1. Go to [DigitalOcean API Tokens](https://cloud.digitalocean.com/account/api/tokens)
2. Generate a new token with read/write permissions

#### DigitalOcean SSH Key ID (if using existing SSH key)
1. Go to [DigitalOcean SSH Keys](https://cloud.digitalocean.com/account/security)
2. Copy the ID of your existing SSH key
3. Or use the CLI: `doctl compute ssh-key list`

#### DNSimple Account ID
1. Go to [DNSimple Account](https://dnsimple.com/account)
2. Copy the Account ID from the URL or settings

### 4. Configure Variables

Copy the example file and edit:
```bash
cp terraform.tfvars.example terraform.tfvars
```

The example file contains comprehensive documentation and examples for both IBM Cloud and DigitalOcean. Simply uncomment and configure the variables for your chosen provider.

**Key Configuration Steps:**
1. Set `cloud_provider = "ibm"` or `cloud_provider = "digitalocean"`
2. Uncomment and configure the variables for your chosen provider
3. Set your API keys/tokens
4. Configure your domain and DNSimple settings

**Quick Start Examples:**

**IBM Cloud:**
```hcl
cloud_provider = "ibm"
ibm_api_key = "your-ibm-cloud-api-key"
ibm_region = "us-south"
zone = "1"
resource_group_id = "your-resource-group-id"
production = true
```

**DigitalOcean:**
```hcl
cloud_provider = "digitalocean"
digitalocean_token = "your-digitalocean-api-token"
digitalocean_region = "nyc3"
digitalocean_size = "s-2vcpu-4gb"
production = true
```

**Common Settings (both providers):**
```hcl
domain_name = "example.com"
subdomain = "chat"
dnsimple_token = "your-dnsimple-api-token"
dnsimple_account = "your-dnsimple-account-id"
```

**SSH Key Options:**
```hcl
# Option 1: Provide public key (creates new SSH key)
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... your-email@example.com"

# Option 2: Use existing IBM Cloud SSH key (IBM Cloud only)
# ibm_ssh_key_id = "your-ibm-cloud-ssh-key-id"

# Option 3: Use existing DigitalOcean SSH key (DigitalOcean only)
# digitalocean_ssh_key_id = "your-digitalocean-ssh-key-id"
```

> **📖 Detailed Configuration**: The `terraform.tfvars.example` file contains comprehensive documentation, all available options, and multiple example configurations. Simply copy it and uncomment the variables you need.

### 📋 Configuration File Features

The `terraform.tfvars.example` file includes:

- **🔧 Complete Documentation**: Every variable is documented with descriptions and examples
- **🌐 Multi-Cloud Support**: Examples for both IBM Cloud and DigitalOcean
- **⚙️ All Options**: Every available configuration option with explanations
- **📝 Multiple Examples**: Production, test, and provider-specific configurations
- **🔍 Easy Navigation**: Well-organized sections with clear headers
- **💡 Best Practices**: Recommended settings and security considerations

## 🚀 Deployment

### Deployment Steps
```bash
# 1. Copy and configure the example file
cp terraform.tfvars.example terraform.tfvars

# 2. Edit terraform.tfvars with your configuration
# Set cloud_provider = "ibm" or "digitalocean"
# Uncomment and configure the variables for your chosen provider

# 3. Deploy
terraform init
terraform apply -auto-approve
```

### Using Makefile (Recommended)
```bash
# Configuration helpers
make config-ibm     # Copy example file for IBM Cloud
make config-do      # Copy example file for DigitalOcean

# Deployment
make prod-deploy    # Production deployment
make test-deploy    # Test deployment with random domain hash
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

#### IBM Cloud Profiles
| Profile | vCPU | RAM | Use Case |
|---------|------|-----|----------|
| `cx2-2x4` | 2 | 4GB | Development, testing |
| `cx2-4x8` | 4 | 8GB | Small production |
| `cx2-8x16` | 8 | 16GB | Medium production |
| `cx2-16x32` | 16 | 32GB | Large production |

#### DigitalOcean Droplet Sizes
| Size | vCPU | RAM | Use Case |
|------|------|-----|----------|
| `s-1vcpu-1gb` | 1 | 1GB | Development, testing |
| `s-2vcpu-2gb` | 2 | 2GB | Small production |
| `s-2vcpu-4gb` | 2 | 4GB | Medium production |
| `s-4vcpu-8gb` | 4 | 8GB | Large production |

## 🔒 Security Features

- **Automatic SSL**: Let's Encrypt certificates via Caddy with automatic renewal
- **HSTS**: HTTP Strict Transport Security with preload support
- **Security Headers**: XSS protection, clickjacking protection, content type options
- **HTTP Redirect**: All HTTP traffic automatically redirects to HTTPS (308 redirect)
- **Firewall**: IBM Cloud Security Groups or DigitalOcean firewall rules
- **SSH Access**: Key-based authentication only (no password authentication)
- **SSL Termination**: Caddy handles all SSL/TLS, Campfire runs on internal port 3000

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
├── main.tf                    # Main Terraform configuration with multi-cloud support
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── versions.tf                # Provider version constraints
├── docker-compose.yml.tpl     # Docker Compose template with Caddy reverse proxy
├── setup_campfire.sh          # Application setup script with race condition handling
├── terraform.tfvars.example   # Comprehensive example configuration
├── terraform.tfvars           # Your actual configuration (create from example)
└── README.md                  # This file
```

## 🔧 Troubleshooting

### Common Issues

1. **SSL Certificate Issues**
   - Check DNS propagation: `nslookup your-domain.com`
   - Verify domain points to correct IP
   - Check Caddy logs: `docker-compose logs caddy`
   - Ensure domain is accessible from the internet

2. **Application Not Starting**
   - Check container status: `docker-compose ps`
   - View logs: `docker-compose logs campfire`
   - Restart: `docker-compose restart`
   - Check systemd service: `systemctl status campfire`

3. **502 Bad Gateway Errors**
   - This usually indicates Caddy can't reach Campfire
   - Check if Campfire is running: `docker-compose ps`
   - Restart Caddy: `docker-compose restart caddy`
   - Wait for Campfire to fully initialize (30-60 seconds)

4. **SSH Connection Issues**
   - Verify SSH key is correct
   - Check security group allows SSH (port 22)
   - Ensure instance is running
   - Try connecting with verbose output: `ssh -v root@your-ip`

5. **DNS Issues**
   - Verify DNSimple token and account ID
   - Check domain is managed by DNSimple
   - Wait for DNS propagation (up to 24 hours)
   - Verify A record was created correctly

6. **Docker Installation Issues (DigitalOcean)**
   - The deployment now uses `apt-get install docker.io` for reliability
   - If issues persist, check system logs: `journalctl -u docker`

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

## 🆕 Recent Improvements

### Version 2.0 - Multi-Cloud & Reliability Updates

- **✅ Multi-Cloud Support**: Seamless switching between IBM Cloud and DigitalOcean
- **✅ Race Condition Fixes**: Built-in delays and restart logic for reliable startup
- **✅ Docker Installation**: Improved DigitalOcean Docker installation using `apt-get`
- **✅ SSL Termination**: Caddy handles all SSL/TLS, Campfire runs on internal port 3000
- **✅ Real-Time Installation**: See installation progress via remote-exec provisioners
- **✅ Flexible SSH Keys**: Support for existing cloud provider SSH keys
- **✅ Production Ready**: No manual intervention required - just `terraform apply -auto-approve`

### Key Technical Improvements

- **Caddy Reverse Proxy**: Automatic SSL certificates and HTTP→HTTPS redirect
- **Race Condition Handling**: 30-second delay + Caddy restart to ensure Campfire is ready
- **Sensitive Output Management**: Proper handling of domain names with random hashes
- **Multi-Provider Architecture**: Conditional resource creation based on `cloud_provider` variable
- **Systemd Integration**: Automatic service startup and restart on boot

## 🙏 Acknowledgments

- [Basecamp](https://github.com/basecamp) for the Once Campfire application
- [Caddy](https://caddyserver.com/) for automatic SSL management
- [IBM Cloud](https://cloud.ibm.com/) for cloud infrastructure
- [DigitalOcean](https://www.digitalocean.com/) for cloud infrastructure
- [DNSimple](https://dnsimple.com/) for DNS management

## 📞 Support

- Create an [issue](https://github.com/jjasghar/tf-campfire/issues) for bugs
- Start a [discussion](https://github.com/jjasghar/tf-campfire/discussions) for questions
- Check the [Wiki](https://github.com/jjasghar/tf-campfire/wiki) for documentation

---

**Happy Chatting! 🎉**

If you're wondering there is a `/play` command in the chat, you can use any of these:
```
"56k","ballmer","bell","bezos","bueller","butts","clowntown","cottoneyejoe","crickets","curb","dadgummit","dangerzone","danielsan","deeper","donotwant","drama","flawless","glados","gogogo","greatjob","greyjoy","guarantee","heygirl","honk","horn","horror","inconceivable","letitgo","live","loggins","makeitso","noooo","nyan","ohmy","ohyeah","pushit","rimshot","rollout","rumble","sax","secret","sexyback","story","tada","tmyk","totes","trololo","trombone","unix","vuvuzela","what","whoomp","wups","yay","yeah","yodel".
```
