# Load Dependencies
."$PSScriptRoot\vm.localConfig.ps1"
Write-Host "Deploying Virtual Machine $environment"

# Check for Login and Load Parameters
Write-Host "$(Get-Date) Logging into Azure."
Try {
    $currentSubscription = (Get-AzureRmContext -ErrorAction Continue).Subscription.Id
    if($currentSubscription -ne $SubscriptionId) {
        $currentSubscription = $subscriptionId
        Login-AzureRmAccount
        Set-AzureRmContext -SubscriptionId $currentSubscription
    }
} Catch [System.Management.Automation.PSInvalidOperationException] {
    Login-AzureRmAccount
    Set-AzureRmContext -SubscriptionId $currentSubscription
} 

if(!$location)
{
    $location = Read-Host -Prompt "Please Provide a Project Location"
}

if(!$country)
{
    $country = Read-Host -Prompt "Please Provide a Project Country"
}

if(!$projectName)
{
    $projectName = Read-Host -Prompt "Please Provide the Project Name"
}

$projectName = $projectName.ToUpper()

if(!$projectNumber)
{
    $projectNumber = Read-Host -Prompt "Please Provide the Project Number"
}


Set-Location -Path $PSScriptRoot

$rgName = "GROUP-$country-$projectName-$projectNumber"

# Create Resource Group (if it exists this wont re-create it)
New-AzureRmResourceGroup -Name $rgName -Location $location -Force

# Deploy the Azure Virtual Machine (and dependancies) resources
(Get-Date).DateTime

$deploymentparms = @{
    ResourceGroupName = $rgName
    TemplateFile = $templatefilelocation
    adminPassword = $vmAdminPassword
    storageAccountPrefix = $storageAccountPrefix
    projectName = $projectName
    projectNumber = $projectNumber
    location = $location
    country = $country
    subscriptionId = $SubscriptionId
    vmSize = $vmSize
    ipPrefix = $ipPrefix
    ruleIp01 = $ipRule01
    adminName = $adminUserName
}

$resourceDeploy = New-AzureRmResourceGroupDeployment  @deploymentparms

(Get-Date).DateTime

