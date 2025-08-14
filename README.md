# 🍲 Orphaned Network Ingredient Bisque

## *Chef's Special: Azure Cost Optimization à la CloudCostChef*

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Azure](https://img.shields.io/badge/Azure-CLI%20%7C%20PowerShell-0078d4.svg)](https://azure.microsoft.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Chef's Rating](https://img.shields.io/badge/Chef's%20Rating-⭐⭐⭐⭐⭐-gold.svg)](#)

> *"Turning forgotten Azure ingredients into delicious cost savings!"* - CloudCostChef

---

## 🍽️ What's Cooking?

Welcome to **CloudCostChef's Kitchen**! This signature dish identifies and serves up forgotten Azure network resources that are quietly draining your budget. Our special **Orphaned Network Ingredient Bisque** scans your Azure subscription pantries to find:

- 🥬 **Lonely NIC Lettuce** - Network Interface Cards sitting unused and wilting away
- 🧅 **Crying Onion Public IPs** - Public IP addresses that make your wallet weep with tears of wasted money

### 💰 The Savings Menu

Turn forgotten ingredients into a **feast of savings**:
- 🍜 **Monthly Savings Soup**: $1.50 per orphaned NIC + $3.65 per lonely Public IP
- 🍽️ **Annual Savings Banquet**: 12x your monthly savings
- 📊 **Detailed Cost Breakdown**: Per subscription kitchen analysis

---

## 🛒 Shopping List (Prerequisites)

Before you start cooking, make sure your kitchen is properly equipped:

### Required Ingredients:
- **PowerShell 5.1+** or **PowerShell Core 6.0+**
- **Azure PowerShell Modules**:
  ```powershell
  Install-Module Az.Accounts -Force
  Install-Module Az.ResourceGraph -Force  
  Install-Module Az.Billing -Force
  ```
- **Azure Account** with appropriate permissions to read resources

### Chef's Permissions Required:
- `Reader` role on target subscriptions
- `Resource Graph Reader` permissions (for KQL queries)
- Access to `Microsoft.ResourceGraph/resources/read`

---

## 🍳 Cooking Instructions

### Quick Start Recipe:

1. **Prep Your Kitchen** (Install dependencies):
   ```powershell
   # Install the Azure PowerShell ingredients
   Install-Module Az -Force -AllowClobber
   ```

2. **Heat Up Your Session** (Connect to Azure):
   ```powershell
   Connect-AzAccount
   ```

3. **Start Cooking** (Run the script):
   ```powershell
   # Basic recipe - scan all subscription pantries
   .\OrphanedNetworkIngredientBisque.ps1
   
   # Custom recipe - specific pantries only
   .\OrphanedNetworkIngredientBisque.ps1 -SubscriptionIds @("sub1-id", "sub2-id") -AllSubscriptions:$false
   
   # Takeaway version - custom output location
   .\OrphanedNetworkIngredientBisque.ps1 -OutputPath "C:\MyKitchen\CostSavingsMenu.html"
   ```

### Advanced Cooking Techniques:

```powershell
# Scan specific subscription kitchens
.\OrphanedNetworkIngredientBisque.ps1 `
    -SubscriptionIds @("12345678-1234-1234-1234-123456789012", "87654321-4321-4321-4321-210987654321") `
    -AllSubscriptions:$false `
    -OutputPath ".\MyCustomBisque.html"

# Quick scan of all kitchens with default serving
.\OrphanedNetworkIngredientBisque.ps1 -AllSubscriptions
```

---

## 🎛️ Chef's Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `OutputPath` | String | `.\Azure_Unattached_Resources_Report.html` | Where to serve your final dish |
| `AllSubscriptions` | Switch | `$true` | Use all ingredients from every pantry |
| `SubscriptionIds` | String Array | `@()` | Hand-picked subscription ingredients |

---

## 🍽️ What's On The Menu? (Features)

### 🥗 Appetizers (Quick Overview):
- **Real-time ingredient scanning** across all your Azure kitchens
- **Beautiful cost presentation** with chef-styled HTML reports
- **Pantry breakdown analysis** showing waste per subscription
- **CSV takeaway options** for further analysis

### 🍖 Main Course (Detailed Features):
- **KQL-powered ingredient detection** using Azure Resource Graph
- **Smart filtering** to avoid false positives (excludes load balancer attachments, etc.)
- **Cost calculation engine** with current Azure pricing
- **Interactive HTML reports** with downloadable CSV exports
- **Subscription-by-subscription breakdown** of wasted resources

### 🍰 Dessert (Bonus Features):
- **Beautiful chef-themed styling** that makes cost optimization delightful
- **Professional recommendations** for kitchen cleanup and prevention
- **One-click report opening** for immediate consumption
- **Progress indicators** throughout the cooking process

---

## 📊 Sample Output (The Final Dish)

After running the script, you'll receive:

### 🍲 HTML Bisque Report Including:
- **Executive Summary Cards** showing total waste and savings
- **Detailed Ingredient Tables** with full resource information
- **Kitchen Breakdown** (per subscription analysis)
- **Chef's Professional Recommendations** for cleanup
- **CSV Export Buttons** for spreadsheet analysis

### 💰 Cost Savings Preview:
```
🎉 ORPHANED NETWORK INGREDIENT BISQUE COMPLETE! 🎉

👨‍🍳 Chef's Summary:
   🍽️  Bisque successfully prepared and plated!
   💰 Monthly savings soup ready: $47.30
   🎊 Annual savings banquet available: $567.60

🍲 BISQUE INGREDIENTS FOUND:
   🥬 Lonely NIC Lettuce pieces: 12 (wasting $18.00/month)
   🧅 Crying Onion Public IPs: 8 (bleeding $29.20/month)
   📊 Total forgotten ingredients: 20
   🏪 Subscription kitchens inspected: 5
```

---

## 🧑‍🍳 Chef's Pro Tips

### 🔍 Before You Clean Your Kitchen:
1. **Taste before you toss** - Verify resources are truly unused
2. **Check the recipe book** - Some ingredients might be planned for future dishes
3. **Look for dependencies** - Some resources might be connected in ways not obvious

### 🤖 Kitchen Automation:
```powershell
# Set up automated monthly kitchen cleaning reminders
# Create Azure Policy to prevent orphaned resources
# Implement resource tagging for better tracking
```

### 📅 Regular Maintenance:
- Run this bisque recipe monthly for freshest results
- Set up alerts for resources unused > 30 days
- Implement consistent tagging strategies

---

## 🍳 Cooking Variations (Customization)

### Modify Ingredient Costs:
```powershell
# Update the cost variables in the script
$nicMonthlyCost = 1.50      # Adjust based on your region
$publicIpMonthlyCost = 3.65 # Update for current pricing
```

### Custom KQL Recipes:
The script uses two main "secret recipes" (KQL queries). You can customize these for different ingredients:

- **Lonely NIC Lettuce Detection**: Finds unattached Network Interface Cards
- **Crying Onion Public IP Discovery**: Locates unused Public IP addresses

---

## 🆘 Kitchen Accidents (Troubleshooting)

### Common Cooking Mishaps:

**🚨 "Required Azure PowerShell modules not found"**
```powershell
# Solution: Install the missing ingredients
Install-Module Az -Force -AllowClobber
```

**🚨 "Access Denied" or "Insufficient Permissions"**
- Ensure you have `Reader` role on target subscriptions
- Verify `Resource Graph Reader` permissions
- Check with your Azure administrator for proper access

**🚨 "No subscriptions found"**
```powershell
# Make sure you're connected to the right Azure tenant
Get-AzContext
Connect-AzAccount -TenantId "your-tenant-id"
```

**🚨 "KQL Query Failed"**
- This usually indicates permission issues with Resource Graph
- Contact your Azure admin to grant Resource Graph access

---

## 🍷 Pairing Suggestions (Related Tools)

This bisque pairs beautifully with other CloudCostChef specialties:
- **Storage Account Cleanup Soufflé** (coming soon)
- **Unused VM Retirement Roast** (in development)  
- **Over-provisioned Database Diet** (planned)

---

## 🤝 Contributing to the Kitchen

We welcome fellow chefs to contribute to our cost optimization cookbook!

### How to Help:
1. **Fork** the repository
2. **Create** your feature branch (`git checkout -b feature/AmazingIngredient`)
3. **Commit** your changes (`git commit -m 'Add some AmazingIngredient'`)
4. **Push** to the branch (`git push origin feature/AmazingIngredient`)
5. **Open** a Pull Request

### Contribution Ideas:
- New ingredient detection (unused disks, idle VMs, etc.)
- Enhanced cost calculations for different regions
- Additional export formats (Excel, JSON)
- Multi-cloud support (AWS, GCP)

---

## 📞 Support & Feedback

### Need Help in the Kitchen?
- 🐛 **Bug Reports**: Open an issue with detailed reproduction steps
- 💡 **Feature Requests**: Share your ideas for new ingredients to detect
- 💬 **Questions**: Start a discussion in our community forum
- 📧 **Direct Contact**: cloudcostchef@example.com

### Show Your Appreciation:
- ⭐ **Star this repository** if it helped reduce your Azure costs
- 🍽️ **Share your success stories** and savings achieved
- 📢 **Spread the word** to other cloud cost chefs

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🌟 Final Word from the Chef

> *"Remember, a clean Azure kitchen is a profitable kitchen! Every orphaned resource you clean up is money back in your pocket. Cook responsibly, save significantly, and may your cloud costs always be optimized!"*
> 
> — **CloudCostChef** 👨‍🍳

---

## 📈 Success Stories

### What Chefs Are Saying:

> *"This bisque helped us identify $2,400 in annual savings from just 15 minutes of kitchen cleanup!"* - DevOps Chef, TechCorp

> *"The beautiful reports make it easy to show management where we're bleeding money. Saved our team 10 hours of manual resource hunting."* - Cloud Architect, StartupXYZ

> *"Finally, cost optimization that doesn't put people to sleep! The chef theme makes our team actually want to clean up our Azure environment."* - FinOps Lead, Enterprise Inc.

---

**Happy Cooking! 🍲✨**

*Remember to check your Azure costs regularly and keep your cloud kitchen tidy!*
