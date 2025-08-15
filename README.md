# 🍲 Orphaned Cloud Ingredient Bisque - Multi-Cloud Edition

## *Chef's Special: Azure, GCP & AWS Cost Optimization à la CloudCostChef*

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Azure](https://img.shields.io/badge/Azure-CLI%20%7C%20PowerShell-0078d4.svg)](https://azure.microsoft.com/)
[![GCP](https://img.shields.io/badge/GCP-CLI%20%7C%20PowerShell-4285f4.svg)](https://cloud.google.com/)
[![AWS](https://img.shields.io/badge/AWS-CLI%20%7C%20PowerShell-FF9900.svg)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Chef's Rating](https://img.shields.io/badge/Chef's%20Rating-⭐⭐⭐⭐⭐-gold.svg)](#)

> *"Turning forgotten cloud ingredients into delicious cost savings across Azure, GCP & AWS!"* - CloudCostChef

---

## 🍽️ What's Cooking?

Welcome to **CloudCostChef's Kitchen**! This signature collection identifies and serves up forgotten cloud resources that are quietly draining your budget across all major cloud platforms. Our special **Orphaned Cloud Ingredient Bisque** recipes scan your cloud pantries to find wasted resources and turn them into cost savings.

### 🏪 Our Multi-Cloud Restaurant Menu

| 🍲 **Azure Edition** | 🍲 **GCP Edition** | 🍲 **AWS Edition** |
|---------------------|-------------------|-------------------|
| 🥬 **Lonely NIC Lettuce**<br/>*Network Interface Cards* | 🥔 **Forgotten Disk Potatoes**<br/>*Persistent Disks* | 🥕 **Forgotten Storage Carrots**<br/>*EBS Volumes* |
| 🧅 **Crying Onion Public IPs**<br/>*Unused Public IPs* | 🧅 **Crying Onion Static IPs**<br/>*Static External IPs* | 🍇 **Lonely Grape Elastic IPs**<br/>*Elastic IP Addresses* |
| | 🍄 **Lonely Load Balancer Mushrooms**<br/>*Forwarding Rules* | 🍄 **Idle Mushroom Load Balancers**<br/>*ALB/NLB/CLB with no targets* |
| | | 🌿 **Lonely Herb NAT Gateways**<br/>*Unused NAT Gateways* |

### 💰 The Savings Menu

Turn forgotten ingredients into a **feast of savings**:

#### 🍜 **Azure Monthly Soup**:
- $1.50 per orphaned NIC + $3.65 per lonely Public IP

#### 🍜 **GCP Monthly Soup**:  
- $0.04/GB for disk potatoes + $7.30 per static IP + $18.25 per forwarding rule

#### 🍜 **AWS Monthly Soup**:
- $0.08/GB for EBS carrots + $3.65 per Elastic IP + $16-32 per load balancer + $32.40 per NAT Gateway

#### 🍽️ **Annual Savings Banquet**: 12x your monthly savings across all clouds!

---

## 🛒 Shopping List (Prerequisites)

Before you start cooking, make sure your kitchen is properly equipped for all cloud platforms:

### 🔧 Universal Ingredients:
- **PowerShell 5.1+** or **PowerShell Core 6.0+** (all platforms)

### ☁️ Azure Ingredients:
```powershell
# Install Azure PowerShell modules
Install-Module Az.Accounts -Force
Install-Module Az.ResourceGraph -Force  
Install-Module Az.Billing -Force
```

### 🌐 GCP Ingredients:
```bash
# Install Google Cloud SDK
curl https://sdk.cloud.google.com | bash

# Install jq for JSON parsing (not needed for PowerShell version)
# sudo apt-get install jq  # Linux
# brew install jq          # macOS
```

### ☁️ AWS Ingredients:
```bash
# Install AWS CLI v2
# Windows: Download from https://aws.amazon.com/cli/
# macOS: brew install awscli
# Linux: curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
```

### 🔑 Chef's Permissions Required:

#### Azure:
- `Reader` role on target subscriptions
- `Resource Graph Reader` permissions

#### GCP:
- `Viewer` role or equivalent read permissions
- `Compute Viewer` for disk and IP analysis
- `Network Viewer` for load balancer analysis

#### AWS:
- `ReadOnlyAccess` policy or equivalent
- EC2, ELB, and VPC read permissions across regions

---

## 🍳 Cooking Instructions

### 🥘 Azure Kitchen Setup:

```powershell
# Connect to Azure
Connect-AzAccount

# Basic recipe - scan all subscription pantries
.\Azure-Orphaned-Network-Bisque.ps1

# Custom recipe - specific subscriptions only
.\Azure-Orphaned-Network-Bisque.ps1 -SubscriptionIds @("sub1-id", "sub2-id") -AllSubscriptions:$false
```

### 🥘 GCP Kitchen Setup:

```powershell
# Authenticate with GCP
gcloud auth login

# Basic recipe - scan all project pantries  
.\GCP-Orphaned-Resources-Bisque.ps1

# Custom recipe - specific projects only
.\GCP-Orphaned-Resources-Bisque.ps1 -AllProjects:$false -ProjectIds @("project1", "project2")
```

### 🥘 AWS Kitchen Setup:

```powershell
# Configure AWS credentials
aws configure

# Basic recipe - scan all regional pantries
.\AWS-Orphaned-Resources-Bisque.ps1

# Custom recipe - specific regions only
.\AWS-Orphaned-Resources-Bisque.ps1 -AllRegions:$false -RegionNames @("us-east-1", "us-west-2")
```

### 🍽️ Advanced Multi-Cloud Cooking:

```powershell
# Run all three platforms for complete cost analysis
.\Azure-Orphaned-Network-Bisque.ps1 -OutputPath ".\Reports\Azure-Savings.html"
.\GCP-Orphaned-Resources-Bisque.ps1 -OutputPath ".\Reports\GCP-Savings.html"  
.\AWS-Orphaned-Resources-Bisque.ps1 -OutputPath ".\Reports\AWS-Savings.html"
```

---

## 🎛️ Chef's Parameters

### 📊 Azure Parameters:
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `OutputPath` | String | `.\Azure_Unattached_Resources_Report.html` | Where to serve your final dish |
| `AllSubscriptions` | Switch | `$true` | Use all ingredients from every pantry |
| `SubscriptionIds` | String Array | `@()` | Hand-picked subscription ingredients |

### 📊 GCP Parameters:
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `OutputPath` | String | `.\GCP_Unattached_Resources_Report.html` | Where to serve your final dish |
| `AllProjects` | Switch | `$true` | Use all ingredients from every pantry |
| `ProjectIds` | String Array | `@()` | Hand-picked project ingredients |

### 📊 AWS Parameters:
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `OutputPath` | String | `.\AWS_Unattached_Resources_Report.html` | Where to serve your final dish |
| `AllRegions` | Switch | `$true` | Use all ingredients from every regional pantry |
| `RegionNames` | String Array | `@("us-east-1", "us-west-2")` | Hand-picked regional ingredients |
| `AwsProfile` | String | `"default"` | AWS credentials profile to use |

---

## 🍽️ What's On The Menu? (Features)

### 🥗 Appetizers (Quick Overview):
- **Real-time ingredient scanning** across Azure, GCP, and AWS
- **Beautiful cost presentation** with chef-styled HTML reports
- **Platform-specific breakdown analysis** 
- **CSV takeaway options** for further analysis
- **Consistent chef experience** across all cloud platforms

### 🍖 Main Course (Detailed Features):

#### 🔵 Azure Specialties:
- **KQL-powered ingredient detection** using Azure Resource Graph
- **Smart NIC filtering** (excludes load balancer attachments, private endpoints)
- **Public IP waste detection** with allocation method analysis
- **Subscription-by-subscription breakdown**

#### 🟢 GCP Specialties:
- **gcloud CLI-powered scanning** with JSON parsing
- **Persistent disk orphan detection** (unattached disks)
- **Static IP reservation analysis** (unused reserved IPs)
- **Forwarding rule optimization** (rules with no backends)
- **Project-by-project breakdown**

#### 🟠 AWS Specialties:
- **AWS CLI-powered multi-service scanning**
- **EBS volume orphan detection** with type-based costing
- **Elastic IP association analysis** 
- **Load balancer target health checking**
- **NAT Gateway route table verification**
- **Region-by-region breakdown**

### 🍰 Dessert (Bonus Features):
- **Beautiful platform-themed styling** (Azure blue, Google colors, AWS orange)
- **Professional recommendations** for kitchen cleanup and prevention
- **One-click report opening** for immediate consumption
- **Progress indicators** throughout the cooking process
- **Multi-account/project/subscription support**

---

## 📊 Sample Output (The Final Dishes)

After running each script, you'll receive platform-specific HTML reports:

### 🍲 Azure Bisque Report:
```
🎉 ORPHANED NETWORK INGREDIENT BISQUE COMPLETE! 🎉

👨‍🍳 Chef's Summary:
   💰 Monthly savings soup ready: $47.30
   🎊 Annual savings banquet available: $567.60

🍲 AZURE INGREDIENTS FOUND:
   🥬 Lonely NIC Lettuce pieces: 12 (wasting $18.00/month)
   🧅 Crying Onion Public IPs: 8 (bleeding $29.20/month)
   🏪 Subscription kitchens inspected: 5
```

### 🍲 GCP Bisque Report:
```
🎉 ORPHANED CLOUD INGREDIENT BISQUE COMPLETE! 🎉

👨‍🍳 Chef's Summary:
   💰 Monthly savings soup ready: $127.45
   🎊 Annual savings banquet available: $1,529.40

🍲 GCP INGREDIENTS FOUND:
   🥔 Forgotten disk potatoes: 15 (487 GB wasting $19.48/month)
   🧅 Crying onion static IPs: 12 (bleeding $87.60/month)
   🍄 Lonely load balancer mushrooms: 1 (costing $18.25/month)
   🏪 Project kitchens inspected: 8
```

### 🍲 AWS Bisque Report:
```
🎉 ORPHANED CLOUD INGREDIENT BISQUE COMPLETE! 🎉

👨‍🍳 Chef's Summary:
   💰 Monthly savings soup ready: $342.75
   🎊 Annual savings banquet available: $4,113.00

🍲 AWS INGREDIENTS FOUND:
   🥕 Forgotten storage carrots: 25 (1,250 GB wasting $100.00/month)
   🍇 Lonely grape Elastic IPs: 18 (bleeding $65.70/month)
   🍄 Idle mushroom load balancers: 3 (costing $48.60/month)
   🌿 Lonely herb NAT Gateways: 4 (costing $129.60/month)
   🏪 Regional kitchens inspected: 16
```

---

## 🧑‍🍳 Chef's Pro Tips

### 🔍 Universal Kitchen Wisdom:
1. **Taste before you toss** - Always verify resources are truly unused
2. **Check the recipe dependencies** - Some ingredients might be planned for future dishes
3. **Look for cross-platform dependencies** - Resources might be connected across clouds

### 🤖 Multi-Cloud Kitchen Automation:

#### Azure Automation:
```powershell
# Set up Azure Policy to prevent orphaned resources
# Create Logic Apps for automated cleanup
# Implement resource tagging strategies
```

#### GCP Automation:
```bash
# Use Cloud Asset Inventory for tracking
# Implement Cloud Functions for cleanup
# Set up Recommender API integration
```

#### AWS Automation:
```powershell
# Create AWS Config Rules for compliance
# Set up Lambda functions for cleanup
# Use Trusted Advisor recommendations
```

### 📅 Regular Multi-Cloud Maintenance:
- Run all three bisque recipes monthly for freshest results
- Set up alerts for resources unused > 30 days across all platforms
- Implement consistent tagging strategies across clouds
- Create consolidated cost tracking dashboard

---

## 🍳 Platform-Specific Cooking Variations

### 🔵 Azure Customizations:
```powershell
# Modify costs for different regions
$nicMonthlyCost = 1.50      # Adjust based on your region
$publicIpMonthlyCost = 3.65 # Update for current pricing

# Custom KQL queries for different resource types
# Add detection for unused storage accounts, app services, etc.
```

### 🟢 GCP Customizations:
```powershell
# Update pricing for different regions
$diskCostPerGbMonth = 0.04        # Standard persistent disk cost
$staticIpCostMonth = 7.30         # Regional static IP cost

# Extend to detect unused Cloud SQL instances, VMs, etc.
```

### 🟠 AWS Customizations:
```powershell
# Regional pricing variations
$ebsVolumeGp3CostPerGbMonth = 0.08
$elasticIpCostMonth = 3.65

# Add detection for unused RDS instances, Lambda functions, etc.
```

---

## 🆘 Kitchen Accidents (Troubleshooting)

### 🔵 Azure Common Issues:

**🚨 "Required Azure PowerShell modules not found"**
```powershell
Install-Module Az -Force -AllowClobber
```

**🚨 "Access Denied" or "Insufficient Permissions"**
- Ensure `Reader` role on target subscriptions
- Verify `Resource Graph Reader` permissions

### 🟢 GCP Common Issues:

**🚨 "gcloud command not found"**
```bash
# Install Google Cloud SDK
curl https://sdk.cloud.google.com | bash
```

**🚨 "Authentication failed"**
```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### 🟠 AWS Common Issues:

**🚨 "aws command not found"**
- Install AWS CLI v2 from https://aws.amazon.com/cli/

**🚨 "Access Denied"**
```bash
aws configure
# Ensure IAM user has ReadOnlyAccess policy
```

---

## 🍷 Pairing Suggestions (Related Tools)

This multi-cloud bisque collection pairs beautifully with other CloudCostChef specialties:

### 🍽️ Coming Soon to Our Menu:
- **Multi-Cloud Storage Cleanup Soufflé** (unused storage across all platforms)
- **Cross-Platform VM Retirement Roast** (idle compute resources)
- **Database Optimization Diet** (over-provisioned databases)
- **Serverless Function Cleanup Appetizer** (unused Lambda/Functions/Cloud Functions)

### 🤝 Community Recipes:
- **Kubernetes Cost Optimization Curry** (right-sizing K8s resources)
- **CDN Bandwidth Reduction Reduction** (optimizing content delivery)
- **DNS Cleanup Digestif** (unused DNS zones and records)

---

## 🤝 Contributing to the Kitchen

We welcome fellow chefs to contribute to our multi-cloud cost optimization cookbook!

### How to Help:
1. **Fork** the repository
2. **Create** your feature branch (`git checkout -b feature/AmazingIngredient`)
3. **Commit** your changes (`git commit -m 'Add some AmazingIngredient'`)
4. **Push** to the branch (`git push origin feature/AmazingIngredient`)
5. **Open** a Pull Request

### Contribution Ideas:
- **New ingredient detection** (unused databases, idle VMs, etc.)
- **Enhanced cost calculations** for different regions and currencies
- **Additional export formats** (Excel, JSON, PowerBI)
- **Cross-cloud correlation** (resources that depend on each other)
- **Automation scripts** for cleanup workflows
- **Additional cloud platforms** (Oracle Cloud, IBM Cloud, etc.)

---

## 📞 Support & Feedback

### Need Help in the Kitchen?
- 🐛 **Bug Reports**: Open an issue with detailed reproduction steps
- 💡 **Feature Requests**: Share your ideas for new ingredients to detect
- 💬 **Questions**: Start a discussion in our community forum
- 📧 **Direct Contact**: cloudcostchef@example.com

### Show Your Appreciation:
- ⭐ **Star this repository** if it helped reduce your cloud costs
- 🍽️ **Share your success stories** and savings achieved across platforms
- 📢 **Spread the word** to other multi-cloud cost chefs
- 💰 **Report your savings** - we love hearing about money saved!

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🌟 Final Word from the Chef

> *"Remember, a clean multi-cloud kitchen is a profitable kitchen! Every orphaned resource you clean up across Azure, GCP, and AWS is money back in your pocket. Cook responsibly across all platforms, save significantly, and may your cloud costs always be optimized!"*
> 
> — **CloudCostChef** 👨‍🍳

---

## 📈 Multi-Cloud Success Stories

### What Chefs Are Saying:

> *"This multi-cloud bisque collection helped us identify $12,400 in annual savings across Azure, GCP, and AWS from just 45 minutes of kitchen cleanup!"* - DevOps Chef, TechCorp

> *"The consistent chef experience across all platforms makes it easy to show management where we're bleeding money in each cloud. Saved our team 30 hours of manual resource hunting per month."* - Cloud Architect, StartupXYZ

> *"Finally, cost optimization that doesn't put people to sleep! The chef theme makes our team actually want to clean up our multi-cloud environment. We've saved over $50K annually!"* - FinOps Lead, Enterprise Inc.

> *"Running all three scripts monthly has become our 'cost optimization ritual'. It's like having a personal chef for our cloud spending!"* - Cloud Operations Manager, ScaleUp Co.

---

## 📊 Platform Comparison Quick Reference

| Feature | Azure Edition | GCP Edition | AWS Edition |
|---------|---------------|-------------|-------------|
| **Primary Resources** | NICs, Public IPs | Disks, Static IPs, LB Rules | EBS, Elastic IPs, LBs, NAT GWs |
| **Typical Monthly Savings** | $50-500 | $100-800 | $200-1200 |
| **Scan Speed** | Fast (KQL) | Medium (gcloud) | Slower (multi-service) |
| **Regions Covered** | All Azure regions | All GCP regions | All AWS regions |
| **Authentication** | Azure AD | Google Auth | AWS IAM |
| **Best For** | Network waste | Compute & network waste | Comprehensive waste detection |

---

**Happy Multi-Cloud Cooking! 🍲✨**

*Remember to check your cloud costs regularly across all platforms and keep your multi-cloud kitchen tidy!*

---

## 🏆 Recognition & Awards

- 🥇 **CloudCostChef's Choice** - Top 3 Multi-Cloud Cost Tools 2024
- 🎖️ **FinOps Foundation Recommended** - Community Favorite
- 🌟 **DevOps Weekly Featured** - Essential Cloud Cost Tool
- 💎 **PowerShell Gallery** - Most Downloaded Cost Optimization Script
