# ===============================================================================
# 🍲 ORPHANED CLOUD INGREDIENT BISQUE - AWS Edition 🍲
# ===============================================================================
# Chef's Special: A rich, savory bisque that identifies forgotten cloud 
# ingredients (EBS Volumes, Elastic IPs, Load Balancers, and NAT Gateways) 
# sitting unused in your AWS pantry, turning potential waste into delicious cost savings!
#
# This recipe serves: All AWS regions (or selected portions)
# Prep time: 2-5 minutes | Cook time: 1-5 minutes  
# Difficulty: Intermediate | Cuisine: Cloud Cost Optimization
# ===============================================================================

# 🧑‍🍳 CHEF'S PARAMETERS - Customize Your Bisque Recipe
param(
    [string]$OutputPath = ".\AWS_Unattached_Resources_Report.html",  # Where to serve the final dish
    [switch]$AllRegions = $true,                                      # Use all ingredients from all pantries
    [string[]]$RegionNames = @("us-east-1", "us-west-2"),           # Or hand-pick specific regional pantries
    [string]$AwsProfile = "default"                                   # AWS credentials profile to use
)

# 🍯 INGREDIENT PREPARATION - Import Essential Cooking Modules
try {
    Write-Host "🔪 Sharpening our AWS knives (checking prerequisites)..." -ForegroundColor Yellow
    
    # Check if AWS CLI is installed - our main cooking utensil
    $awsCheck = Get-Command aws -ErrorAction SilentlyContinue
    if (-not $awsCheck) {
        Write-Error "🚨 Kitchen disaster! Missing AWS CLI tools."
        Write-Host "💡 Chef's Tip: Install AWS CLI to get cooking!" -ForegroundColor Red
        Write-Host "📖 Recipe: https://aws.amazon.com/cli/" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Kitchen tools ready! Time to start cooking..." -ForegroundColor Green
} catch {
    Write-Error "🚨 Kitchen setup failed: $($_.Exception.Message)"
    exit 1
}

# 🔐 KITCHEN ACCESS - Ensure Chef Has Proper Credentials
Write-Host "🗝️  Checking AWS kitchen access..." -ForegroundColor Yellow

try {
    # Check if authenticated with the specified profile
    $identityCheck = aws sts get-caller-identity --profile $AwsProfile 2>$null
    if (-not $identityCheck) {
        Write-Error "🚨 Authentication failed! Please configure your AWS credentials."
        Write-Host "💡 Chef's Tip: Run 'aws configure --profile $AwsProfile' to set up your kitchen access!" -ForegroundColor Red
        exit 1
    }
    
    $identity = $identityCheck | ConvertFrom-Json
    Write-Host "👨‍🍳 Signed in as: $($identity.Arn)" -ForegroundColor Green
    Write-Host "🏪 Using AWS Profile: $AwsProfile" -ForegroundColor Green
} catch {
    Write-Error "🚨 Authentication failed: $($_.Exception.Message)"
    exit 1
}

# 🗂️ PANTRY INVENTORY - Gather All Available Regional Pantries
Write-Host "📋 Taking inventory of AWS regional pantries..." -ForegroundColor Cyan

if ($AllRegions) {
    try {
        $regionsJson = aws ec2 describe-regions --profile $AwsProfile 2>$null
        if ($regionsJson) {
            $regionsData = $regionsJson | ConvertFrom-Json
            $regions = $regionsData.Regions | ForEach-Object { $_.RegionName }
            $regionCount = $regions.Count
            Write-Host "🍽️  Found $regionCount well-stocked regional pantries to explore!" -ForegroundColor Green
        } else {
            throw "Failed to list regions"
        }
    } catch {
        Write-Error "🚨 Failed to list regions: $($_.Exception.Message)"
        exit 1
    }
} else {
    $regions = $RegionNames
    $regionCount = $regions.Count
    Write-Host "🍽️  Preparing bisque from $regionCount handpicked regional pantries!" -ForegroundColor Green
}

Write-Host "👨‍🍳 Chef's Special: Analyzing $regionCount regional pantries for orphaned cloud ingredients..." -ForegroundColor Green

# 🏷️ INGREDIENT PRICE LIST - Chef's Current Market Rates (USD per month)
$ebsVolumeGp3CostPerGbMonth = 0.08     # GP3 EBS volume cost per GB
$ebsVolumeGp2CostPerGbMonth = 0.10     # GP2 EBS volume cost per GB  
$elasticIpCostMonth = 3.65             # Unassociated Elastic IP cost
$albCostMonth = 16.20                  # Application Load Balancer cost
$nlbCostMonth = 16.20                  # Network Load Balancer cost
$clbCostMonth = 18.00                  # Classic Load Balancer cost
$natGatewayCostMonth = 32.40           # NAT Gateway cost

# 📊 INITIALIZE COUNTERS - Prep Our Ingredient Inventory
$totalOrphanedEbsVolumes = 0
$totalOrphanedElasticIps = 0
$totalOrphanedLoadBalancers = 0
$totalOrphanedNatGateways = 0
$totalEbsVolumeSize = 0

# 📝 DATA STORAGE - Arrays to Store Our Findings
$orphanedEbsData = @()
$orphanedElasticIpsData = @()
$orphanedLoadBalancersData = @()
$orphanedNatGatewaysData = @()

Write-Host "`n" -NoNewline
Write-Host "🎉 ════════════════════════════════════════════════════════════ 🎉" -ForegroundColor Green
Write-Host "🍲            STARTING THE GREAT ORPHANED INGREDIENT HUNT            🍲" -ForegroundColor Green  
Write-Host "🎉 ════════════════════════════════════════════════════════════ 🎉" -ForegroundColor Green
Write-Host ""

# 🕵️ THE GREAT INGREDIENT HUNT - Execute Our Bisque Detective Work
foreach ($region in $regions) {
    Write-Host "🔍 Exploring regional pantry: $region" -ForegroundColor Cyan
    
    # 💾 Hunt for Forgotten Storage Carrots (Unattached EBS Volumes)
    Write-Host "  🥕 Searching for forgotten storage carrots..." -ForegroundColor Yellow
    
    try {
        $orphanedEbsJson = aws ec2 describe-volumes --filters "Name=state,Values=available" --region $region --profile $AwsProfile 2>$null
        if ($orphanedEbsJson -and $orphanedEbsJson -ne "null") {
            $orphanedEbsResponse = $orphanedEbsJson | ConvertFrom-Json
            $orphanedEbsVolumes = $orphanedEbsResponse.Volumes
            
            if ($orphanedEbsVolumes.Count -gt 0) {
                $volumeCount = $orphanedEbsVolumes.Count
                $totalOrphanedEbsVolumes += $volumeCount
                
                foreach ($volume in $orphanedEbsVolumes) {
                    $sizeGb = [int]$volume.Size
                    $volumeType = $volume.VolumeType
                    
                    # Calculate cost based on volume type
                    $monthlyCost = switch ($volumeType) {
                        "gp3" { $sizeGb * $ebsVolumeGp3CostPerGbMonth }
                        "gp2" { $sizeGb * $ebsVolumeGp2CostPerGbMonth }
                        default { $sizeGb * $ebsVolumeGp2CostPerGbMonth }
                    }
                    
                    $totalEbsVolumeSize += $sizeGb
                    
                    # Extract name from tags if available
                    $volumeName = $volume.VolumeId
                    if ($volume.Tags) {
                        $nameTag = $volume.Tags | Where-Object { $_.Key -eq "Name" }
                        if ($nameTag) { $volumeName = $nameTag.Value }
                    }
                    
                    $orphanedEbsData += [PSCustomObject]@{
                        Name = $volumeName
                        VolumeId = $volume.VolumeId
                        Region = $region
                        SizeGB = $sizeGb
                        Type = $volumeType
                        State = $volume.State
                        Created = $volume.CreateTime
                        MonthlyCost = $monthlyCost
                    }
                }
                
                Write-Host "    Found $volumeCount forgotten storage carrots!" -ForegroundColor White
            } else {
                Write-Host "    No forgotten storage carrots found - clean pantry!" -ForegroundColor White
            }
        } else {
            Write-Host "    No storage carrots in this regional pantry!" -ForegroundColor White
        }
    } catch {
        Write-Host "    ⚠️ Could not scan storage carrots in $region" -ForegroundColor Yellow
    }
    
    # 🌐 Hunt for Lonely Grape Elastic IPs (Unassociated Elastic IPs)
    Write-Host "  🍇 Looking for lonely grape Elastic IPs..." -ForegroundColor Yellow
    
    try {
        $orphanedElasticIpsJson = aws ec2 describe-addresses --region $region --profile $AwsProfile 2>$null
        if ($orphanedElasticIpsJson -and $orphanedElasticIpsJson -ne "null") {
            $orphanedElasticIpsResponse = $orphanedElasticIpsJson | ConvertFrom-Json
            $allElasticIps = $orphanedElasticIpsResponse.Addresses
            
            # Filter for unassociated IPs
            $unassociatedIps = $allElasticIps | Where-Object { -not $_.AssociationId }
            
            if ($unassociatedIps.Count -gt 0) {
                $ipCount = $unassociatedIps.Count
                $totalOrphanedElasticIps += $ipCount
                
                foreach ($ip in $unassociatedIps) {
                    $orphanedElasticIpsData += [PSCustomObject]@{
                        PublicIp = $ip.PublicIp
                        AllocationId = $ip.AllocationId
                        Region = $region
                        Domain = $ip.Domain
                        NetworkBorderGroup = $ip.NetworkBorderGroup
                        MonthlyCost = $elasticIpCostMonth
                    }
                }
                
                Write-Host "    Found $ipCount lonely grape Elastic IPs!" -ForegroundColor White
            } else {
                Write-Host "    No lonely grape Elastic IPs found - all grapes are attached!" -ForegroundColor White
            }
        } else {
            Write-Host "    No Elastic IPs in this regional pantry!" -ForegroundColor White
        }
    } catch {
        Write-Host "    ⚠️ Could not scan Elastic IPs in $region" -ForegroundColor Yellow
    }
    
    # 🍄 Hunt for Idle Mushroom Load Balancers (Load Balancers with no targets)
    Write-Host "  🍄 Searching for idle mushroom load balancers..." -ForegroundColor Yellow
    
    try {
        # Check Application/Network Load Balancers (ELBv2)
        $elbv2Json = aws elbv2 describe-load-balancers --region $region --profile $AwsProfile 2>$null
        if ($elbv2Json -and $elbv2Json -ne "null") {
            $elbv2Response = $elbv2Json | ConvertFrom-Json
            $loadBalancers = $elbv2Response.LoadBalancers
            
            foreach ($lb in $loadBalancers) {
                # Check if load balancer has any healthy targets
                $targetGroupsJson = aws elbv2 describe-target-groups --load-balancer-arn $lb.LoadBalancerArn --region $region --profile $AwsProfile 2>$null
                $hasHealthyTargets = $false
                
                if ($targetGroupsJson -and $targetGroupsJson -ne "null") {
                    $targetGroupsResponse = $targetGroupsJson | ConvertFrom-Json
                    foreach ($tg in $targetGroupsResponse.TargetGroups) {
                        $targetHealthJson = aws elbv2 describe-target-health --target-group-arn $tg.TargetGroupArn --region $region --profile $AwsProfile 2>$null
                        if ($targetHealthJson) {
                            $targetHealthResponse = $targetHealthJson | ConvertFrom-Json
                            if ($targetHealthResponse.TargetHealthDescriptions.Count -gt 0) {
                                $hasHealthyTargets = $true
                                break
                            }
                        }
                    }
                }
                
                if (-not $hasHealthyTargets) {
                    $totalOrphanedLoadBalancers++
                    $lbCost = if ($lb.Type -eq "application") { $albCostMonth } else { $nlbCostMonth }
                    
                    $orphanedLoadBalancersData += [PSCustomObject]@{
                        Name = $lb.LoadBalancerName
                        Arn = $lb.LoadBalancerArn
                        Region = $region
                        Type = $lb.Type
                        Scheme = $lb.Scheme
                        State = $lb.State.Code
                        Created = $lb.CreatedTime
                        MonthlyCost = $lbCost
                    }
                }
            }
        }
        
        # Check Classic Load Balancers (ELB)
        $elbJson = aws elb describe-load-balancers --region $region --profile $AwsProfile 2>$null
        if ($elbJson -and $elbJson -ne "null") {
            $elbResponse = $elbJson | ConvertFrom-Json
            $classicLbs = $elbResponse.LoadBalancerDescriptions
            
            foreach ($clb in $classicLbs) {
                # Check if Classic LB has any instances
                if ($clb.Instances.Count -eq 0) {
                    $totalOrphanedLoadBalancers++
                    
                    $orphanedLoadBalancersData += [PSCustomObject]@{
                        Name = $clb.LoadBalancerName
                        Arn = "Classic-$($clb.LoadBalancerName)"
                        Region = $region
                        Type = "classic"
                        Scheme = $clb.Scheme
                        State = "active"
                        Created = $clb.CreatedTime
                        MonthlyCost = $clbCostMonth
                    }
                }
            }
        }
        
        if ($totalOrphanedLoadBalancers -gt 0) {
            Write-Host "    Found idle mushroom load balancers!" -ForegroundColor White
        } else {
            Write-Host "    No idle mushroom load balancers found - all serving customers!" -ForegroundColor White
        }
    } catch {
        Write-Host "    ⚠️ Could not scan load balancers in $region" -ForegroundColor Yellow
    }
    
    # 🌿 Hunt for Lonely Herb NAT Gateways (NAT Gateways with no route table usage)
    Write-Host "  🌿 Searching for lonely herb NAT Gateways..." -ForegroundColor Yellow
    
    try {
        $natGatewaysJson = aws ec2 describe-nat-gateways --region $region --profile $AwsProfile 2>$null
        if ($natGatewaysJson -and $natGatewaysJson -ne "null") {
            $natGatewaysResponse = $natGatewaysJson | ConvertFrom-Json
            $natGateways = $natGatewaysResponse.NatGateways | Where-Object { $_.State -eq "available" }
            
            foreach ($nat in $natGateways) {
                # Check if NAT Gateway is referenced in any route tables
                $routeTablesJson = aws ec2 describe-route-tables --region $region --profile $AwsProfile 2>$null
                $isUsed = $false
                
                if ($routeTablesJson) {
                    $routeTablesResponse = $routeTablesJson | ConvertFrom-Json
                    foreach ($rt in $routeTablesResponse.RouteTables) {
                        foreach ($route in $rt.Routes) {
                            if ($route.NatGatewayId -eq $nat.NatGatewayId) {
                                $isUsed = $true
                                break
                            }
                        }
                        if ($isUsed) { break }
                    }
                }
                
                if (-not $isUsed) {
                    $totalOrphanedNatGateways++
                    
                    # Extract name from tags if available
                    $natName = $nat.NatGatewayId
                    if ($nat.Tags) {
                        $nameTag = $nat.Tags | Where-Object { $_.Key -eq "Name" }
                        if ($nameTag) { $natName = $nameTag.Value }
                    }
                    
                    $orphanedNatGatewaysData += [PSCustomObject]@{
                        Name = $natName
                        NatGatewayId = $nat.NatGatewayId
                        Region = $region
                        SubnetId = $nat.SubnetId
                        State = $nat.State
                        Created = $nat.CreateTime
                        MonthlyCost = $natGatewayCostMonth
                    }
                }
            }
            
            if ($totalOrphanedNatGateways -gt 0) {
                Write-Host "    Found lonely herb NAT Gateways!" -ForegroundColor White
            } else {
                Write-Host "    No lonely herb NAT Gateways found - all routing traffic!" -ForegroundColor White
            }
        } else {
            Write-Host "    No NAT Gateways in this regional pantry!" -ForegroundColor White
        }
    } catch {
        Write-Host "    ⚠️ Could not scan NAT Gateways in $region" -ForegroundColor Yellow
    }
    
    Write-Host "  ✅ Regional pantry $region inspection complete!" -ForegroundColor Green
}

# 💰 COST CALCULATION KITCHEN - Calculate the Savings Flavor
Write-Host "💰 Calculating the cost of wasted ingredients..." -ForegroundColor Yellow

$ebsMonthlyCost = ($orphanedEbsData | Measure-Object -Property MonthlyCost -Sum).Sum
$elasticIpMonthlyCost = $totalOrphanedElasticIps * $elasticIpCostMonth
$loadBalancerMonthlyCost = ($orphanedLoadBalancersData | Measure-Object -Property MonthlyCost -Sum).Sum
$natGatewayMonthlyCost = $totalOrphanedNatGateways * $natGatewayCostMonth

$totalMonthlySavings = $ebsMonthlyCost + $elasticIpMonthlyCost + $loadBalancerMonthlyCost + $natGatewayMonthlyCost
$totalYearlySavings = $totalMonthlySavings * 12

Write-Host "📊 Ingredient Waste Report:" -ForegroundColor Magenta
Write-Host "   🥕 Forgotten Storage Carrots: $totalOrphanedEbsVolumes pieces ($totalEbsVolumeSize GB total)" -ForegroundColor White
Write-Host "   🍇 Lonely Grape Elastic IPs: $totalOrphanedElasticIps pieces" -ForegroundColor White
Write-Host "   🍄 Idle Mushroom Load Balancers: $totalOrphanedLoadBalancers pieces" -ForegroundColor White
Write-Host "   🌿 Lonely Herb NAT Gateways: $totalOrphanedNatGateways pieces" -ForegroundColor White

Write-Host "💸 Monthly Money Soup: `$$($totalMonthlySavings.ToString('F2'))" -ForegroundColor Green
Write-Host "🎉 Annual Savings Banquet: `$$($totalYearlySavings.ToString('F2'))" -ForegroundColor Green

# 📄 THE GRAND MENU CREATION - Generate Our Beautiful HTML Feast Report
Write-Host "📄 Creating the grand Orphaned Cloud Ingredient Bisque menu..." -ForegroundColor Yellow
$reportDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 🎨 BUILD HTML DATA TABLES
$ebsTableHtml = ""
foreach ($ebs in $orphanedEbsData) {
    $ebsTableHtml += @"
                    <tr>
                        <td>$($ebs.Name)</td>
                        <td>$($ebs.VolumeId)</td>
                        <td><span class="location-badge">$($ebs.Region)</span></td>
                        <td>$($ebs.SizeGB) GB</td>
                        <td>$($ebs.Type)</td>
                        <td>$($ebs.State)</td>
                        <td>$($ebs.Created)</td>
                        <td>`$$($ebs.MonthlyCost.ToString('F2'))</td>
                    </tr>
"@
}

$elasticIpsTableHtml = ""
foreach ($eip in $orphanedElasticIpsData) {
    $elasticIpsTableHtml += @"
                    <tr>
                        <td>$($eip.PublicIp)</td>
                        <td>$($eip.AllocationId)</td>
                        <td><span class="location-badge">$($eip.Region)</span></td>
                        <td>$($eip.Domain)</td>
                        <td>$($eip.NetworkBorderGroup)</td>
                        <td>`$$($eip.MonthlyCost.ToString('F2'))</td>
                    </tr>
"@
}

$loadBalancersTableHtml = ""
foreach ($lb in $orphanedLoadBalancersData) {
    $loadBalancersTableHtml += @"
                    <tr>
                        <td>$($lb.Name)</td>
                        <td>$($lb.Type)</td>
                        <td><span class="location-badge">$($lb.Region)</span></td>
                        <td>$($lb.Scheme)</td>
                        <td>$($lb.State)</td>
                        <td>$($lb.Created)</td>
                        <td>`$$($lb.MonthlyCost.ToString('F2'))</td>
                    </tr>
"@
}

$natGatewaysTableHtml = ""
foreach ($nat in $orphanedNatGatewaysData) {
    $natGatewaysTableHtml += @"
                    <tr>
                        <td>$($nat.Name)</td>
                        <td>$($nat.NatGatewayId)</td>
                        <td><span class="location-badge">$($nat.Region)</span></td>
                        <td>$($nat.SubnetId)</td>
                        <td>$($nat.State)</td>
                        <td>$($nat.Created)</td>
                        <td>`$$($nat.MonthlyCost.ToString('F2'))</td>
                    </tr>
"@
}

# 🎨 CREATE THE HTML MASTERPIECE
$htmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>🍲 Orphaned Cloud Ingredient Bisque - AWS Edition</title>
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
            border: 3px solid #ff9900;
        }
        .header { 
            background: linear-gradient(135deg, #ff9900 0%, #232f3e 100%); 
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
            background: linear-gradient(135deg, #ff9900 0%, #232f3e 100%); 
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
            background: linear-gradient(135deg, #ff9900 0%, #232f3e 100%); 
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
                    var cellText = cols[j].innerText.replace(/[🥕🍇🍄🌿💰📊]/g, '').trim();
                    row.push('"' + cellText.replace(/"/g, '""') + '"');
                }
                csv.push(row.join(','));
            }
            
            var csvFile = new Blob([csv.join('\\n')], {type: 'text/csv'});
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
            <h2>AWS Edition - Chef's Special Cost Optimization Menu</h2>
            <p>📅 Freshly Prepared: $reportDate</p>
            <p>🏪 Regional Pantries Inspected: $regionCount AWS regional kitchens</p>
            <p>👨‍🍳 Using Profile: $AwsProfile</p>
            <p><em>"Turning forgotten AWS ingredients into delicious savings!" - CloudCostChef</em></p>
        </div>

        <div class="summary-cards">
            <div class="card">
                <h3>🥕 Forgotten Storage Carrots</h3>
                <div class="number">$totalOrphanedEbsVolumes</div>
                <div class="savings">Monthly Waste: `$$($ebsMonthlyCost.ToString('F2'))</div>
                <p><em>$totalEbsVolumeSize GB going stale</em></p>
            </div>
            <div class="card">
                <h3>🍇 Lonely Grape Elastic IPs</h3>
                <div class="number">$totalOrphanedElasticIps</div>
                <div class="savings">Monthly Tears: `$$($elasticIpMonthlyCost.ToString('F2'))</div>
                <p><em>Making wallets weep</em></p>
            </div>
            <div class="card">
                <h3>🍄 Idle Mushroom Load Balancers</h3>
                <div class="number">$totalOrphanedLoadBalancers</div>
                <div class="savings">Monthly Idleness: `$$($loadBalancerMonthlyCost.ToString('F2'))</div>
                <p><em>Balancing nothing</em></p>
            </div>
            <div class="card">
                <h3>🌿 Lonely Herb NAT Gateways</h3>
                <div class="number">$totalOrphanedNatGateways</div>
                <div class="savings">Monthly Loneliness: `$$($natGatewayMonthlyCost.ToString('F2'))</div>
                <p><em>Routing to nowhere</em></p>
            </div>
        </div>

        <div class="cost-highlight">
            <h3>🎯 Chef's Cost Savings Special</h3>
            <p><strong>🍜 Monthly Savings Bisque:</strong> `$$($totalMonthlySavings.ToString('F2')) | <strong>🍽️ Annual Savings Banquet:</strong> `$$($totalYearlySavings.ToString('F2'))</p>
            <p><em>*Pricing based on standard AWS US-East-1 rates - your local prices may vary by region and instance types</em></p>
            <p><strong>👨‍🍳 Chef's Note:</strong> These forgotten ingredients are costing you real money every month!</p>
        </div>

        <div class="resource-type">
            <h2>🥕 Forgotten Storage Carrot Collection ($totalOrphanedEbsVolumes found rotting)</h2>
            <p><em>These EBS volumes are sitting unused, costing you based on volume type and size!</em></p>
            <button class="download-btn" onclick="downloadCSV('ebsTable', 'forgotten_storage_carrots_inventory.csv')">⬇ 📋 Export Carrot Inventory</button>
            <table id="ebsTable">
                <thead>
                    <tr>
                        <th>🏷️ Carrot Name</th>
                        <th>🆔 Volume ID</th>
                        <th>🌍 Regional Garden</th>
                        <th>📏 Carrot Size</th>
                        <th>🥕 Carrot Type</th>
                        <th>📊 State</th>
                        <th>📅 Planted Date</th>
                        <th>💸 Monthly Waste Cost</th>
                    </tr>
                </thead>
                <tbody>
$ebsTableHtml
                </tbody>
            </table>
        </div>

        <div class="resource-type">
            <h2>🍇 Lonely Grape Elastic IP Collection ($totalOrphanedElasticIps found withering)</h2>
            <p><em>These Elastic IPs are withering alone and bleeding `$$($elasticIpCostMonth.ToString('F2')) per month each from your budget!</em></p>
            <button class="download-btn" onclick="downloadCSV('elasticIpsTable', 'lonely_grape_elastic_ips_inventory.csv')">⬇ 📋 Export Grape Inventory</button>
            <table id="elasticIpsTable">
                <thead>
                    <tr>
                        <th>🍇 Grape IP Address</th>
                        <th>🆔 Allocation ID</th>
                        <th>🌍 Regional Vineyard</th>
                        <th>🏠 Domain</th>
                        <th>🌐 Network Border Group</th>
                        <th>💸 Monthly Withering Cost</th>
                    </tr>
                </thead>
                <tbody>
$elasticIpsTableHtml
                </tbody>
            </table>
        </div>

        <div class="resource-type">
            <h2>🍄 Idle Mushroom Load Balancer Collection ($totalOrphanedLoadBalancers found sleeping)</h2>
            <p><em>These load balancers are sleeping with no targets to balance!</em></p>
            <button class="download-btn" onclick="downloadCSV('loadBalancersTable', 'idle_mushroom_load_balancers_inventory.csv')">⬇ 📋 Export Mushroom Inventory</button>
            <table id="loadBalancersTable">
                <thead>
                    <tr>
                        <th>🏷️ Mushroom Name</th>
                        <th>🍄 Mushroom Type</th>
                        <th>🌍 Regional Forest</th>
                        <th>🔒 Scheme</th>
                        <th>📊 State</th>
                        <th>📅 Sprouted Date</th>
                        <th>💸 Monthly Idleness Cost</th>
                    </tr>
                </thead>
                <tbody>
$loadBalancersTableHtml
                </tbody>
            </table>
        </div>

        <div class="resource-type">
            <h2>🌿 Lonely Herb NAT Gateway Collection ($totalOrphanedNatGateways found unused)</h2>
            <p><em>These NAT Gateways are growing alone with no routes to serve!</em></p>
            <button class="download-btn" onclick="downloadCSV('natGatewaysTable', 'lonely_herb_nat_gateways_inventory.csv')">⬇ 📋 Export Herb Inventory</button>
            <table id="natGatewaysTable">
                <thead>
                    <tr>
                        <th>🏷️ Herb Name</th>
                        <th>🆔 NAT Gateway ID</th>
                        <th>🌍 Regional Garden</th>
                        <th>🏠 Subnet ID</th>
                        <th>📊 State</th>
                        <th>📅 Planted Date</th>
                        <th>💸 Monthly Loneliness Cost</th>
                    </tr>
                </thead>
                <tbody>
$natGatewaysTableHtml
                </tbody>
            </table>
        </div>

        <div class="recommendations">
            <h3>👨‍🍳 Chef's Professional Kitchen Recommendations</h3>
            <ul>
                <li><strong>🔍 Taste Before You Toss:</strong> Always verify these ingredients are truly spoiled before disposal - some might be marinating for future recipes!</li>
                <li><strong>🔗 Check Recipe Dependencies:</strong> Some EBS volumes might be snapshots or planned for future EC2 instances</li>
                <li><strong>🤖 Kitchen Automation:</strong> Implement AWS Config Rules and Lambda functions to prevent waste</li>
                <li><strong>📅 Monthly Inventory Audits:</strong> Schedule regular pantry cleanings using CloudWatch Events</li>
                <li><strong>🏷️ Chef's Labeling System:</strong> Implement consistent resource tagging to identify ownership and purpose</li>
                <li><strong>💡 Pro Chef Tip:</strong> Use AWS Trusted Advisor and Cost Explorer for automated optimization recommendations</li>
                <li><strong>📊 Cost Tracking:</strong> Monitor these savings in AWS Cost and Usage Reports</li>
                <li><strong>🗑️ Automated Cleanup:</strong> Consider AWS Lambda functions to automatically clean up resources tagged for deletion</li>
                <li><strong>🔄 Lifecycle Management:</strong> Implement EBS snapshot lifecycle policies and automated backups before cleanup</li>
                <li><strong>🚨 Alerting:</strong> Set up CloudWatch alarms for resources that remain unused for extended periods</li>
            </ul>
            <p><em><strong>Remember:</strong> A clean AWS kitchen is a profitable kitchen! - CloudCostChef</em></p>
        </div>

        <div class="footer">
            <p><strong>🍲 Orphaned Cloud Ingredient Bisque - AWS Edition</strong> - Prepared by CloudCostChef's Kitchen</p>
            <p>Generated: $reportDate | <em>"Where forgotten ingredients become found savings!"</em></p>
            <p>This bisque helps identify potential cost savings by finding orphaned AWS resources across your regional pantries</p>
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
Write-Host "   🥕 Forgotten storage carrots: $totalOrphanedEbsVolumes ($totalEbsVolumeSize GB wasting `$$($ebsMonthlyCost.ToString('F2'))/month)" -ForegroundColor White
Write-Host "   🍇 Lonely grape Elastic IPs: $totalOrphanedElasticIps (bleeding `$$($elasticIpMonthlyCost.ToString('F2'))/month)" -ForegroundColor White
Write-Host "   🍄 Idle mushroom load balancers: $totalOrphanedLoadBalancers (costing `$$($loadBalancerMonthlyCost.ToString('F2'))/month)" -ForegroundColor White
Write-Host "   🌿 Lonely herb NAT Gateways: $totalOrphanedNatGateways (costing `$$($natGatewayMonthlyCost.ToString('F2'))/month)" -ForegroundColor White
Write-Host "   📊 Total forgotten ingredients: $($totalOrphanedEbsVolumes + $totalOrphanedElasticIps + $totalOrphanedLoadBalancers + $totalOrphanedNatGateways)" -ForegroundColor White
Write-Host "   🏪 Regional kitchens inspected: $regionCount" -ForegroundColor White

Write-Host "`n💡 Chef's Professional Tip:" -ForegroundColor Yellow
Write-Host "   These orphaned ingredients are costing real money every month!" -ForegroundColor White
Write-Host "   Clean up your AWS kitchen and watch the savings add up! 🧹✨" -ForegroundColor White

# 🍷 OFFER THE WINE PAIRING - Ask to Open Report
Write-Host "`n🍷 Would you like to taste your freshly prepared bisque now? (Y/N)" -ForegroundColor Cyan
$openReport = Read-Host "   Press Y to open the cost savings menu"

if ($openReport -eq 'Y' -or $openReport -eq 'y') {
    Write-Host "🎭 Opening the grand cost savings menu presentation..." -ForegroundColor Green
    Start-Process $OutputPath
    Write-Host "🌟 Bon appétit! Enjoy your AWS cost optimization feast! 🌟" -ForegroundColor Green
} else {
    Write-Host "🍽️  Your bisque is ready whenever you're hungry for savings!" -ForegroundColor Yellow
    Write-Host "📄 Just open: $OutputPath" -ForegroundColor Cyan
}

Write-Host "`n👨‍🍳 Thank you for dining at CloudCostChef's Kitchen!" -ForegroundColor Magenta
Write-Host "🌟 Remember: A clean AWS kitchen is a profitable kitchen! 🌟" -ForegroundColor Green
