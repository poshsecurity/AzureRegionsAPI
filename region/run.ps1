using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

$regions = @(
            'Australia Central',
            'Australia Central 2',
            'Australia East',
            'Australia Southeast',
            'Brazil South',
            'Canada Central',
            'Canada East',
            'Central India',
            'Central US EUAP',
            'Central US',
            'China East',
            'China North',
            'East Asia',
            'East US 2 EUAP',
            'East US 2',
            'East US',
            'France Central',
            'France South',
            'Germany Central',
            'Germany Northeast',
            'Japan East',
            'Japan West',
            'Korea Central',
            'Korea South',
            'North Central US',
            'North Europe',
            'South Central US',
            'South India',
            'Southeast Asia',
            'UK North',
            'UK South',
            'UK South 2',
            'UK West',
            'West Central US',
            'West Europe',
            'West India',
            'West US 2',
            'West US',
            'North Europe 2',  #Placeholder until azure region name is confirmed
            'East Europe',     #Placeholder until azure region name is confirmed
            'Korea South 2',    #Placeholder until azure region name is confirmed
            'Brazil Southeast', #Placeholder until azure region name is confirmed
            'Brazil Northeast', #Placeholder until azure region name is confirmed
            'Chile Central'    #Placeholder until azure region name is confirmed
)

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $regions
})
