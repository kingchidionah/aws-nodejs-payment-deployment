# 📖 Simple Deployment Guide

This guide walks you through deploying your Node.js application on AWS EC2 using the **simple approach** - perfect for learning and taking portfolio screenshots.

**Time:** 45-60 minutes  
**Cost:** $0.00 (free tier)  
**Difficulty:** Beginner-friendly ⭐⭐

---

## 📋 Prerequisites Checklist

Before starting, make sure you have:

- [ ] AWS account created and verified
- [ ] Credit card added to AWS (required even for free tier)
- [ ] Stripe account created ([stripe.com](https://stripe.com))
- [ ] SSH client available (Terminal on Mac/Linux, PuTTY on Windows)
- [ ] Text editor for editing files (VS Code, Sublime, nano)
- [ ] 1 hour of uninterrupted time

---

## Phase 1: AWS Account Setup

### Step 1: Create IAM User

**Why?** Never use root AWS account for everyday tasks (security best practice)

> 📸 **Screenshot 1:** IAM user creation page

1. **Sign in to AWS Console:** https://console.aws.amazon.com
2. Search for **IAM** in the top search bar
3. Click **Users** (left sidebar) → **Create user**
4. **User details:**
   - User name: `ec2-deploy-user` (or your preferred name)
   - ✅ Check **"Provide user access to the AWS Management Console"**
   - Select **"I want to create an IAM user"**
   - Custom password: Create a strong password
   - ⬜ Uncheck "Users must create a new password" (optional)

5. Click **Next**

> 📸 **Screenshot 2:** Permissions page

6. **Set permissions:**
   - Select **"Attach policies directly"**
   - In search box, type: `EC2`
   - ✅ Check **AmazonEC2FullAccess**

7. Click **Next** → **Create user**

8. **Important:** 
   - Copy the **Console sign-in URL**
   - Save your username and password securely
   - Sign out from root account
   - Sign in with your new IAM user

**✅ Verification:** You should see your IAM username in top-right corner (not "root")

---

### Step 2: Create SSH Key Pair

**Why?** This is how you'll securely connect to your server (like a password, but more secure)

> 📸 **Screenshot 3:** Key pair creation

1. In AWS Console, go to **EC2** (search in top bar)
2. In left sidebar, scroll to **Network & Security** → **Key Pairs**
3. Click **Create key pair** (orange button, top right)
4. **Configure key pair:**
   - Name: `nodejs-app-key`
   - Key pair type: **RSA**
   - Private key file format: 
     - **.pem** (if using Mac/Linux)
     - **.ppk** (if using Windows with PuTTY)

5. Click **Create key pair**
6. **File downloads automatically** - This is your ONLY copy!

**⚠️ CRITICAL - Secure Your Key:**

**On Mac/Linux:**
```bash
# Move key to safe location
mv ~/Downloads/nodejs-app-key.pem ~/.ssh/

# Set correct permissions (required for SSH to work)
chmod 400 ~/.ssh/nodejs-app-key.pem

# Verify
ls -l ~/.ssh/nodejs-app-key.pem
# Should show: -r-------- (read-only by you)
```

**On Windows:**
```bash
# Move to a secure folder (e.g., C:\Users\YourName\.ssh\)
# PuTTY will use this file directly
```

**🚨 NEVER:**
- Share this file with anyone
- Commit it to Git
- Upload to cloud storage
- Email it
- If lost, you can't recover it (you'll need to create a new one)

---

### Step 3: Launch EC2 Instance

**Why?** This is your virtual server where your app will run

> 📸 **Screenshot 4:** Launch instance page

1. Go to **EC2 Dashboard** → Click **Launch Instance** (orange button)

2. **Name and tags:**
   - Name: `nodejs-payment-app`

3. **Application and OS Images (AMI):**
   - Quick Start: Select **Ubuntu**
   - AMI: **Ubuntu Server 22.04 LTS (HVM), SSD Volume Type**
   - Architecture: **64-bit (x86)**
   - ✅ Free tier eligible (should show green label)

> 📸 **Screenshot 5:** Instance type selection

4. **Instance type:**
   - Select **t2.micro** (should be pre-selected)
   - ✅ Free tier eligible
   - Specs: 1 vCPU, 1 GiB Memory

5. **Key pair:**
   - Select your key: **nodejs-app-key**
   - If you don't see it, you skipped Step 2 - go back!

> 📸 **Screenshot 6:** Network settings / Security group

6. **Network settings:**
   - Click **Edit** (top right of Network settings box)
   - Firewall (security groups): **Create security group**
   - Security group name: `nodejs-app-sg`
   - Description: `Security group for Node.js application`

7. **Inbound security group rules:**

   **Rule 1 - SSH (should already exist):**
   - Type: **SSH**
   - Protocol: TCP
   - Port: 22
   - Source: **My IP** (your current IP - recommended)
   - Description: `SSH access from my location`

   **Rule 2 - HTTP:**
   - Click **Add security group rule**
   - Type: **HTTP**
   - Protocol: TCP
   - Port: 80
   - Source: **Anywhere (0.0.0.0/0)**
   - Description: `HTTP web traffic`

   **Rule 3 - Custom TCP (for Node.js):**
   - Click **Add security group rule**
   - Type: **Custom TCP**
   - Protocol: TCP
   - Port: **3000**
   - Source: **Anywhere (0.0.0.0/0)**
   - Description: `Node.js application`

8. **Configure storage:**
   - Keep default: **8 GiB gp3** (free tier allows up to 30 GB)

9. **Advanced details:** (expand if you want to see options)
   - Keep all defaults for now
   - (This is where you'd paste user-data scripts for automation, but we're doing manual setup)

10. **Summary:**
    - Review on right side panel
    - Should show **Free tier eligible**
    - Number of instances: **1**

11. Click **Launch instance** (orange button)

> 📸 **Screenshot 7:** Launch success page

12. **Success!** You should see:
    - "Successfully initiated launch of instance i-xxxxxxxxx"
    - Click **View all instances**

**✅ Verification:**
- Instance state: Should be **Pending** → **Running** (takes 1-2 minutes)
- Status checks: Wait for **2/2 checks passed** (takes 3-5 minutes)

> 📸 **Screenshot 8:** Instance running with status checks passed

---

### Step 4: Allocate Elastic IP

**Why?** Without this, your server's IP address changes every time you stop/start it (very annoying!)

> 📸 **Screenshot 9:** Elastic IP allocation

1. In EC2 Dashboard left sidebar, scroll to **Network & Security** → **Elastic IPs**
2. Click **Allocate Elastic IP address** (orange button)
3. Settings:
   - Network Border Group: Keep default (your region)
   - Public IPv4 address pool: **Amazon's pool of IPv4 addresses**
4. Click **Allocate**

5. **Success!** You now have a static IP address

> 📸 **Screenshot 10:** Elastic IP association

6. **Associate with your instance:**
   - Select your new Elastic IP (checkbox)
   - Click **Actions** → **Associate Elastic IP address**
   - Resource type: **Instance**
   - Instance: Select **nodejs-payment-app** (should be only option)
   - Private IP: Leave as-is (auto-selected)
   - Click **Associate**

**✅ Verification:**
- Your Elastic IP should now show **Associated instance ID**
- Copy this Elastic IP address somewhere safe (you'll use it a lot!)

**💡 Important Notes:**
- ✅ **FREE** while attached to a running instance
- ⚠️ **$3.60/month** if NOT attached to a running instance
- 🚨 **Always release Elastic IP when you terminate instance!**

---

## Phase 2: Server Connection & Setup

### Step 5: Connect via SSH

**Why?** You need to access your server's command line to install software and deploy your app

> 📸 **Screenshot 11:** SSH connection

**On Mac/Linux:**

```bash
# Replace <ELASTIC_IP> with your actual Elastic IP
ssh -i ~/.ssh/nodejs-app-key.pem ubuntu@<ELASTIC_IP>

# Example:
# ssh -i ~/.ssh/nodejs-app-key.pem ubuntu@54.123.45.67
```

**First time connecting:**
```
The authenticity of host '54.123.45.67 (54.123.45.67)' can't be established.
ECDSA key fingerprint is SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```
Type `yes` and press Enter

**On Windows (using PuTTY):**
1. Open PuTTY
2. Host Name: `ubuntu@<ELASTIC_IP>`
3. Port: 22
4. Connection → SSH → Auth → Browse → Select your `.ppk` file
5. Click **Open**

**✅ Success looks like:**
```
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 6.2.0-1009-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

ubuntu@ip-172-31-xx-xx:~$
```

> 📸 **Screenshot 12:** Successful login showing Ubuntu welcome message

**❌ If connection fails:**

**Error: "Permission denied (publickey)"**
```bash
# Fix: Check key permissions
chmod 400 ~/.ssh/nodejs-app-key.pem

# Try again
ssh -i ~/.ssh/nodejs-app-key.pem ubuntu@<ELASTIC_IP>
```

**Error: "Connection timed out"**
- Check Security Group has SSH (port 22) allowed from your IP
- Verify instance is **running** (not stopped)
- Verify you're using correct Elastic IP

---

### Step 6: Update System & Install Node.js

Now you're connected to your Ubuntu server. Let's install everything needed.

**Update system packages:**

```bash
# Update package list
sudo apt update

# Upgrade installed packages (this may take 5-10 minutes)
sudo apt upgrade -y
```

> 📸 **Screenshot 13:** System update in progress

**Install Node.js 18.x LTS:**

```bash
# Add NodeSource repository for Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -

# Install Node.js (includes npm)
sudo apt install -y nodejs

# Verify installation
node --version
npm --version
```

> �� **Screenshot 14:** Node.js and npm versions

**Expected output:**
```
v18.19.0  (or similar 18.x version)
10.2.3    (or similar version)
```

**Install Git:**

```bash
sudo apt install -y git

# Verify
git --version
```

**Expected output:**
```
git version 2.34.1 (or similar)
```

**✅ Checkpoint:** You now have a Ubuntu server with Node.js and Git installed!

---

## Phase 3: Deploy Application

### Step 7: Clone Repository

```bash
# Make sure you're in home directory
cd ~

# Clone your repository (replace with your GitHub username)
git clone https://github.com/kingchidionah/aws-nodejs-payment-deployment.git

# Navigate into project
cd aws-nodejs-payment-deployment

# Verify files are there
ls -la
```

> 📸 **Screenshot 15:** Repository cloned, showing file listing

**Expected output:**
```
-rw-rw-r--  1 ubuntu ubuntu  xxxx Jan xx xx:xx .env.example
-rw-rw-r--  1 ubuntu ubuntu  xxxx Jan xx xx:xx .gitignore
-rw-rw-r--  1 ubuntu ubuntu  xxxx Jan xx xx:xx README.md
drwxrwxr-x  2 ubuntu ubuntu  4096 Jan xx xx:xx client
-rw-rw-r--  1 ubuntu ubuntu  xxxx Jan xx xx:xx package.json
-rw-rw-r--  1 ubuntu ubuntu  xxxx Jan xx xx:xx server.js
```

---

### Step 8: Configure Environment Variables

**Create .env file from template:**

```bash
# Copy example file
cp .env.example .env

# Edit with nano text editor
nano .env
```

**In nano editor, fill in these values:**

```bash
DOMAIN="http://<YOUR_ELASTIC_IP>"
PORT=3000
STATIC_DIR="./client"

PUBLISHABLE_KEY="pk_test_your_stripe_publishable_key_here"
SECRET_KEY="sk_test_your_stripe_secret_key_here"
```

> 📸 **Screenshot 16:** .env file configured (BLUR/HIDE actual Stripe keys!)

**Get Stripe API keys:**
1. Go to [https://dashboard.stripe.com](https://dashboard.stripe.com)
2. Create account / Sign in
3. Click **Developers** (top right)
4. Click **API keys**
5. Under **Standard keys**:
   - Copy **Publishable key** (starts with `pk_test_`)
   - Copy **Secret key** (click "Reveal" first, starts with `sk_test_`)

**Paste these into your .env file**

**Save and exit nano:**
- Press `Ctrl + O` (save)
- Press `Enter` (confirm filename)
- Press `Ctrl + X` (exit)

**Verify .env file:**
```bash
cat .env
```
You should see your configuration (keys will be visible - that's ok, only you see this)

---

### Step 9: Install Dependencies & Start Application

```bash
# Install all npm packages (this takes 1-2 minutes)
npm install
```

> 📸 **Screenshot 17:** npm install in progress/completed

**Start the application:**

```bash
# Simple start (foreground)
npm start
```

**Expected output:**
```
> aws-session@1.0.0 start
> node server.js

Server is listening on port 3000
```

> 📸 **Screenshot 18:** Application started successfully

**🎉 Your app is running!**

**Test locally on server:**
```bash
# Open a NEW terminal window (keep the first one running)
# SSH into your server again
ssh -i ~/.ssh/nodejs-app-key.pem ubuntu@<ELASTIC_IP>

# Test with curl
curl http://localhost:3000

# You should see HTML output
```

---

### Step 10: Access from Browser

**Open your web browser and visit:**

```
http://<YOUR_ELASTIC_IP>:3000
```

Example: `http://54.123.45.67:3000`

> 📸 **Screenshot 19:** Application running in browser (full page)

**✅ Success!** You should see your payment application interface!

**❌ If page doesn't load:**

1. **Check Security Group:**
   - EC2 Dashboard → Security Groups → `nodejs-app-sg`
   - Inbound rules should have port 3000 open to 0.0.0.0/0

2. **Check app is running:**
   - In your SSH terminal, you should see `npm start` still running
   - If it stopped, run `npm start` again

3. **Check correct URL:**
   - Must use `http://` not `https://`
   - Must include `:3000` at the end
   - Use Elastic IP, not instance ID

---

### Step 11: Keep App Running After Logout

**Problem:** When you close your terminal, `npm start` stops and your app goes down.

**Solution:** Use `screen` to keep the process running in background.

**Install screen:**
```bash
# Press Ctrl+C to stop npm start
sudo apt install screen
```

**Start app with screen:**
```bash
# Create new screen session named "nodejs-app"
screen -S nodejs-app

# Inside screen, start your app
cd ~/aws-nodejs-payment-deployment
npm start

# Detach from screen (keeps app running):
# Press Ctrl+A, then press D
```

**You'll see:**
```
[detached from xxxx.nodejs-app]
```

**Now you can safely logout:**
```bash
exit
```

**Your app keeps running!**

**To reconnect later:**
```bash
# SSH back into server
ssh -i ~/.ssh/nodejs-app-key.pem ubuntu@<ELASTIC_IP>

# Reattach to your screen session
screen -r nodejs-app

# You'll see your app still running
# To detach again: Ctrl+A then D
```

**Useful screen commands:**
```bash
screen -ls               # List all screen sessions
screen -r nodejs-app     # Reattach to nodejs-app session
screen -X -S nodejs-app quit  # Kill the nodejs-app session
```

---

## 🎉 Deployment Complete!

**What you've accomplished:**

- ✅ Created AWS IAM user
- ✅ Launched EC2 instance
- ✅ Configured Security Group
- ✅ Allocated Elastic IP
- ✅ Connected via SSH
- ✅ Installed Node.js and Git
- ✅ Deployed your application
- ✅ Configured environment variables
- ✅ Application accessible from internet
- ✅ Learned to keep app running with screen

**Your app is now live at:** `http://<YOUR_ELASTIC_IP>:3000`

---

## 📸 Screenshot Checklist

Make sure you captured:

- [ ] IAM user creation
- [ ] Key pair creation
- [ ] EC2 instance launch configuration
- [ ] Security group rules
- [ ] Instance running (status checks passed)
- [ ] Elastic IP association
- [ ] SSH connection successful
- [ ] Node.js version check
- [ ] Repository cloned
- [ ] npm install completed
- [ ] Application started (npm start output)
- [ ] Application in browser (working)

---

## 🧹 Cleanup (When You're Done)

**⚠️ IMPORTANT:** To avoid charges, clean up when you're finished!

**[See Complete Cleanup Guide →](COST_GUIDE.md)**

**Quick cleanup:**

1. **In SSH terminal:**
```bash
# Kill screen session
screen -X -S nodejs-app quit

# Logout
exit
```

2. **In AWS Console:**
   - EC2 → Instances → Select instance → **Instance State** → **Terminate instance**
   - EC2 → Elastic IPs → Select IP → **Actions** → **Release Elastic IP address**

3. **Verify:**
   - Wait 10 minutes
   - Check **Billing Dashboard** to confirm no running resources

---

## ❓ Troubleshooting

**[See Full Troubleshooting Guide →](TROUBLESHOOTING.md)**

**Quick fixes:**

**Can't SSH connect:**
```bash
chmod 400 ~/.ssh/nodejs-app-key.pem
ssh -i ~/.ssh/nodejs-app-key.pem ubuntu@<ELASTIC_IP>
```

**App not accessible from browser:**
- Check Security Group has port 3000 open
- Verify app is running: `ps aux | grep node`
- Check URL: `http://` not `https://`, include `:3000`

**Port 3000 already in use:**
```bash
# Find process using port 3000
sudo lsof -i :3000

# Kill it
sudo kill -9 <PID>

# Restart your app
npm start
```

---

## 🎓 Next Steps

**After mastering this simple deployment:**

1. **Try the production approach:**
   - [Production Deployment Guide](PRODUCTION_DEPLOYMENT.md)
   - Learn PM2, NGINX, and automation

2. **Add features:**
   - Set up HTTPS with SSL certificate
   - Add a custom domain name
   - Implement database (RDS)

3. **Learn more AWS:**
   - S3 for file storage
   - CloudFront for CDN
   - Route 53 for DNS

---

**Congratulations on deploying to AWS! ��**
