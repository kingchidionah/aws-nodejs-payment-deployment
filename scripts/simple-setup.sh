#!/bin/bash
#
# Simple Setup Script for Ubuntu EC2 Instance
#
# This script automates the basic setup steps:
# - System updates
# - Node.js 18.x installation
# - Git installation
# 
# Usage:
#   chmod +x scripts/simple-setup.sh
#   ./scripts/simple-setup.sh
#
# After running this script, you still need to:
# - Clone your repository
# - Configure .env file
# - Run npm install
# - Start your application
#

echo "=========================================="
echo "Simple EC2 Setup Script"
echo "=========================================="
echo ""
echo "This will install:"
echo "  • System updates"
echo "  • Node.js 18.x LTS"
echo "  • Git"
echo ""
read -p "Continue? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 1
fi

echo ""
echo "⏳ Step 1/4: Updating system packages..."
sudo apt update -y
sudo apt upgrade -y
echo "✅ System updated"

echo ""
echo "⏳ Step 2/4: Installing Node.js 18.x..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
echo "✅ Node.js installed"

node --version
npm --version

echo ""
echo "⏳ Step 3/4: Installing Git..."
sudo apt install -y git
echo "✅ Git installed"

git --version

echo ""
echo "⏳ Step 4/4: Installing screen (for keeping app running)..."
sudo apt install -y screen
echo "✅ Screen installed"

echo ""
echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Clone your repository:"
echo "   git clone https://github.com/kingchidionah/aws-nodejs-payment-deployment.git"
echo ""
echo "2. Navigate to project:"
echo "   cd aws-nodejs-payment-deployment"
echo ""
echo "3. Configure environment:"
echo "   cp .env.example .env"
echo "   nano .env"
echo ""
echo "4. Install dependencies:"
echo "   npm install"
echo ""
echo "5. Start application with screen:"
echo "   screen -S nodejs-app"
echo "   npm start"
echo "   # Press Ctrl+A then D to detach"
echo ""
echo "=========================================="
