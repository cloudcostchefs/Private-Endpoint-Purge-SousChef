# ===============================================================================
# 🍲 ORPHANED NETWORK INGREDIENT BISQUE 🍲
# ===============================================================================
# Chef's Special: A rich, savory bisque that identifies forgotten network 
# ingredients (NICs and Public IPs) sitting unused in your Azure pantry,
# turning potential waste into delicious cost savings!
#
# This recipe serves: All Azure subscriptions (or selected portions)
# Prep time: 2-5 minutes | Cook time: 30 seconds - 2 minutes
# Difficulty: Intermediate | Cuisine: Cloud Cost Optimization
# ===============================================================================

# 🧑‍🍳 CHEF'S PARAMETERS - Customize Your Bisque Recipe
param(
    [string]$OutputPath = ".\Azure_Unattached_Resources_Report.html",  # Where to serve the final dish
    [switch]$AllSubscriptions = $true,                                   # Use all ingredients from the pantry
    [string[]]$SubscriptionIds = @()                                    # Or hand-pick specific subscription ingredients
)

# 🍯 INGREDIENT PREPARATION - Import Essential Cooking Modules
# Just like any good chef needs proper utensils, we need our Azure PowerShell tools
try {
    Write-Host "🔪 Sharpening our Azure knives (importing modules)..." -ForegroundColor Yellow
    
    # Our main cooking utensils for this bisque recipe
    Import-Module Az.Accounts -Force      # The master chef's access pass
    Import-Module Az.ResourceGraph -Force # Our ingredient scanner and sorter
    Import-Module Az.Billing -Force       # The cost calculator for our savings menu
    
    Write-Host "✅ Kitchen tools ready! Time to start cooking..." -ForegroundColor Green
} catch {
    Write-Error "🚨 Kitchen disaster! Missing essential cooking tools. Please stock your pantry with: Install-Module Az"
    Write-Host "💡 Chef's Tip: Run 'Install-Module Az' to get all the ingredients you need!" -ForegroundColor Red
    exit 1
}

# 🔐 KITCHEN ACCESS - Ensure Chef Has Proper Credentials
# No chef can cook without access to the kitchen!
if (-not (Get-AzContext)) {
    Write-Host "🗝️  Unlocking the Azure kitchen doors..." -ForegroundColor Yellow
    Write-Host "🧑‍🍳 Please sign in with your chef credentials..." -ForegroundColor Cyan
    Connect-AzAccount
}

# 🗂️ PANTRY INVENTORY - Gather All Available Subscription Ingredients
# Time to see what subscriptions (pantries) we're working with
if ($AllSubscriptions) {
    Write-Host "📋 Taking inventory of ALL subscription pantries..." -ForegroundColor Cyan
    $subscriptions = Get-AzSubscription | Where-Object { $_.State -eq "Enabled" }
    Write-Host "🍽️  Found $($subscriptions.Count) well-stocked pantries to explore!" -ForegroundColor Green
} else {
    Write-Host "🎯 Working with chef's selected pantries only..." -ForegroundColor Cyan
    $subscriptions = $SubscriptionIds | ForEach-Object { Get-AzSubscription -SubscriptionId $_ }
    Write-Host "🍽️  Preparing bisque from $($subscriptions.Count) handpicked pantries!" -ForegroundColor Green
}

Write-Host "👨‍🍳 Chef's Special: Analyzing $($subscriptions.Count) subscription pantries for orphaned network ingredients..." -ForegroundColor Green

# 🔍 RECIPE QUERIES - Our Secret Bisque Ingredients Detection Formulas
# These KQL queries are like our family recipes - passed down through generations of cloud chefs!

# 🥬 LONELY NIC LETTUCE - Finding Network Interface Cards Without Purpose
# These NICs are like lettuce sitting in the fridge, forgotten and going bad
$unattachedNicQuery = @"
Resources
| where type == "microsoft.network/networkinterfaces"
| where properties.virtualMachine == ""                    // No VM boyfriend/girlfriend
| where isempty(properties.privateEndpoint)               // Not attached to private endpoint either
| extend ipConfigs = properties.ipConfigurations
| mv-expand ipConfig = ipConfigs
| extend 
    hasLoadBalancer = isnotempty(ipConfig.properties.loadBalancerBackendAddressPools) or isnotempty(ipConfig.properties.loadBalancerInboundNatRules),
    hasAppGateway = isnotempty(ipConfig.properties.applicationGatewayBackendAddressPools),
    hasPrivateLinkConnection = isnotempty(ipConfig.properties.privateLinkConnectionProperties)
