#!/bin/bash

# Script to generate VAPID keys for Campfire Web Push notifications
# This script requires Node.js and npm to be installed

echo "Generating VAPID keys for Campfire Web Push notifications..."
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed. Please install Node.js first."
    echo "Visit: https://nodejs.org/"
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "Error: npm is not installed. Please install npm first."
    exit 1
fi

# Install web-push if not already installed
if ! npm list -g web-push &> /dev/null; then
    echo "Installing web-push package..."
    npm install -g web-push
fi

# Generate VAPID keys
echo "Generating VAPID keys..."
web-push generate-vapid-keys

echo ""
echo "Add these keys to your terraform.tfvars file:"
echo "vapid_public_key  = \"<public_key_here>\""
echo "vapid_private_key = \"<private_key_here>\""
echo ""
echo "Note: Keep the private key secure and never commit it to version control!"
