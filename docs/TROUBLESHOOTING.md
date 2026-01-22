# 🔧 Troubleshooting Guide

Common issues and solutions for deploying Node.js applications on AWS EC2.

---

## 📑 Table of Contents

- [SSH Connection Problems](#ssh-connection-problems)
- [Application Won't Start](#application-wont-start)
- [Can't Access from Browser](#cant-access-from-browser)
- [AWS Console Issues](#aws-console-issues)
- [Node.js / npm Problems](#nodejs--npm-problems)
- [Environment Variable Issues](#environment-variable-issues)

---

## 🔐 SSH Connection Problems

### Problem: "Permission denied (publickey)"

**Error message:**
```
ubuntu@54.123.45.67: Permission denied (publickey).
```

**Solution 1: Fix key file permissions**
```bash
# Key must be read-only by you
chmod 400 ~/.ssh/nodejs-app-key.pem

# Try connecting again
ssh -i ~/.ssh/nodejs-app-key.pem ubuntu@<ELASTIC_IP>
```

**Solution 2: Verify correct username**
```bash
# For Ubuntu AMI, username is "ubuntu" (not "ec2-user")
ssh -i ~/.ssh/nodejs-app-key.pem ubuntu@<ELASTIC_IP>
```

**Solution 3: Check you're using correct key**
```bash
# List your keys
ls -la ~/.ssh/

# Use the key you created in AWS
ssh -i ~/.ssh/nodejs-app-key.pem ubuntu@<ELASTIC_IP>
```

---

### Problem: "Connection timed out"

**Error message:**
```
ssh: connect to host 54.123.45.67 port 22: Connection timed out
```

**Solution 1: Check Security Group**
1. Go to EC2 Console → Security Groups
2. Select `nodejs-app-sg`
3. Click **Inbound rules** tab
4. Verify SSH rule exists:
   ```
   Type: SSH
   Port: 22
   Source: Your IP (or 0.0.0.0/0 temporarily)
   ```

**Solution 2: Verify instance is running**
1. EC2 Console → Instances
2. Instance state should be **Running** (green dot)
3. Status checks: **2/2 checks passed**

**Solution 3: Check you're using Elastic IP**
```bash
# Use Elastic IP, not the dynamic public IP
# Elastic IP doesn't change when instance restarts
ssh -i ~/.ssh/nodejs-app-key.pem ubuntu@<YOUR_ELASTIC_IP>
```

---

### Problem: "Host key verification failed"

**Error message:**
```
Host key verification failed.
```

**Solution:**
```bash
# Remove old host key
ssh-keygen -R <ELASTIC_IP>

# Try connecting again
ssh -i ~/.ssh/nodejs-app-key.pem ubuntu@<ELASTIC_IP>
```

---

### Problem: "WARNING: UNPROTECTED PRIVATE KEY FILE!"

**Error message:**
```
Permissions 0644 for 'nodejs-app-key.pem' are too open.
```

**Solution:**
```bash
# Fix permissions
chmod 400 ~/.ssh/nodejs-app-key.pem

# Verify
ls -l ~/.ssh/nodejs-app-key.pem
# Should show: -r-------- (read-only by you)
```

---

## 🚀 Application Won't Start

### Problem: "Cannot find module"

**Error message:**
```
Error: Cannot find module 'express'
```

**Solution:**
```bash
# Navigate to project directory
cd ~/aws-nodejs-payment-deployment

# Install dependencies
npm install

# Try starting again
npm start


## 🔐 Dependency Security Notice (npm audit)

During dependency installation using `npm install`, npm reports a small number of **high-severity vulnerabilities**:


### 📌 Why This Happens

These vulnerabilities originate from **transitive dependencies** that are used strictly for **development purposes** (for example, tooling such as `nodemon` and related notifier packages).

They are:
- Not part of the application’s runtime logic
- Not executed in production
- Commonly flagged in Node.js development environments

---

### 🧠 Risk Assessment

| Aspect | Assessment |
|------|-----------|
Affected packages | Development-only dependencies |
Production impact | None |
Runtime exposure | No |
Exploitability | Low |
Environment | Learning / non-production |

A production-only audit confirms this assessment:

```bash
npm audit --production


```

---

### Problem: "EADDRINUSE: address already in use"

**Error message:**
```
Error: listen EADDRINUSE: address already in use :::3000
```

**Meaning:** Port 3000 is already being used by another process.

**Solution 1: Find and kill the process**
```bash
# Find what's using port 3000
sudo lsof -i :3000

# You'll see output like:
# COMMAND   PID   USER
# node      1234  ubuntu

# Kill that process (replace 1234 with actual PID)
sudo kill -9 1234

# Start your app again
npm start
```

**Solution 2: Use a different port**
```bash
# Edit .env file
nano .env

# Change PORT to something else (e.g., 3001)
PORT=3001

# Save and start
npm start

# Remember to update Security Group to allow new port!
```

---

### Problem: App starts then immediately crashes

**Check logs:**
```bash
# If using npm start directly, errors show in terminal

# If using screen, reattach and check
screen -r nodejs-app

# Common causes:
# 1. Missing environment variables
# 2. Syntax error in code
# 3. Missing dependencies
```

**Solution: Check environment variables**
```bash
# Verify .env file exists and has all required variables
cat .env

# Should have:
# DOMAIN=
# PORT=
# PUBLISHABLE_KEY=
# SECRET_KEY=
```

---

## 🌐 Can't Access from Browser

### Problem: "This site can't be reached"

**Checklist:**

**1. Is app running?**
```bash
# SSH into server
ssh -i ~/.ssh/nodejs-app-key.pem ubuntu@<ELASTIC_IP>

# Check if node is running
ps aux | grep node

# If not running, start it
cd ~/aws-nodejs-payment-deployment
npm start
```

**2. Is Security Group configured?**
```
EC2 → Security Groups → nodejs-app-sg → Inbound rules

Must have:
Type: Custom TCP
Port: 3000
Source: 0.0.0.0/0
```

**3. Are you using correct URL?**
```
Correct:   http://54.123.45.67:3000
Wrong:     https://54.123.45.67:3000  (no HTTPS!)
Wrong:     http://54.123.45.67        (missing :3000)
Wrong:     http://i-0abc123...        (that's instance ID, not IP!)
```

**4. Using Elastic IP?**
```
Use Elastic IP, not the public IP from instance details
Elastic IP is static and doesn't change
```

---

### Problem: Page loads but shows errors

**Check browser console:**
```
1. Open browser
2. Press F12 (Developer Tools)
3. Click "Console" tab
4. Look for errors (red text)
```

**Common issues:**

**API key errors:**
```javascript
// Error: Invalid API key
// Solution: Check your Stripe keys in .env
cat .env
# Make sure PUBLISHABLE_KEY and SECRET_KEY are correct
```

**CORS errors:**
```javascript
// Error: blocked by CORS policy
// Solution: Check DOMAIN in .env matches your URL
DOMAIN="http://54.123.45.67"  # Must match exactly
```

---

## 📱 AWS Console Issues

### Problem: "You are not authorized to perform this operation"

**Solution:** Check IAM permissions
```
IAM → Users → Your user → Permissions tab
Should have: AmazonEC2FullAccess
```

---

### Problem: Can't find my instance

**Possible causes:**

**1. Wrong region**
```
Check region selector (top right of AWS Console)
Make sure you're in same region where you created instance
Common regions: us-east-1, us-west-2
```

**2. Instance terminated**
```
EC2 → Instances
Filter: Show all instances (including terminated)
If terminated, you'll need to create new one
```

---

### Problem: Can't allocate Elastic IP

**Error:** "The maximum number of addresses has been reached"

**Solution:**
```
You have 5 Elastic IPs allocated already (AWS limit)

Fix:
1. EC2 → Elastic IPs
2. Find IPs not associated with instances
3. Select them → Actions → Release
4. Try allocating again
```

---

## 📦 Node.js / npm Problems

### Problem: "node: command not found"

**Solution:**
```bash
# Node.js not installed properly
# Reinstall:
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verify
node --version
npm --version
```

---

### Problem: npm install fails

**Error:** Various permission or network errors

**Solution 1: Update npm**
```bash
sudo npm install -g npm@latest
```

**Solution 2: Clear npm cache**
```bash
npm cache clean --force
npm install
```

**Solution 3: Delete node_modules and reinstall**
```bash
rm -rf node_modules
npm install
```

---

### Problem: "EACCES: permission denied"

**Solution:**
```bash
# Don't use sudo with npm install in your project
# Instead, fix npm permissions:
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Now install again (no sudo)
npm install
```

---

## 🔐 Environment Variable Issues

### Problem: "undefined" values in application

**Meaning:** Environment variables not loading

**Solution 1: Check .env file exists**
```bash
# Should be in project root
ls -la ~/aws-nodejs-payment-deployment/.env

# If missing:
cd ~/aws-nodejs-payment-deployment
cp .env.example .env
nano .env  # Add your values
```

**Solution 2: Verify dotenv is loaded**
```javascript
// At the very top of server.js:
require('dotenv').config();

// Then use variables:
const stripe = require('stripe')(process.env.SECRET_KEY);
```

**Solution 3: Check variable names match**
```bash
# In .env:
PUBLISHABLE_KEY="pk_test_..."

# In server.js, must be:
process.env.PUBLISHABLE_KEY  // (not PUBLISABLE_KEY)
```

---

## 🎯 Quick Diagnostic Commands

Run these to diagnose issues:

**Check system status:**
```bash
# Is server running?
uptime

# Available disk space?
df -h

# Available memory?
free -h

# System load?
top  # Press 'q' to exit
```

**Check application:**
```bash
# Is Node.js running?
ps aux | grep node

# Is port 3000 in use?
sudo lsof -i :3000

# Can I access locally?
curl http://localhost:3000

# Check environment variables loaded
cd ~/aws-nodejs-payment-deployment
cat .env
```

**Check AWS status:**
```bash
# From local machine:
# Can I reach the server?
ping <ELASTIC_IP>

# Can I connect to SSH port?
telnet <ELASTIC_IP> 22

# Can I connect to app port?
telnet <ELASTIC_IP> 3000
```

---

## 💡 Pro Tips

**1. Keep a log of commands you run**
```bash
# In SSH session, enable logging
script ~/deployment-log.txt
# All commands and output saved to file
# Exit logging: exit
```

**2. Test locally first**
```bash
# Before deploying to AWS, test on your laptop:
git clone https://github.com/kingchidionah/aws-nodejs-payment-deployment.git
cd aws-nodejs-payment-deployment
cp .env.example .env
nano .env  # Add test values
npm install
npm start
# Visit http://localhost:3000
```

**3. Use verbose mode for debugging**
```bash
# Get more detailed error messages
npm start --verbose
```

**4. Check AWS Service Health**
```
https://status.aws.amazon.com/
Sometimes issues are on AWS's side
```

---

## 🆘 Still Stuck?

**Before asking for help, gather this information:**

```
1. What are you trying to do?
2. What command did you run?
3. What error message do you see? (exact text)
4. What have you tried already?
5. Screenshots of error (if applicable)

Useful diagnostic info:
- Node.js version: node --version
- npm version: npm --version
- Instance type: (from EC2 console)
- AMI: Ubuntu 22.04
- Security group rules: (screenshot)
```

**Where to get help:**
- AWS Documentation: https://docs.aws.amazon.com
- Stack Overflow: Tag questions with `aws-ec2` and `node.js`
- AWS Forums: https://forums.aws.amazon.com
- GitHub Issues: Open issue in your repository

---

## ✅ Prevention Checklist

Prevent issues before they happen:

- [ ] Read instructions completely before starting
- [ ] Have all prerequisites ready (Stripe keys, etc.)
- [ ] Test locally before deploying to AWS
- [ ] Take screenshots at each step (for reference)
- [ ] Save all important information (IP addresses, commands)
- [ ] Set up billing alerts before creating resources
- [ ] Follow cleanup guide when done

---

**Most issues are simple fixes - don't give up! 💪**

Last Updated: January 2026
