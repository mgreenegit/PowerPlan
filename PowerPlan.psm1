﻿function Get-Powerplan
{
<#
.Synopsis
   Get a Powerplan by name or all of them
.DESCRIPTION
   This cmdlet queries the CIM class Win32_PowerPlan. See also Set-PowerPlan cmdlet
.EXAMPLE
   Get-Powerplan

   This command will output all powerplans:

Caption        : 
Description    : Automatically balances performance with energy consumption on capable hardware.
ElementName    : Balanced
InstanceID     : Microsoft:PowerPlan\{381b4222-f694-41f0-9685-ff5bb260df2e}
IsActive       : False
PSComputerName : 

Caption        : 
Description    : Favors performance, but may use more energy.
ElementName    : High performance
InstanceID     : Microsoft:PowerPlan\{8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c}
IsActive       : True
PSComputerName : 

Caption        : 
Description    : Saves energy by reducing your computer’s performance where possible.
ElementName    : Power saver
InstanceID     : Microsoft:PowerPlan\{a1841308-3541-4fab-bc81-f71556f20b4a}
IsActive       : False
PSComputerName : 
.EXAMPLE
   Get-Powerplan -PlanName high*

   This command will output all plans that begins with high

Caption        : 
Description    : Favors performance, but may use more energy.
ElementName    : High performance
InstanceID     : Microsoft:PowerPlan\{8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c}
IsActive       : True
PSComputerName : 

.EXAMPLE 
    Get-PowerPlan -PlanName high* -ComputerName "Server1","Server2"

    Will output the powerplan with name like high for server1 and server2

.OUTPUTS
   CimInstance
.NOTES
   Powerplan and performance
.COMPONENT
   Powerplan
.ROLE
   Powerplan
.FUNCTIONALITY
   This cmdlet queries the CIM class Win32_PowerPlan
#>
[cmdletbinding()]
[OutputType([CimInstance[]])]
Param(
    [Parameter(
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true, 
        ValueFromRemainingArguments=$false
    )]
    [Alias("ElementName")]
    [string]$PlanName = "*"
    ,
    [Parameter(
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true, 
        ValueFromRemainingArguments=$false
    )]
    [string[]]$ComputerName
)

    Begin
    {
        $f = $MyInvocation.InvocationName
        Write-Verbose -Message "$f - START"

        $GetCimInstance = @{
            Namespace = "root\cimv2\power"
            ClassName = "Win32_PowerPlan"
        }

        if($ComputerName)
        {
            $GetCimInstance.Add("ComputerName",$ComputerName)
        }
    }

    Process
    {
        if($PlanName)
        {
            Get-CimInstance @GetCimInstance | Where-Object ElementName -Like "$PlanName"
        }
        else
        {
            Get-CimInstance @GetCimInstance
        }
    }

    End
    {
        Write-Verbose -Message "$f - END"
    }
}

function Set-PowerPlan
{
<#
.Synopsis
   Sets a Powerplan by name or by value provided from the pipeline
.DESCRIPTION
   This cmdlet invokes the CIM-method Activate in class Win32_PowerPlan. See also Get-PowerPlan cmdlet
.EXAMPLE
   Set-PowerPlan -PlanName high*

   This will set the current powerplan to High for the current computer
.EXAMPLE
   Get-Powerplan -PlanName "Power Saver" | Set-PowerPlan

   Will set the powerplan to "Power Saver" for current computer
.EXAMPLE
   Get-Powerplan -PlanName "Power Saver" -ComputerName "Server1","Server2" | Set-PowerPlan

   This will set the current powerpla to "Power Saver" for the computers Server1 and Server2
.EXAMPLE
   Set-PowerPlan -PlanName "Power Saver" -ComputerName "Server1","Server2"

   This will set the current powerpla to "Power Saver" for the computers Server1 and Server2
.NOTES
   Powerplan and performance
.COMPONENT
   Powerplan
.ROLE
   Powerplan
.FUNCTIONALITY
   This cmdlet invokes CIM-methods in the class Win32_PowerPlan
#>
[cmdletbinding(
    SupportsShouldProcess=$true,
    ConfirmImpact='Medium'
)]
Param(
    [Parameter(
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true, 
        ValueFromRemainingArguments=$false
    )]
    [Alias("ElementName")]
    [string]$PlanName = "*"
    ,    
    [Parameter(
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true, 
        ValueFromRemainingArguments=$false
    )]
    [Alias("PSComputerName")]
    [string[]]$ComputerName
)

    Begin
    {
        $f = $MyInvocation.InvocationName
        Write-Verbose -Message "$f - START"
        $GetCimInstance = @{
            Namespace = "root\cimv2\power"
            ClassName = "Win32_PowerPlan"
        }

        if($pscmdlet.ShouldProcess($ComputerName))
        {
            $GetCimInstance.Add("ComputerName",$ComputerName)
        }

        $InvokeCimMethod = @{
            MethodName = "Activate"
        }

        if($WhatIfPreference)
        {
            $InvokeCimMethod.Add("WhatIf",$true)
        }
    }

    Process
    {   
        Write-Verbose -Message "$f -  ElementName=$PlanName"
        $CimObjectPowerPlan = Get-CimInstance @GetCimInstance | Where-Object ElementName -like "$PlanName"

        foreach($Instance in $CimObjectPowerPlan)
        {
            $null = Invoke-CimMethod -InputObject $Instance @InvokeCimMethod
        }
        if(-not $CimObjectPowerPlan)
        {
            Write-Warning -Message "Unable to find powerplan $PlanName"
        }   
    }

    End
    {
        Write-Verbose -Message "$f - END"
    }

}



