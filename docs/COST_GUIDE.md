# 💰 AWS Cost Management Guide

Understanding and managing costs for your AWS EC2 Node.js deployment project.

---

## 🆓 Free Tier Overview

**AWS Free Tier Duration:** 12 months from account creation date

### What's Free (First 12 Months)

| Service | Free Tier Allowance | Usage Type |
|---------|-------------------|------------|
| **EC2 t2.micro** | 750 hours/month | Running instance |
| **EBS Storage** | 30 GB/month | General Purpose SSD |
| **Elastic IP** | Free (when attached) | Static IP address |
| **Data Transfer** | 15 GB/month outbound | Internet traffic |
| **Data Transfer** | Unlimited inbound | Internet traffic |

**Monthly Estimate for This Project:** **$0.00** ✅

### Free Tier Math

**750 hours = 31.25 days** (more than a full month!)

This means:
- ✅ One t2.micro instance running 24/7 = FREE
- ✅ Multiple instances totaling <750 hours = FREE
- ⚠️ Two t2.micro instances 24/7 = 1,500 hours = CHARGED

**For this learning project (one instance, few hours):** You'll use maybe 4-5 hours total = **$0.00**

---

## 💵 Actual Costs (After Free Tier or Outside Free Tier)

### EC2 Instance Pricing (us-east-1 region)

| Instance Type | vCPU | RAM | Price/Hour | Price/Month (24/7) |
|--------------|------|-----|------------|-------------------|
| t2.micro | 1 | 1 GB | $0.0116 | ~$8.50 |
| t2.small | 1 | 2 GB | $0.023 | ~$17.00 |
| t2.medium | 2 | 4 GB | $0.046 | ~$34.00 |

**For this project:** t2.micro = **$8.50/month** after free tier

### Storage Pricing

**EBS (gp3) General Purpose SSD:**
- $0.08 per GB/month
- 8 GB default = **$0.64/month**
- 30 GB max free tier = **$2.40/month** after

### Elastic IP Pricing

| Status | Cost |
|--------|------|
| **Attached to running instance** | **FREE** ✅ |
| **Allocated but NOT attached** | **$3.60/month** ⚠️ |
| **Multiple IPs per instance** | $3.60/month each (except first) |

**🚨 IMPORTANT:** Always release Elastic IPs you're not using!

### Data Transfer Pricing

**Outbound (from AWS to internet):**
- First 15 GB/month: FREE (free tier)
- 15 GB - 10 TB: $0.09/GB
- For typical website: ~2-5 GB/month = **$0.00** (within free tier)

**Inbound (from internet to AWS):**
- **FREE** (always, no limits)

---

## 📊 Real Cost Scenarios

### Scenario 1: Learning Project (Your Case)

**Setup:**
- 1 EC2 t2.micro instance
- Used for 4 hours to deploy and screenshot
- Elastic IP attached
- Terminated same day

**Costs:**
```
EC2 (4 hours × $0.0116):        $0.05
EBS storage (4 hours):          $0.00 (rounded down)
Elastic IP (attached 4 hours):  $0.00
Data transfer (<1 GB):          $0.00
--------------------------------
TOTAL:                          $0.05

With Free Tier:                 $0.00 ✅
```

### Scenario 2: Forgot to Terminate (1 Week)

**Setup:**
- 1 EC2 t2.micro instance
- Ran for 7 days (168 hours)
- Elastic IP attached
- Within free tier

**Costs:**
```
EC2 (168 hours):               $0.00 (free tier: 750 hours)
EBS storage:                   $0.00 (free tier: 30 GB)
Elastic IP (attached):         $0.00
Data transfer (<5 GB):         $0.00 (free tier: 15 GB)
--------------------------------
TOTAL:                         $0.00 ✅
```

**Without free tier:**
```
EC2 (168 hours × $0.0116):     $1.95
EBS (8 GB for 1 week):         ~$0.15
Total:                         $2.10
```

### Scenario 3: Forgot to Release Elastic IP

**Setup:**
- Terminated instance (good!)
- Forgot to release Elastic IP (bad!)
- 30 days unattached

**Costs:**
```
EC2:                           $0.00 (terminated)
Elastic IP (unattached):       $3.60/month ⚠️
--------------------------------
TOTAL:                         $3.60
```

**This is the #1 mistake beginners make!**

