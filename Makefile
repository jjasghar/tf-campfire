.PHONY: help init plan apply destroy validate format clean

help: ## Show this help message
	@echo "Campfire Terraform Deployment"
	@echo "============================="
	@echo ""
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

init: ## Initialize Terraform
	terraform init

plan: ## Create Terraform plan
	terraform plan

apply: ## Apply Terraform configuration
	terraform apply -auto-approve

destroy: ## Destroy all resources
	terraform destroy

validate: ## Validate Terraform configuration
	terraform validate

format: ## Format Terraform files
	terraform fmt -recursive

clean: ## Clean Terraform files
	rm -rf .terraform/
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate*
	rm -f crash.log

setup: ## Initial setup
	@echo "Setting up Campfire deployment..."
	@if [ ! -f terraform.tfvars ]; then \
		cp terraform.tfvars.example terraform.tfvars; \
		echo "Created terraform.tfvars from example"; \
		echo "Please edit terraform.tfvars with your configuration"; \
	else \
		echo "terraform.tfvars already exists"; \
	fi

vapid-keys: ## Generate VAPID keys for Web Push
	@echo "Generating VAPID keys..."
	@./scripts/generate-vapid-keys.sh

status: ## Show deployment status
	@echo "Terraform State:"
	@terraform show -no-color | head -20
	@echo ""
	@echo "Outputs:"
	@terraform output

ssh: ## SSH into the deployed instance
	@echo "Connecting to Campfire instance..."
	@ssh root@$$(terraform output -raw instance_ip)

logs: ## View Campfire application logs
	@echo "Viewing Campfire logs..."
	@ssh root@$$(terraform output -raw instance_ip) "cd /opt/campfire && docker-compose logs -f"

restart: ## Restart Campfire application
	@echo "Restarting Campfire application..."
	@ssh root@$$(terraform output -raw instance_ip) "cd /opt/campfire && docker-compose restart"

update: ## Update Campfire application
	@echo "Updating Campfire application..."
	@ssh root@$$(terraform output -raw instance_ip) "cd /opt/campfire && docker-compose down && docker build -t campfire:latest https://github.com/basecamp/once-campfire.git && docker-compose up -d"

test-deploy: ## Deploy in test mode with random domain hash
	@echo "Deploying in test mode..."
	@cp terraform.tfvars.example terraform.tfvars
	@echo "⚠️  Please edit terraform.tfvars and set production = false for test mode"
	@terraform apply -auto-approve
	@echo "Test deployment complete!"
	@echo "Test URL: $$(terraform output -raw campfire_url)"

test-destroy: ## Destroy test deployment
	@echo "Destroying test deployment..."
	@terraform destroy -auto-approve

prod-deploy: ## Deploy in production mode with clean domain
	@echo "Deploying in production mode..."
	@cp terraform.tfvars.example terraform.tfvars
	@terraform apply -auto-approve
	@echo "Production deployment complete!"
	@echo "Production URL: $$(terraform output -raw campfire_url)"

prod-destroy: ## Destroy production deployment
	@echo "Destroying production deployment..."
	@terraform destroy -auto-approve

# Configuration targets
config-ibm: ## Copy IBM Cloud example configuration
	@echo "📋 Copying IBM Cloud example configuration..."
	@cp terraform.tfvars.example terraform.tfvars
	@echo "✅ Configuration copied. Edit terraform.tfvars and set cloud_provider = \"ibm\""

config-do: ## Copy DigitalOcean example configuration
	@echo "📋 Copying DigitalOcean example configuration..."
	@cp terraform.tfvars.example terraform.tfvars
	@echo "✅ Configuration copied. Edit terraform.tfvars and set cloud_provider = \"digitalocean\""
