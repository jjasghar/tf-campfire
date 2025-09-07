#!/bin/bash

# Quick start script for Campfire deployment
# This script helps set up the required configuration

set -e

echo "🚀 Campfire Terraform Deployment Quick Start"
echo "============================================="
echo ""

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Error: Terraform is not installed."
    echo "Please install Terraform first: https://www.terraform.io/downloads.html"
    exit 1
fi

# Check if IBM Cloud CLI is installed
if ! command -v ibmcloud &> /dev/null; then
    echo "❌ Error: IBM Cloud CLI is not installed."
    echo "Please install IBM Cloud CLI first: https://cloud.ibm.com/docs/cli"
    exit 1
fi

echo "✅ Prerequisites check passed"
echo ""

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "📝 Creating terraform.tfvars from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo "✅ Created terraform.tfvars"
    echo ""
    echo "⚠️  Please edit terraform.tfvars with your configuration before proceeding"
    echo "   Required values:"
    echo "   - ibm_api_key"
    echo "   - ibm_region"
    echo "   - resource_group_id"
    echo "   - domain_name"
    echo "   - dnsimple_token"
    echo "   - dnsimple_account"
    echo "   - Either ibm_ssh_key_id OR ssh_public_key"
    echo "   - production (true for clean domain, false for hash)"
    echo ""
    echo "   Run: nano terraform.tfvars"
    exit 0
fi

echo "🔍 Validating configuration..."

# Check if required variables are set
source terraform.tfvars 2>/dev/null || true

if [ -z "$ibm_api_key" ] || [ -z "$domain_name" ] || [ -z "$dnsimple_token" ] || [ -z "$dnsimple_account" ]; then
    echo "❌ Error: Required variables not set in terraform.tfvars"
    echo "Please ensure the following are configured:"
    echo "  - ibm_api_key"
    echo "  - domain_name"
    echo "  - dnsimple_token"
    echo "  - dnsimple_account"
    echo "  - Either ibm_ssh_key_id OR ssh_public_key"
    exit 1
fi

if [ -z "$ibm_ssh_key_id" ] && [ -z "$ssh_public_key" ]; then
    echo "❌ Error: SSH key configuration missing"
    echo "Please provide either:"
    echo "  - ibm_ssh_key_id (existing IBM Cloud SSH key)"
    echo "  - ssh_public_key (will create new IBM Cloud SSH key)"
    exit 1
fi

echo "✅ Configuration validation passed"
echo ""

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

echo ""
echo "📋 Running Terraform plan..."
terraform plan

echo ""
echo "🚀 Ready to deploy! Run the following command to deploy:"
echo "   terraform apply -auto-approve"
echo ""
echo "📖 For more information, see README.md"