### Scenario 4: Left Running 24/7 After Free Tier

**Setup:**
- 1 EC2 t2.micro running 24/7
- After 12-month free tier expired
- Forgot about it for 3 months

**Costs per month:**
```
EC2 (730 hours × $0.0116):     $8.47
EBS (8 GB × $0.08):            $0.64
Elastic IP (attached):         $0.00
Data transfer (~5 GB):         $0.00
--------------------------------
Monthly:                       $9.11
3 Months:                      $27.33 😱
```

---

## 🔔 Setting Up Billing Alerts

**Prevent surprises - set up alerts BEFORE deploying!**

### Step 1: Enable Billing Alerts

1. Sign in to AWS Console (root or IAM with billing permissions)
2. Click your account name (top right) → **Billing and Cost Management**
3. Left sidebar → **Billing Preferences**
4. Under **Alert Preferences:**
   - ✅ Check **"Receive Billing Alerts"**
   - ✅ Check **"Receive Free Tier Usage Alerts"**
   - Enter your email address
5. Click **Save preferences**

### Step 2: Create CloudWatch Alarm

1. Go to **CloudWatch** service
2. Left sidebar → **Alarms** → **Billing**
3. Click **Create alarm**
4. **Select metric:**
   - Metric: **Total Estimated Charge**
   - Currency: USD
   - Click **Select metric**
5. **Conditions:**
   - Threshold type: **Static**
   - Whenever EstimatedCharges is: **Greater than** `1` (or your threshold)
6. **Configure actions:**
   - Alarm state trigger: **In alarm**
   - Send notification to: **Create new topic**
   - Email: Your email
   - Click **Create topic**
7. **Name alarm:** `Billing-Alert-1-Dollar`
8. Click **Create alarm**
9. **Check your email** and confirm subscription