| where not(hasLoadBalancer) and not(hasAppGateway) and not(hasPrivateLinkConnection)  // Truly orphaned ingredients
| project 
    name,
    resourceGroup,
    location,
    subscriptionId,
    privateIP = tostring(ipConfig.properties.privateIPAddress),
    tags
"@

# 🧅 CRYING ONION PUBLIC IPs - Public IPs That Make You Cry (From Wasted Money)
# Like onions that make you cry, these unused Public IPs are making your wallet weep
$unattachedPublicIpQuery = @"
Resources
| where type == "microsoft.network/publicipaddresses"
| where isempty(properties.ipConfiguration)              // No one wants to dance with these IPs
| project 
    name,
    resourceGroup,
    location,
    subscriptionId,
    ipAddress = properties.ipAddress,
    allocationMethod = properties.publicIPAllocationMethod,
    ipVersion = properties.publicIPAddressVersion,
    sku = sku.name,
    tags
"@

# 🍴 INGREDIENT SCANNER FUNCTION - Our Magical Kitchen Scanner
# This function is like having X-ray vision to see all ingredients in the pantry
function Invoke-KqlQuery {
    param($Query, $SubscriptionIds)
    
    Write-Host "🔬 Scanning pantries with our magical ingredient detector..." -ForegroundColor Yellow
    
    try {
        $results = Search-AzGraph -Query $Query -Subscription $SubscriptionIds
        Write-Host "✨ Successfully scanned and found ingredients!" -ForegroundColor Green
        return $results
    } catch {
        Write-Warning "⚠️  Kitchen scanner malfunction: $($_.Exception.Message)"
        Write-Host "🤷‍♂️ Sometimes our ingredient scanner gets a bit temperamental..." -ForegroundColor Yellow
        return @()
    }
}

# 🕵️ THE GREAT INGREDIENT HUNT - Execute Our Bisque Detective Work
Write-Host "🕵️‍♂️ Beginning the Great Orphaned Ingredient Hunt..." -ForegroundColor Yellow
Write-Host "🔍 Deploying our secret recipe scanners across all pantries..." -ForegroundColor Cyan

$subscriptionIds = $subscriptions.Id

# 🥬 Hunt for Lonely Lettuce (Unattached NICs)
Write-Host "🥬 Searching for lonely NIC lettuce..." -ForegroundColor Cyan
$unattachedNics = Invoke-KqlQuery -Query $unattachedNicQuery -SubscriptionIds $subscriptionIds

# 🧅 Hunt for Crying Onions (Unattached Public IPs)  
Write-Host "🧅 Looking for crying onion Public IPs..." -ForegroundColor Cyan
$unattachedPublicIps = Invoke-KqlQuery -Query $unattachedPublicIpQuery -SubscriptionIds $subscriptionIds

# 💰 COST CALCULATION KITCHEN - Where We Calculate the Savings Flavor
# Every great chef knows the cost of their ingredients!
Write-Host "💰 Calculating the cost of wasted ingredients..." -ForegroundColor Yellow

# 🏷️ INGREDIENT PRICE LIST - Chef's Current Market Rates (USD per month)
$nicMonthlyCost = 1.50              # Cost of letting NIC lettuce rot in the fridge
$publicIpMonthlyCost = 3.65         # Price of crying onion Public IPs
$staticPublicIpMonthlyCost = 3.65   # Static onions cost the same tears

# 🧮 SAVINGS CALCULATOR - Count Our Wasted Ingredients
$totalNics = $unattachedNics.Count
$totalPublicIps = $unattachedPublicIps.Count

Write-Host "📊 Ingredient Waste Report:" -ForegroundColor Magenta
Write-Host "   🥬 Lonely NIC Lettuce Found: $totalNics pieces" -ForegroundColor White
Write-Host "   🧅 Crying Onion Public IPs Found: $totalPublicIps pieces" -ForegroundColor White

# 💸 THE SAVINGS FEAST - Calculate How Much Money We're Leaving on the Table
$nicsCost = $totalNics * $nicMonthlyCost
$publicIpsCost = $totalPublicIps * $publicIpMonthlyCost
$totalMonthlySavings = $nicsCost + $publicIpsCost
$totalYearlySavings = $totalMonthlySavings * 12

