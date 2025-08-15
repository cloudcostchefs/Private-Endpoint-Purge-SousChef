# ===============================================================================
# 🍲 ORPHANED CLOUD INGREDIENT BISQUE - GCP Edition 🍲
# ===============================================================================
# Chef's Special: A rich, savory bisque that identifies forgotten cloud 
# ingredients (Disks, IPs, and Load Balancers) sitting unused in your GCP pantry,
# turning potential waste into delicious cost savings!
#
# This recipe serves: All GCP projects (or selected portions)
# Prep time: 2-5 minutes | Cook time: 30 seconds - 3 minutes  
# Difficulty: Intermediate | Cuisine: Cloud Cost Optimization
# ===============================================================================

# 🧑‍🍳 CHEF'S PARAMETERS - Customize Your Bisque Recipe
param(
    [string]$OutputPath = ".\GCP_Unattached_Resources_Report.html",  # Where to serve the final dish
    [switch]$AllProjects = $true,                                     # Use all ingredients from the pantry
    [string[]]$ProjectIds = @()                                       # Or hand-pick specific project ingredients
)

# 🍯 INGREDIENT PREPARATION - Import Essential Cooking Modules
try {
    Write-Host "🔪 Sharpening our GCP knives (checking prerequisites)..." -ForegroundColor Yellow
    
    # Check if gcloud CLI is installed - our main cooking utensil
    $gcloudCheck = Get-Command gcloud -ErrorAction SilentlyContinue
    if (-not $gcloudCheck) {
        Write-Error "🚨 Kitchen disaster! Missing gcloud CLI tools."
        Write-Host "💡 Chef's Tip: Install Google Cloud SDK to get cooking!" -ForegroundColor Red
        Write-Host "📖 Recipe: https://cloud.google.com/sdk/docs/install" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Kitchen tools ready! Time to start cooking..." -ForegroundColor Green
} catch {
    Write-Error "🚨 Kitchen setup failed: $($_.Exception.Message)"
    exit 1
}

# 🔐 KITCHEN ACCESS - Ensure Chef Has Proper Credentials
Write-Host "🗝️  Checking GCP kitchen access..." -ForegroundColor Yellow

try {
    # Check if authenticated
    $authCheck = gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>$null
    if (-not $authCheck -or $authCheck.Length -eq 0) {
        Write-Host "🧑‍🍳 Please sign in with your chef credentials..." -ForegroundColor Cyan
        gcloud auth login
    }
    
    $currentAccount = (gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>$null)[0]
    Write-Host "👨‍🍳 Signed in as: $currentAccount" -ForegroundColor Green
} catch {
    Write-Error "🚨 Authentication failed: $($_.Exception.Message)"
    exit 1
}

# 🗂️ PANTRY INVENTORY - Gather All Available Project Ingredients
Write-Host "📋 Taking inventory of GCP project pantries..." -ForegroundColor Cyan

if ($AllProjects) {
    try {
        $projectsJson = gcloud projects list --format="json" --filter="lifecycleState:ACTIVE" 2>$null | ConvertFrom-Json
        $projects = $projectsJson | ForEach-Object { $_.projectId }
        $projectCount = $projects.Count
        Write-Host "🍽️  Found $projectCount well-stocked pantries to explore!" -ForegroundColor Green
    } catch {
        Write-Error "🚨 Failed to list projects: $($_.Exception.Message)"
        exit 1
    }
} else {
    $projects = $ProjectIds
    $projectCount = $projects.Count
    Write-Host "🍽️  Preparing bisque from $projectCount handpicked pantries!" -ForegroundColor Green
}

Write-Host "👨‍🍳 Chef's Special: Analyzing $projectCount project pantries for orphaned cloud ingredients..." -ForegroundColor Green

# 🏷️ INGREDIENT PRICE LIST - Chef's Current Market Rates (USD per month)
$diskCostPerGbMonth = 0.04        # Standard persistent disk cost
$staticIpCostMonth = 7.30         # Reserved static external IP cost  
$forwardingRuleCostMonth = 18.25  # Load balancer forwarding rule cost

# 📊 INITIALIZE COUNTERS - Prep Our Ingredient Inventory
$totalOrphanedDisks = 0
$totalOrphanedStaticIps = 0
$totalOrphanedForwardingRules = 0
$totalDiskSizeGb = 0

# 📝 DATA STORAGE - Arrays to Store Our Findings
$orphanedDisksData = @()
$orphanedIpsData = @()
$orphanedForwardingRulesData = @()
$projectSummaries = @()

Write-Host "`n" -NoNewline
Write-Host "🎉 ════════════════════════════════════════════════════════════ 🎉" -ForegroundColor Green
Write-Host "🍲            STARTING THE GREAT ORPHANED INGREDIENT HUNT            🍲" -ForegroundColor Green  
Write-Host "🎉 ════════════════════════════════════════════════════════════ 🎉" -ForegroundColor Green
Write-Host ""

# 🕵️ THE GREAT INGREDIENT HUNT - Execute Our Bisque Detective Work
foreach ($project in $projects) {
    Write-Host "🔍 Exploring pantry: $project" -ForegroundColor Cyan
    
    # Set the project context
    gcloud config set project $project --quiet 2>$null
    
    # 💽 Hunt for Forgotten Hard Drive Potatoes (Unattached Persistent Disks)
    Write-Host "  🥔 Searching for forgotten disk potatoes..." -ForegroundColor Yellow
    
    try {
        $orphanedDisksJson = gcloud compute disks list --format="json" --filter="NOT users:*" --project=$project 2>$null
        if ($orphanedDisksJson -and $orphanedDisksJson -ne "[]") {
            $orphanedDisks = $orphanedDisksJson | ConvertFrom-Json
            $diskCount = $orphanedDisks.Count
            $totalOrphanedDisks += $diskCount
            
            foreach ($disk in $orphanedDisks) {
                $zoneClean = Split-Path $disk.zone -Leaf
                $typeClean = Split-Path $disk.type -Leaf
                $sizeGb = [int]$disk.sizeGb
                $monthlyCost = $sizeGb * $diskCostPerGbMonth
                $totalDiskSizeGb += $sizeGb
                
                $orphanedDisksData += [PSCustomObject]@{
                    Name = $disk.name
                    Project = $project
                    Zone = $zoneClean
                    SizeGB = $sizeGb
                    Type = $typeClean
                    Created = $disk.creationTimestamp
                    MonthlyCost = $monthlyCost
                }
            }
            
            Write-Host "    Found $diskCount forgotten disk potatoes!" -ForegroundColor White
        } else {
            Write-Host "    No forgotten disk potatoes found - clean pantry!" -ForegroundColor White
        }
    } catch {
        Write-Host "    ⚠️ Could not scan disk potatoes in $project" -ForegroundColor Yellow
    }
    
    # 🌐 Hunt for Crying Onion Static IPs (Unattached Static External IPs)
    Write-Host "  🧅 Looking for crying onion static IPs..." -ForegroundColor Yellow
    
    try {
        $orphanedIpsJson = gcloud compute addresses list --format="json" --filter="status:RESERVED" --project=$project 2>$null
        if ($orphanedIpsJson -and $orphanedIpsJson -ne "[]") {
            $orphanedIps = $orphanedIpsJson | ConvertFrom-Json
            $ipCount = $orphanedIps.Count
            $totalOrphanedStaticIps += $ipCount
            
            foreach ($ip in $orphanedIps) {
                $regionClean = if ($ip.region) { Split-Path $ip.region -Leaf } else { "global" }
                
                $orphanedIpsData += [PSCustomObject]@{
                    Name = $ip.name
                    Project = $project
                    Region = $regionClean
                    Address = $ip.address
                    Type = $ip.addressType
                    Created = $ip.creationTimestamp
                    MonthlyCost = $staticIpCostMonth
                }
            }
            
            Write-Host "    Found $ipCount crying onion static IPs!" -ForegroundColor White
        } else {
            Write-Host "    No crying onion static IPs found - dry pantry!" -ForegroundColor White
        }
    } catch {
        Write-Host "    ⚠️ Could not scan static IPs in $project" -ForegroundColor Yellow
    }
    
    # 🔄 Hunt for Lonely Load Balancer Mushrooms (Unused Forwarding Rules)
    Write-Host "  🍄 Searching for lonely load balancer mushrooms..." -ForegroundColor Yellow
    
    try {
        $forwardingRulesJson = gcloud compute forwarding-rules list --format="json" --project=$project 2>$null
        if ($forwardingRulesJson -and $forwardingRulesJson -ne "[]") {
            $forwardingRules = $forwardingRulesJson | ConvertFrom-Json
            
            # Check for rules with no target (simplified check)
            $orphanedRules = $forwardingRules | Where-Object { -not $_.target -or $_.target -eq "" }
            $ruleCount = $orphanedRules.Count
            
            if ($ruleCount -gt 0) {
                $totalOrphanedForwardingRules += $ruleCount
                
                foreach ($rule in $orphanedRules) {
                    $orphanedForwardingRulesData += [PSCustomObject]@{
                        Name = $rule.name
                        Project = $project
                        Region = if ($rule.region) { Split-Path $rule.region -Leaf } else { "global" }
                        IPAddress = $rule.IPAddress
                        PortRange = $rule.portRange
                        Created = $rule.creationTimestamp
                        MonthlyCost = $forwardingRuleCostMonth
                    }
                }
                
                Write-Host "    Found $ruleCount lonely load balancer mushrooms!" -ForegroundColor White
            } else {
                Write-Host "    No lonely load balancer mushrooms found - connected pantry!" -ForegroundColor White
            }
        } else {
            Write-Host "    No load balancer mushrooms in this pantry!" -ForegroundColor White
        }
    } catch {
        Write-Host "    ⚠️ Could not scan load balancers in $project" -ForegroundColor Yellow
    }
    
    Write-Host "  ✅ Pantry $project inspection complete!" -ForegroundColor Green
}

# 💰 COST CALCULATION KITCHEN - Calculate the Savings Flavor
Write-Host "💰 Calculating the cost of wasted ingredients..." -ForegroundColor Yellow

$diskMonthlyCost = $totalDiskSizeGb * $diskCostPerGbMonth
$staticIpMonthlyCost = $totalOrphanedStaticIps * $staticIpCostMonth
$forwardingRuleMonthlyCost = $totalOrphanedForwardingRules * $forwardingRuleCostMonth

$totalMonthlySavings = $diskMonthlyCost + $staticIpMonthlyCost + $forwardingRuleMonthlyCost
$totalYearlySavings = $totalMonthlySavings * 12

Write-Host "📊 Ingredient Waste Report:" -ForegroundColor Magenta
Write-Host "   🥔 Forgotten Disk Potatoes: $totalOrphanedDisks pieces ($totalDiskSizeGb GB total)" -ForegroundColor White
Write-Host "   🧅 Crying Onion Static IPs: $totalOrphanedStaticIps pieces" -ForegroundColor White
Write-Host "   🍄 Lonely Load Balancer Mushrooms: $totalOrphanedForwardingRules pieces" -ForegroundColor White

Write-Host "💸 Monthly Money Soup: `$$($totalMonthlySavings.ToString('F2'))" -ForegroundColor Green
Write-Host "🎉 Annual Savings Banquet: `$$($totalYearlySavings.ToString('F2'))" -ForegroundColor Green

# 📄 THE GRAND MENU CREATION - Generate Our Beautiful HTML Feast Report
Write-Host "📄 Creating the grand Orphaned Cloud Ingredient Bisque menu..." -ForegroundColor Yellow
$reportDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 🎨 BUILD HTML DATA TABLES
$disksTableHtml = ""
foreach ($disk in $orphanedDisksData) {
    $disksTableHtml += @"
                    <tr>
                        <td>$($disk.Name)</td>
                        <td>$($disk.Project)</td>
                        <td><span class="location-badge">$($disk.Zone)</span></td>
                        <td>$($disk.SizeGB) GB</td>
                        <td>$($disk.Type)</td>
                        <td>$($disk.Created)</td>
                        <td>`$$($disk.MonthlyCost.ToString('F2'))</td>
                    </tr>
"@
}

$ipsTableHtml = ""
foreach ($ip in $orphanedIpsData) {
    $ipsTableHtml += @"
                    <tr>
                        <td>$($ip.Name)</td>
                        <td>$($ip.Project)</td>
                        <td><span class="location-badge">$($ip.Region)</span></td>
                        <td>$($ip.Address)</td>
                        <td>$($ip.Type)</td>
                        <td>$($ip.Created)</td>
                        <td>`$$($ip.MonthlyCost.ToString('F2'))</td>
                    </tr>
"@
}

$forwardingRulesTableHtml = ""
foreach ($rule in $orphanedForwardingRulesData) {
    $forwardingRulesTableHtml += @"
                    <tr>
                        <td>$($rule.Name)</td>
                        <td>$($rule.Project)</td>
                        <td><span class="location-badge">$($rule.Region)</span></td>
                        <td>$($rule.IPAddress)</td>
                        <td>$($rule.PortRange)</td>
                        <td>$($rule.Created)</td>
                        <td>`$$($rule.MonthlyCost.ToString('F2'))</td>
                    </tr>
"@
}

# 🎨 CREATE THE HTML MASTERPIECE
$htmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>🍲 Orphaned Cloud Ingredient Bisque - GCP Edition</title>
    <style>
        /* 🎨 Chef's Signature Styling - Making Our Report Delicious to Look At */
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            margin: 20px; 
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            background-attachment: fixed;
        }
        .container { 
            max-width: 1200px; 
            margin: 0 auto; 
            background-color: white; 
            padding: 20px; 
            border-radius: 15px; 
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            border: 3px solid #4285f4;
        }
        .header { 
            background: linear-gradient(135deg, #4285f4 0%, #34a853 100%); 
            color: white; 
            padding: 25px; 
            border-radius: 12px; 
            margin-bottom: 25px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        .header::before {
            content: "🍲";
            position: absolute;
            top: 10px;
            right: 20px;
            font-size: 3em;
            opacity: 0.3;
        }
        .chef-title {
            font-size: 2.5em;
            margin: 0;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .summary-cards { 
            display: flex; 
            flex-wrap: wrap; 
            gap: 20px; 
            margin-bottom: 25px; 
        }
        .card { 
            background: linear-gradient(135deg, #84fab0 0%, #8fd3f4 100%); 
            border: 2px solid #4ecdc4; 
            border-radius: 15px; 
            padding: 20px; 
            flex: 1; 
            min-width: 220px;
            position: relative;
            overflow: hidden;
        }
        .card::before {
            content: "";
            position: absolute;
            top: -50%;
            right: -50%;
            width: 100%;
            height: 100%;
            background: radial-gradient(circle, rgba(255,255,255,0.3) 0%, transparent 70%);
            transform: rotate(45deg);
        }
        .card h3 { 
            margin-top: 0; 
            color: #2c3e50; 
            font-weight: bold;
            font-size: 1.1em;
        }
        .card .number { 
            font-size: 2.5em; 
            font-weight: bold; 
            color: #e74c3c; 
            text-shadow: 1px 1px 2px rgba(0,0,0,0.2);
        }
        .card .savings { 
            color: #27ae60; 
            font-weight: bold; 
            font-size: 1.1em;
        }
        table { 
            width: 100%; 
            border-collapse: collapse; 
            margin-bottom: 25px;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        th, td { 
            border: 1px solid #ddd; 
            padding: 15px; 
            text-align: left; 
        }
        th { 
            background: linear-gradient(135deg, #4285f4 0%, #34a853 100%); 
            font-weight: bold;
            color: white;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        tr:nth-child(even) { 
            background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%); 
        }
        tr:hover {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
            transform: scale(1.02);
            transition: all 0.3s ease;
        }
        .resource-type { 
            background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%); 
            padding: 20px; 
            border-radius: 15px; 
            margin-bottom: 20px;
            border: 2px solid #ff8a80;
        }
        .cost-highlight { 
            background: linear-gradient(135deg, #a8e6cf 0%, #dcedc1 100%); 
            border: 3px solid #81c784; 
            border-radius: 15px; 
            padding: 20px;
            margin-bottom: 20px;
            position: relative;
        }
        .cost-highlight::before {
            content: "💰";
            position: absolute;
            top: 10px;
            right: 20px;
            font-size: 2em;
        }
        .location-badge { 
            background: linear-gradient(135deg, #4285f4 0%, #34a853 100%); 
            color: white; 
            padding: 5px 12px; 
            border-radius: 20px; 
            font-size: 0.85em;
            font-weight: bold;
        }
        .recommendations { 
            background: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%); 
            border: 3px solid #fdcb6e; 
            border-radius: 15px; 
            padding: 20px; 
            margin-top: 25px;
            color: white;
        }
        .recommendations h3 {
            color: white;
            text-shadow: 1px 1px 2px rgba(0,0,0,0.3);
        }
        .footer { 
            text-align: center; 
            margin-top: 35px; 
            color: #6c757d; 
            font-size: 0.9em;
            padding: 20px;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border-radius: 10px;
        }
        .download-btn { 
            background: linear-gradient(135deg, #56ab2f 0%, #a8e6cf 100%); 
            color: white; 
            padding: 12px 25px; 
            border: none; 
            border-radius: 25px; 
            cursor: pointer; 
            margin: 10px 5px;
            font-weight: bold;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }
        .download-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0,0,0,0.3);
        }
    </style>
    <script>
        function downloadCSV(tableId, filename) {
            console.log('👨‍🍳 Chef is preparing your takeaway CSV...');
            var csv = [];
            var rows = document.querySelectorAll('#' + tableId + ' tr');
            
            for (var i = 0; i < rows.length; i++) {
                var row = [], cols = rows[i].querySelectorAll('td, th');
                for (var j = 0; j < cols.length; j++) {
                    var cellText = cols[j].innerText.replace(/[🥔🧅🍄💰📊]/g, '').trim();
                    row.push('"' + cellText.replace(/"/g, '""') + '"');
                }
                csv.push(row.join(','));
            }
            
            var csvFile = new Blob([csv.join('\n')], {type: 'text/csv'});
            var downloadLink = document.createElement('a');
            downloadLink.download = filename;
            downloadLink.href = window.URL.createObjectURL(csvFile);
            downloadLink.style.display = 'none';
            document.body.appendChild(downloadLink);
            downloadLink.click();
            document.body.removeChild(downloadLink);
        }
    </script>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1 class="chef-title">🍲 Orphaned Cloud Ingredient Bisque</h1>
            <h2>GCP Edition - Chef's Special Cost Optimization Menu</h2>
            <p>📅 Freshly Prepared: $reportDate</p>
            <p>🏪 Pantries Inspected: $projectCount GCP project kitchens</p>
            <p><em>"Turning forgotten GCP ingredients into delicious savings!" - CloudCostChef</em></p>
        </div>

        <div class="summary-cards">
            <div class="card">
                <h3>🥔 Forgotten Disk Potatoes</h3>
                <div class="number">$totalOrphanedDisks</div>
                <div class="savings">Monthly Waste: `$$($diskMonthlyCost.ToString('F2'))</div>
                <p><em>$totalDiskSizeGb GB going stale</em></p>
            </div>
            <div class="card">
                <h3>🧅 Crying Onion Static IPs</h3>
                <div class="number">$totalOrphanedStaticIps</div>
                <div class="savings">Monthly Tears: `$$($staticIpMonthlyCost.ToString('F2'))</div>
                <p><em>Making wallets weep</em></p>
            </div>
            <div class="card">
                <h3>🍄 Lonely Load Balancer Mushrooms</h3>
                <div class="number">$totalOrphanedForwardingRules</div>
                <div class="savings">Monthly Solitude: `$$($forwardingRuleMonthlyCost.ToString('F2'))</div>
                <p><em>Forwarding to nowhere</em></p>
            </div>
            <div class="card">
                <h3>💰 Total Monthly Savings Soup</h3>
                <div class="number">`$$($totalMonthlySavings.ToString('F2'))</div>
                <div class="savings">Annual Feast: `$$($totalYearlySavings.ToString('F2'))</div>
                <p><em>Ready to serve!</em></p>
            </div>
        </div>

        <div class="cost-highlight">
            <h3>🎯 Chef's Cost Savings Special</h3>
            <p><strong>🍜 Monthly Savings Bisque:</strong> `$$($totalMonthlySavings.ToString('F2')) | <strong>🍽️ Annual Savings Banquet:</strong> `$$($totalYearlySavings.ToString('F2'))</p>
            <p><em>*Pricing based on standard GCP market rates - your local prices may vary by region and commitment discounts</em></p>
            <p><strong>👨‍🍳 Chef's Note:</strong> These forgotten ingredients are costing you real money every month!</p>
        </div>

        <div class="resource-type">
            <h2>🥔 Forgotten Disk Potato Collection ($totalOrphanedDisks found rotting)</h2>
            <p><em>These persistent disks are sitting unused, costing you `$$($diskCostPerGbMonth.ToString('F2')) per GB per month!</em></p>
            <button class="download-btn" onclick="downloadCSV('disksTable', 'forgotten_disk_potatoes_inventory.csv')">⬇ 📋 Export Potato Inventory</button>
            <table id="disksTable">
                <thead>
                    <tr>
                        <th>🏷️ Potato Name</th>
                        <th>🏪 Project Pantry</th>
                        <th>🌍 Growing Zone</th>
                        <th>📏 Potato Size</th>
                        <th>🥔 Potato Type</th>
                        <th>📅 Planted Date</th>
                        <th>💸 Monthly Waste Cost</th>
                    </tr>
                </thead>
                <tbody>
$disksTableHtml
                </tbody>
            </table>
        </div>

        <div class="resource-type">
            <h2>🧅 Crying Onion Static IP Collection ($totalOrphanedStaticIps found weeping)</h2>
            <p><em>These static IPs are crying lonely tears and bleeding `$$($staticIpCostMonth.ToString('F2')) per month each from your budget!</em></p>
            <button class="download-btn" onclick="downloadCSV('ipsTable', 'crying_onion_static_ips_inventory.csv')">⬇ 📋 Export Onion Inventory</button>
            <table id="ipsTable">
                <thead>
                    <tr>
                        <th>🏷️ Onion Name</th>
                        <th>🏪 Project Pantry</th>
                        <th>🌍 Growing Region</th>
                        <th>🌐 IP Address</th>
                        <th>📋 Address Type</th>
                        <th>📅 Reserved Date</th>
                        <th>💸 Monthly Tear Cost</th>
                    </tr>
                </thead>
                <tbody>
$ipsTableHtml
                </tbody>
            </table>
        </div>

        <div class="resource-type">
            <h2>🍄 Lonely Load Balancer Mushroom Collection ($totalOrphanedForwardingRules found wilting)</h2>
            <p><em>These forwarding rules are growing alone with no backends, costing `$$($forwardingRuleCostMonth.ToString('F2')) per month each!</em></p>
            <button class="download-btn" onclick="downloadCSV('forwardingRulesTable', 'lonely_load_balancer_mushrooms_inventory.csv')">⬇ 📋 Export Mushroom Inventory</button>
            <table id="forwardingRulesTable">
                <thead>
                    <tr>
                        <th>🏷️ Mushroom Name</th>
                        <th>🏪 Project Pantry</th>
                        <th>🌍 Growing Region</th>
                        <th>🌐 IP Address</th>
                        <th>🔌 Port Range</th>
                        <th>📅 Sprouted Date</th>
                        <th>💸 Monthly Loneliness Cost</th>
                    </tr>
                </thead>
                <tbody>
$forwardingRulesTableHtml
                </tbody>
            </table>
        </div>

        <div class="recommendations">
            <h3>👨‍🍳 Chef's Professional Kitchen Recommendations</h3>
            <ul>
                <li><strong>🔍 Taste Before You Toss:</strong> Always verify these ingredients are truly spoiled before disposal - some might be marinating for future recipes!</li>
                <li><strong>🔗 Check Recipe Dependencies:</strong> Some disks might be snapshots or planned for future VM instances</li>
                <li><strong>🤖 Kitchen Automation:</strong> Implement Cloud Asset Inventory and Policy Intelligence to prevent waste</li>
                <li><strong>📅 Monthly Inventory Audits:</strong> Schedule regular pantry cleanings using Cloud Scheduler</li>
                <li><strong>🏷️ Chef's Labeling System:</strong> Implement consistent resource labeling to identify ownership and purpose</li>
                <li><strong>💡 Pro Chef Tip:</strong> Use Recommender API to get automated suggestions for resource optimization</li>
                <li><strong>📊 Cost Tracking:</strong> Monitor these savings in Cloud Billing reports and set up budget alerts</li>
                <li><strong>🗑️ Automated Cleanup:</strong> Consider Cloud Functions to automatically clean up resources tagged for deletion</li>
                <li><strong>🔄 Lifecycle Management:</strong> Implement disk lifecycle policies and automated snapshots before cleanup</li>
            </ul>
            <p><em><strong>Remember:</strong> A clean cloud kitchen is a profitable kitchen! - CloudCostChef</em></p>
        </div>

        <div class="footer">
            <p><strong>🍲 Orphaned Cloud Ingredient Bisque - GCP Edition</strong> - Prepared by CloudCostChef's Kitchen</p>
            <p>Generated: $reportDate | <em>"Where forgotten ingredients become found savings!"</em></p>
            <p>This bisque helps identify potential cost savings by finding orphaned GCP resources in your project pantries</p>
            <p>🌟 <strong>Bon Appétit!</strong> Enjoy your cost savings feast! 🌟</p>
        </div>
    </div>
</body>
</html>
"@

# 🍽️ SERVE THE DISH - Save and Present the Final Report
Write-Host "🍽️  Plating the final Orphaned Cloud Ingredient Bisque..." -ForegroundColor Yellow
$htmlReport | Out-File -FilePath $OutputPath -Encoding UTF8

# 🎉 CHEF'S FINAL PRESENTATION - Display Results with Flair
Write-Host "`n" -NoNewline
Write-Host "🎉 ════════════════════════════════════════════════════════════ 🎉" -ForegroundColor Green
Write-Host "🍲            ORPHANED CLOUD INGREDIENT BISQUE COMPLETE!            🍲" -ForegroundColor Green  
Write-Host "🎉 ════════════════════════════════════════════════════════════ 🎉" -ForegroundColor Green

Write-Host "`n👨‍🍳 Chef's Summary:" -ForegroundColor Cyan
Write-Host "   🍽️  Bisque successfully prepared and plated!" -ForegroundColor White
Write-Host "   📄 Menu saved to: $OutputPath" -ForegroundColor Yellow
Write-Host "   💰 Monthly savings soup ready: `$$($totalMonthlySavings.ToString('F2'))" -ForegroundColor Green
Write-Host "   🎊 Annual savings banquet available: `$$($totalYearlySavings.ToString('F2'))" -ForegroundColor Green

Write-Host "`n🍲 BISQUE INGREDIENTS FOUND:" -ForegroundColor Magenta
Write-Host "   🥔 Forgotten disk potatoes: $totalOrphanedDisks ($totalDiskSizeGb GB wasting `$$($diskMonthlyCost.ToString('F2'))/month)" -ForegroundColor White
Write-Host "   🧅 Crying onion static IPs: $totalOrphanedStaticIps (bleeding `$$($staticIpMonthlyCost.ToString('F2'))/month)" -ForegroundColor White
Write-Host "   🍄 Lonely load balancer mushrooms: $totalOrphanedForwardingRules (costing `$$($forwardingRuleMonthlyCost.ToString('F2'))/month)" -ForegroundColor White
Write-Host "   📊 Total forgotten ingredients: $($totalOrphanedDisks + $totalOrphanedStaticIps + $totalOrphanedForwardingRules)" -ForegroundColor White
Write-Host "   🏪 Project kitchens inspected: $projectCount" -ForegroundColor White

Write-Host "`n💡 Chef's Professional Tip:" -ForegroundColor Yellow
Write-Host "   These orphaned ingredients are costing real money every month!" -ForegroundColor White
Write-Host "   Clean up your GCP kitchen and watch the savings add up! 🧹✨" -ForegroundColor White

# 🍷 OFFER THE WINE PAIRING - Ask to Open Report
Write-Host "`n🍷 Would you like to taste your freshly prepared bisque now? (Y/N)" -ForegroundColor Cyan
$openReport = Read-Host "   Press Y to open the cost savings menu"

if ($openReport -eq 'Y' -or $openReport -eq 'y') {
    Write-Host "🎭 Opening the grand cost savings menu presentation..." -ForegroundColor Green
    Start-Process $OutputPath
    Write-Host "🌟 Bon appétit! Enjoy your GCP cost optimization feast! 🌟" -ForegroundColor Green
} else {
    Write-Host "🍽️  Your bisque is ready whenever you're hungry for savings!" -ForegroundColor Yellow
    Write-Host "📄 Just open: $OutputPath" -ForegroundColor Cyan
}

Write-Host "`n👨‍🍳 Thank you for dining at CloudCostChef's Kitchen!" -ForegroundColor Magenta
Write-Host "🌟 Remember: A clean GCP kitchen is a profitable kitchen! 🌟" -ForegroundColor Green