**Recommended thresholds for learning:**
- $1.00 - First alert (something's running)
- $5.00 - Second alert (investigate immediately)
- $10.00 - Third alert (problem!)

---

## 🧹 Complete Cleanup Checklist

**Use this checklist when you're done with your project:**

### Immediate Actions (In Order!)

- [ ] **1. SSH into instance and stop any running processes**
  ```bash
  # If using screen
  screen -ls
  screen -X -S nodejs-app quit
  
  # Or just kill node
  pkill -f node
  
  # Logout
  exit
  ```

- [ ] **2. Terminate EC2 Instance**
  ```
  AWS Console → EC2 → Instances
  → Select your instance
  → Instance State → Terminate Instance
  → Type "terminate" to confirm
  ```

- [ ] **3. Release Elastic IP (CRITICAL!)**
  ```
  AWS Console → EC2 → Elastic IPs
  → Select your Elastic IP
  → Actions → Release Elastic IP address
  → Confirm release
  ```

- [ ] **4. Delete Security Group (Optional but tidy)**
  ```
  AWS Console → EC2 → Security Groups
  → Select nodejs-app-sg
  → Actions → Delete security group
  ```

- [ ] **5. Delete Key Pair (Optional)**
  ```
  AWS Console → EC2 → Key Pairs
  → Select nodejs-app-key
  → Actions → Delete
  → Also delete local file: rm ~/.ssh/nodejs-app-key.pem
  ```

### Verification (Wait 10-15 minutes, then check)

- [ ] **No running instances**
  ```
  EC2 → Instances
  Should show: "No instances"
  Or: All instances in "terminated" state
  ```

- [ ] **No Elastic IPs allocated**
  ```
  EC2 → Elastic IPs
  Should show: "No Elastic IP addresses"
  ```

- [ ] **Check Billing Dashboard**
  ```
  Account → Billing Dashboard
  Check "Month-to-Date Costs"
  Should show: $0.00 (or very small amount like $0.02)
  ```

- [ ] **Verify no active resources**
  ```
  CloudWatch → Billing
  Wait 24 hours, should show $0.00 new charges
  ```

---

## 💡 Cost Optimization Tips

### For Learning Projects

**Do:**
- ✅ Deploy and test in single session (2-4 hours)
- ✅ Take all screenshots during session
- ✅ Destroy resources same day
- ✅ Set billing alerts before deploying
- ✅ Use smallest instance type (t2.micro)

**Don't:**
- ❌ Leave instance running "just in case"
- ❌ Forget about Elastic IPs
- ❌ Use larger instance types for testing
- ❌ Deploy multiple instances for learning

### For Long-Term Projects

**If keeping instance running:**

1. **Stop instance when not in use:**
   ```
   Instance State → Stop instance
   (You still pay for EBS storage, but not compute)
   Savings: ~$8/month → ~$0.64/month
   ```

2. **Use Reserved Instances (if running 24/7):**
   ```
   1-year commitment: 40% savings ($8.50 → $5.10/month)
   3-year commitment: 60% savings ($8.50 → $3.40/month)
   ```

3. **Right-size your instance:**
   ```
   Monitor CPU/memory usage
   If always <20%, downgrade to nano/micro
   If always >80%, upgrade to small
   ```

4. **Use Elastic IP only when needed:**
   ```
   For development: Use public IP (changes on restart)
   For production: Use Elastic IP
   ```

---

## 📅 Monthly Cost Tracker

Use this to track your AWS usage:

```
Month: _______________

Resources Used:
[ ] EC2 instance type: ____________  Hours: ______
[ ] EBS storage:       ____________  GB: _________
[ ] Elastic IP:        [ ] Yes [ ] No
[ ] Data transfer:     ____________  GB: _________

Estimated Cost: $____________

Actual Bill:    $____________

Notes:
_____________________________________________________
_____________________________________________________
```

---

## ⚠️ Common Costly Mistakes

### Mistake #1: Unattached Elastic IP
**Cost:** $3.60/month  
**Fix:** Always release Elastic IPs when terminating instances

### Mistake #2: Leaving Instances Running
**Cost:** $8-10/month per instance  
**Fix:** Terminate instances when done learning

### Mistake #3: Forgetting About Stopped Instances
**Cost:** ~$0.64/month (storage only)  
**Fix:** Terminate, don't just stop (for learning projects)

### Mistake #4: Using Wrong Instance Type
**Cost:** $17-34/month for t2.small/medium  
**Fix:** Always use t2.micro for learning

### Mistake #5: No Billing Alerts
**Cost:** Unknown until too late!  
**Fix:** Set up alerts BEFORE deploying anything

---

## 🎯 Cost-Free Learning Plan

**Perfect for students/learners with zero budget:**

**Week 1:**
- Day 1: Study AWS documentation
- Day 2-3: Watch tutorials, prepare
- Day 4: Deploy in single 4-hour session
- Take all screenshots
- Destroy everything same day
- Cost: **$0.00**

**Week 2:**
- Review screenshots
- Write documentation
- Update GitHub
- No AWS usage needed
- Cost: **$0.00**

**Week 3:**
- (Optional) Deploy again to practice
- Different 4-hour session
- Destroy again
- Cost: **$0.00**

**Total learning cost:** **$0.00** ✅

---

## 📞 What If I Get Charged?

**Small charge ($0.01 - $0.50):**
- Don't panic! This is normal
- AWS rounds up tiny usage
- Not worth contacting support

**Unexpected charge ($1 - $10):**
1. Check Billing Dashboard → Cost Explorer
2. See what service charged you
3. Go terminate/delete that resource
4. Monitor for 24 hours

**Large unexpected charge ($10+):**
1. **Immediately** terminate all instances
2. Release all Elastic IPs
3. Check Cost Explorer for details
4. Contact AWS Support (they're helpful for first-time mistakes)
5. Explain: "First-time user, learning project, didn't know about X"
   - AWS often credits first-time learners for honest mistakes

**AWS Support:**
- Free tier includes: Documentation, forums
- Basic support plan: FREE
- Email support: Available in Support Center

---

## ✅ Final Cost Checklist

Before you finish this project:

- [ ] Took all screenshots needed
- [ ] Documented your learnings
- [ ] Terminated EC2 instance
- [ ] Released Elastic IP
- [ ] Deleted Security Group (optional)
- [ ] Deleted Key Pair (optional)
- [ ] Checked Billing Dashboard (shows $0.00)
- [ ] Waited 24 hours
- [ ] Checked billing again (still $0.00)
- [ ] Downloaded/saved any important logs or screenshots
- [ ] Updated GitHub with final documentation

**Expected Total Cost:** $0.00 🎉

---

**Remember:** The free tier is generous for learning. Use it wisely, clean up properly, and you'll have a great AWS learning experience without spending a cent!

Last Updated: January 2026