Write-Host "💸 Monthly Money Soup: $($totalMonthlySavings.ToString('F2'))" -ForegroundColor Green
Write-Host "🎉 Annual Savings Banquet: $($totalYearlySavings.ToString('F2'))" -ForegroundColor Green

# 🎨 PRESENTATION PREP - Format Our Currency for the Final Dish
# A good chef always plates beautifully!
$nicsCostFormatted = $nicsCost.ToString('F2')
$publicIpsCostFormatted = $publicIpsCost.ToString('F2')
$totalMonthlySavingsFormatted = $totalMonthlySavings.ToString('F2')
$totalYearlySavingsFormatted = $totalYearlySavings.ToString('F2')
$nicMonthlyCostFormatted = $nicMonthlyCost.ToString('F2')
$publicIpMonthlyCostFormatted = $publicIpMonthlyCost.ToString('F2')

# 🍽️ ORGANIZE BY PANTRY - Group Ingredients by Subscription Kitchen
Write-Host "🍽️  Organizing ingredients by subscription pantry..." -ForegroundColor Cyan
$nicsBySubscription = $unattachedNics | Group-Object -Property subscriptionId
$publicIpsBySubscription = $unattachedPublicIps | Group-Object -Property subscriptionId

# 📚 PANTRY DIRECTORY - Create Our Subscription Kitchen Registry
$subscriptionDetails = @{}
foreach ($sub in $subscriptions) {
    $subscriptionDetails[$sub.Id] = @{
        Name = $sub.Name
        Id = $sub.Id
        TenantId = $sub.TenantId
    }
}

# 📄 THE GRAND MENU CREATION - Generate Our Beautiful HTML Feast Report
Write-Host "📄 Creating the grand Orphaned Network Ingredient Bisque menu..." -ForegroundColor Yellow
$reportDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 🎨 START THE MASTERPIECE - Begin HTML Report Creation
$htmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>🍲 Orphaned Network Ingredient Bisque - Cost Savings Menu</title>
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
            border: 3px solid #ff6b6b;
        }
        .header { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
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
            background: linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%); 
            font-weight: bold;
            color: #2c3e50;
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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
            color: white; 
            padding: 5px 12px; 
            border-radius: 20px; 
            font-size: 0.85em;
            font-weight: bold;
        }
        .subscription-section { 
            margin-bottom: 35px; 
            padding: 20px; 
            border: 2px solid #ff6b6b; 
            border-radius: 15px;
            background: linear-gradient(135deg, #ffeaa7 0%, #fab1a0 100%);
        }
        .tags { 
            font-size: 0.8em; 
            color: #6c757d; 
            max-width: 200px; 
            word-wrap: break-word;
            background: #f8f9fa;
            padding: 5px;
            border-radius: 5px;
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
        .chef-emoji {
            font-size: 1.5em;
            margin: 0 5px;
        }
    </style>
    <script>
        // 🔽 CHEF'S SPECIAL DOWNLOAD RECIPE - Turn Tables Into Takeaway CSV
        function downloadCSV(tableId, filename) {
            console.log('👨‍🍳 Chef is preparing your takeaway CSV...');
            var csv = [];
            var rows = document.querySelectorAll('#' + tableId + ' tr');
            
            for (var i = 0; i < rows.length; i++) {
                var row = [], cols = rows[i].querySelectorAll('td, th');
                for (var j = 0; j < cols.length; j++) {
                    // Clean up any chef emojis for CSV export
                    var cellText = cols[j].innerText.replace(/[🥬🧅💰📊]/g, '').trim();
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
            
            console.log('✅ Takeaway CSV ready! Bon appétit!');
        }
    </script>
</head>
<body>
    <div class="container">
        <!-- 🍲 THE GRAND HEADER - Our Restaurant Sign -->
        <div class="header">
            <h1 class="chef-title">🍲 Orphaned Network Ingredient Bisque</h1>
            <h2>Chef's Special Cost Optimization Menu</h2>
            <p><span class="chef-emoji">📅</span>Freshly Prepared: $reportDate</p>
            <p><span class="chef-emoji">🏪</span>Pantries Inspected: $($subscriptions.Count) subscription kitchens</p>
            <p><em>"Turning forgotten ingredients into delicious savings!" - CloudCostChef</em></p>
        </div>

        <!-- 💎 INGREDIENT SUMMARY CARDS - Our Appetizer Spread -->
        <div class="summary-cards">
            <div class="card">
                <h3>🥬 Lonely NIC Lettuce</h3>
                <div class="number">$totalNics</div>
                <div class="savings">Monthly Waste: `$$($nicsCost.ToString('F2'))</div>
                <p><em>Wilting away unused</em></p>
            </div>
            <div class="card">
                <h3>🧅 Crying Onion Public IPs</h3>
                <div class="number">$totalPublicIps</div>
                <div class="savings">Monthly Tears: `$$($publicIpsCost.ToString('F2'))</div>
                <p><em>Making wallets weep</em></p>
            </div>
            <div class="card">
                <h3>💰 Total Monthly Savings Soup</h3>
                <div class="number">`$$($totalMonthlySavings.ToString('F2'))</div>
                <div class="savings">Annual Feast: `$$($totalYearlySavings.ToString('F2'))</div>
                <p><em>Ready to serve!</em></p>
            </div>
            <div class="card">
                <h3>📊 Total Wasted Ingredients</h3>
                <div class="number">$($totalNics + $totalPublicIps)</div>
                <div class="savings">Items for cleanup</div>
                <p><em>Time for spring cleaning!</em></p>
            </div>
        </div>

        <!-- 🎯 COST SAVINGS HIGHLIGHT - The Main Course Presentation -->
        <div class="cost-highlight">
            <h3>🎯 Chef's Cost Savings Special</h3>
            <p><strong>🍜 Monthly Savings Bisque:</strong> `$$($totalMonthlySavings.ToString('F2')) | <strong>🍽️ Annual Savings Banquet:</strong> `$$($totalYearlySavings.ToString('F2'))</p>
            <p><em>*Pricing based on standard Azure market rates - your local prices may vary by region and seasonal demand</em></p>
            <p><strong>👨‍🍳 Chef's Note:</strong> These forgotten ingredients are costing you real money every month!</p>
        </div>

        <!-- 🥬 LONELY LETTUCE SECTION - Unattached NICs Menu -->
        <div class="resource-type">
            <h2>🥬 Lonely NIC Lettuce Collection ($totalNics found wilting)</h2>
            <p><em>These network interfaces are sitting alone, unused, and costing you `$$nicMonthlyCostFormatted per month each!</em></p>
            <button class="download-btn" onclick="downloadCSV('nicsTable', 'lonely_nic_lettuce_inventory.csv')">⬇ 📋 Export Lettuce Inventory</button>
            <table id="nicsTable">
                <thead>
                    <tr>
                        <th>🏷️ Ingredient Name</th>
                        <th>🏪 Pantry (Subscription)</th>
                        <th>📦 Storage Group</th>
                        <th>🌍 Kitchen Location</th>
                        <th>🔢 Private IP Address</th>
                        <th>🏷️ Chef's Labels (Tags)</th>
                        <th>💸 Monthly Waste Cost</th>
                    </tr>
                </thead>
                <tbody>
"@

# 🥬 ADD LONELY LETTUCE ENTRIES - Populate NIC Table
Write-Host "🥬 Adding lonely NIC lettuce entries to the menu..." -ForegroundColor Cyan
foreach ($nic in $unattachedNics) {
    $subscriptionName = $subscriptionDetails[$nic.subscriptionId].Name
    $tags = if ($nic.tags) { ($nic.tags | ConvertTo-Json -Compress) } else { "No chef labels" }
    $htmlReport += @"
                    <tr>
                        <td>$($nic.name)</td>
                        <td>$subscriptionName</td>
                        <td>$($nic.resourceGroup)</td>
                        <td><span class="location-badge">$($nic.location)</span></td>
                        <td>$($nic.privateIP)</td>
                        <td class="tags">$tags</td>
                        <td>`$${nicMonthlyCost.ToString('F2')}</td>
                    </tr>
"@
}

# 🧅 CRYING ONIONS SECTION - Continue Building the Menu
$htmlReport += @"
                </tbody>
            </table>
        </div>

        <!-- 🧅 CRYING ONION SECTION - Unattached Public IPs Menu -->
        <div class="resource-type">
            <h2>🧅 Crying Onion Public IP Collection ($totalPublicIps found weeping)</h2>
            <p><em>These public IPs are crying lonely tears and bleeding `$$publicIpMonthlyCostFormatted per month each from your budget!</em></p>
            <button class="download-btn" onclick="downloadCSV('publicIpsTable', 'crying_onion_public_ips_inventory.csv')">⬇ 📋 Export Onion Inventory</button>
            <table id="publicIpsTable">
                <thead>
                    <tr>
                        <th>🏷️ Onion Name</th>
                        <th>🏪 Pantry (Subscription)</th>
                        <th>📦 Storage Group</th>
                        <th>🌍 Growing Location</th>
                        <th>🌐 IP Address</th>
                        <th>⭐ Onion Grade (SKU)</th>
                        <th>📋 Allocation Recipe</th>
                        <th>🏷️ Chef's Labels (Tags)</th>
                        <th>💸 Monthly Tear Cost</th>
                    </tr>
                </thead>
                <tbody>
"@

# 🧅 ADD CRYING ONION ENTRIES - Populate Public IP Table
Write-Host "🧅 Adding crying onion Public IP entries to the menu..." -ForegroundColor Cyan
foreach ($pip in $unattachedPublicIps) {
    $subscriptionName = $subscriptionDetails[$pip.subscriptionId].Name
    $tags = if ($pip.tags) { ($pip.tags | ConvertTo-Json -Compress) } else { "No chef labels" }
    $htmlReport += @"
                    <tr>
                        <td>$($pip.name)</td>
                        <td>$subscriptionName</td>
                        <td>$($pip.resourceGroup)</td>
                        <td><span class="location-badge">$($pip.location)</span></td>
                        <td>$($pip.ipAddress)</td>
                        <td>$($pip.sku)</td>
                        <td>$($pip.allocationMethod)</td>
                        <td class="tags">$tags</td>
                        <td>`$${publicIpMonthlyCost.ToString('F2')}</td>
                    </tr>
"@
}

# 🏪 PANTRY BREAKDOWN SECTION - Subscription Analysis
$htmlReport += @"
                </tbody>
            </table>
        </div>

        <!-- 🏪 PANTRY BREAKDOWN - By Subscription Kitchen Analysis -->
        <div class="subscription-section">
            <h2>🏪 Pantry Breakdown - Cost Analysis by Kitchen</h2>
            <p><em>Here's how much each subscription kitchen is wasting on forgotten ingredients:</em></p>
            <table>
                <thead>
                    <tr>
                        <th>🏪 Kitchen Name</th>
                        <th>🆔 Pantry ID</th>
                        <th>🥬 Lonely Lettuce Count</th>
                        <th>🧅 Crying Onions Count</th>
                        <th>💸 Monthly Kitchen Waste</th>
                    </tr>
                </thead>
                <tbody>
"@

# 🏪 ADD PANTRY BREAKDOWN ENTRIES
Write-Host "🏪 Creating pantry breakdown by subscription..." -ForegroundColor Cyan
$allSubscriptionIds = ($unattachedNics.subscriptionId + $unattachedPublicIps.subscriptionId) | Sort-Object -Unique
foreach ($subId in $allSubscriptionIds) {
    $subName = $subscriptionDetails[$subId].Name
    $subNics = ($unattachedNics | Where-Object { $_.subscriptionId -eq $subId }).Count
    $subPips = ($unattachedPublicIps | Where-Object { $_.subscriptionId -eq $subId }).Count
    $subSavings = ($subNics * $nicMonthlyCost) + ($subPips * $publicIpMonthlyCost)
    
    $htmlReport += @"
                    <tr>
                        <td>$subName</td>
                        <td>$subId</td>
                        <td>$subNics</td>
                        <td>$subPips</td>
                        <td>`$$($subSavings.ToString('F2'))</td>
                    </tr>
"@
}

# 🍽️ CHEF'S RECOMMENDATIONS - Final Course
$htmlReport += @"
                </tbody>
            </table>
        </div>

        <!-- 👨‍🍳 CHEF'S RECOMMENDATIONS - Professional Kitchen Wisdom -->
        <div class="recommendations">
            <h3>👨‍🍳 Chef's Professional Kitchen Recommendations</h3>
            <ul>
                <li><strong>🔍 Taste Before You Toss:</strong> Always verify these ingredients are truly spoiled before disposal - some might be marinating for future recipes!</li>
                <li><strong>🔗 Check the Recipe Dependencies:</strong> Some ingredients might be planned for tomorrow's special dishes</li>
                <li><strong>🤖 Kitchen Automation:</strong> Implement Azure Policy rules to prevent ingredients from going bad in the first place</li>
                <li><strong>📅 Monthly Inventory Audits:</strong> Schedule regular pantry cleanings to catch spoiling ingredients early</li>
                <li><strong>🏷️ Chef's Labeling System:</strong> Implement consistent tagging to identify ingredient ownership and purpose</li>
                <li><strong>💡 Pro Chef Tip:</strong> Set up alerts when ingredients sit unused for more than 30 days</li>
                <li><strong>📊 Cost Tracking:</strong> Monitor these savings in your monthly kitchen budget reports</li>
            </ul>
            <p><em><strong>Remember:</strong> A clean kitchen is a profitable kitchen! - CloudCostChef</em></p>
        </div>

        <!-- 🍽️ RESTAURANT FOOTER - Credits and Closing -->
        <div class="footer">
            <p><strong>🍲 Orphaned Network Ingredient Bisque</strong> - Prepared by CloudCostChef's Kitchen</p>
            <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | <em>"Where forgotten ingredients become found savings!"</em></p>
            <p>This bisque helps identify potential cost savings by finding orphaned Azure network ingredients in your subscription pantries</p>
            <p>🌟 <strong>Bon Appétit!</strong> Enjoy your cost savings feast! 🌟</p>
        </div>
    </div>
</body>
</html>
"@

# 🍽️ SERVE THE DISH - Save and Present the Final Report
Write-Host "🍽️  Plating the final Orphaned Network Ingredient Bisque..." -ForegroundColor Yellow
$htmlReport | Out-File -FilePath $OutputPath -Encoding UTF8

# 🎉 CHEF'S FINAL PRESENTATION - Display Results with Flair
Write-Host "`n" -NoNewline
Write-Host "🎉 ════════════════════════════════════════════════════════════ 🎉" -ForegroundColor Green
Write-Host "🍲            ORPHANED NETWORK INGREDIENT BISQUE COMPLETE!            🍲" -ForegroundColor Green  
Write-Host "🎉 ════════════════════════════════════════════════════════════ 🎉" -ForegroundColor Green

Write-Host "`n👨‍🍳 Chef's Summary:" -ForegroundColor Cyan
Write-Host "   🍽️  Bisque successfully prepared and plated!" -ForegroundColor White
Write-Host "   📄 Menu saved to: $OutputPath" -ForegroundColor Yellow
Write-Host "   💰 Monthly savings soup ready: `$$($totalMonthlySavings.ToString('F2'))" -ForegroundColor Green
Write-Host "   🎊 Annual savings banquet available: `$$($totalYearlySavings.ToString('F2'))" -ForegroundColor Green

Write-Host "`n🍲 BISQUE INGREDIENTS FOUND:" -ForegroundColor Magenta
Write-Host "   🥬 Lonely NIC Lettuce pieces: $totalNics (wasting `$$($nicsCost.ToString('F2'))/month)" -ForegroundColor White
Write-Host "   🧅 Crying Onion Public IPs: $totalPublicIps (bleeding `$$($publicIpsCost.ToString('F2'))/month)" -ForegroundColor White
Write-Host "   📊 Total forgotten ingredients: $($totalNics + $totalPublicIps)" -ForegroundColor White
Write-Host "   🏪 Subscription kitchens inspected: $($subscriptions.Count)" -ForegroundColor White

Write-Host "`n💡 Chef's Professional Tip:" -ForegroundColor Yellow
Write-Host "   These orphaned ingredients are costing real money every month!" -ForegroundColor White
Write-Host "   Clean up your Azure kitchen and watch the savings add up! 🧹✨" -ForegroundColor White

# 🍷 OFFER THE WINE PAIRING - Ask to Open Report
Write-Host "`n🍷 Would you like to taste your freshly prepared bisque now? (Y/N)" -ForegroundColor Cyan
$openReport = Read-Host "   Press Y to open the cost savings menu"

if ($openReport -eq 'Y' -or $openReport -eq 'y') {
    Write-Host "🎭 Opening the grand cost savings menu presentation..." -ForegroundColor Green
    Start-Process $OutputPath
    Write-Host "🌟 Bon appétit! Enjoy your Azure cost optimization feast! 🌟" -ForegroundColor Green
} else {
    Write-Host "🍽️  Your bisque is ready whenever you're hungry for savings!" -ForegroundColor Yellow
    Write-Host "📄 Just open: $OutputPath" -ForegroundColor Cyan
}

Write-Host "`n👨‍🍳 Thank you for dining at CloudCostChef's Kitchen!" -ForegroundColor Magenta
Write-Host "🌟 Remember: A clean Azure kitchen is a profitable kitchen! 🌟" -ForegroundColor Green
