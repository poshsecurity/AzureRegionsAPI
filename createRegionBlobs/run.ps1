using namespace System.Net

# Input bindings are passed in via param block.
param([string] $InputBlob, $TriggerMetadata)

# Write out the blob name and size to the information log.
Write-Host "PowerShell Blob trigger function Processed blob! Name: $($TriggerMetadata.Name) Size: $($InputBlob.Length) bytes"

$AzureRegions = @{
    'West Europe'         = 'EuropeWest'
    'East US'             = 'USEast'
    'East US 2'           = 'USEast2'
    'West US'             = 'USWest'
    'North Central US'    = 'USNorth'
    'North Europe'        = 'EuropeNorth'
    'Central US'          = 'USCentral'
    'East Asia'           = 'AsiaEast'
    'Southeast Asia'      = 'AsiaSouthEast'
    'South Central US'    = 'USSouth'
    'Japan West'          = 'JapanWest'
    'Japan East'          = 'JapanEast'
    'Brazil South'        = 'BrazilSouth'
    'Australia East'      = 'AustraliaEast'
    'Australia Southeast' = 'AustraliaSoutheast'
    'Central India'       = 'IndiaCentral'
    'West India'          = 'IndiaWest'
    'South India'         = 'IndiaSouth'
    'Canada Central'      = 'CanadaCentral'
    'Canada East'         = 'CanadaEast'
    'West Central US'     = 'USWestCentral'
    'West US 2'           = 'USWest2'
    'UK South'            = 'UKSouth'
    'UK West'             = 'UKWest'
    'China North'         = 'chinanorth'
    'China East'          = 'chinaeast'
    'Central US EUAP'     = 'uscentraleuap'
    'East US 2 EUAP'      = 'useast2euap'
    'Korea South'         = 'koreasouth'
    'Korea Central'       = 'koreacentral'
    'France Central'      = 'francec'
    'France South'        = 'frances'
    'Germany Central'     = 'germanycentral'
    'Germany Northeast'   = 'germanynortheast'
    'Australia Central'   = 'australiac'
    'Australia Central 2' = 'australiac2'
    'UK North'            = 'uknorth'
    'UK South 2'          = 'uksouth2'
    'North Europe 2'      = 'europenorth2' #Placeholder until azure region name is confirmed
    'East Europe'         = 'europeeast' #Placeholder until azure region name is confirmed
    'Korea South 2'       = 'koreas2' #Placeholder until azure region name is confirmed
    'Brazil Southeast'    = 'brazilse' #Placeholder until azure region name is confirmed
    'Brazil Northeast'    = 'brazilne' #Placeholder until azure region name is confirmed
    'Chile Central'       = 'chilec' #Placeholder until azure region name is confirmed
    'South Africa North'  = 'southafrican'
    'South Africa West'   = 'southafricaw'
    'UAE North'           = 'uaen'
    'UAE Central'         = 'uaec'
}

$temp = [System.IO.Path]::GetTempPath()
Write-Host "Temp Dir $temp"

Write-Host "[createRegionBlobs] getting xml"
$RequestXML = [xml]$InputBlob
$Regions = $RequestXML.AzurePublicIpAddresses.Region

Write-Host "[createRegionBlobs] getting storage context"
$Con = New-AzStorageContext -ConnectionString $env:MyStorageConnectionAppSetting

Write-Host "[createRegionBlobs] processing regions in file $Regions.Count"
foreach ($Region in $Regions)
{
    $BackendRegionName = $Region.Name

    # Translate each region name to something friendly
    $RegionName = $AzureRegions.GetEnumerator().Where({$_.Value -eq $BackendRegionName}).Name

    Write-Host ('Processing region: {0}' -f $RegionName)
    $filename = Join-path -Path $temp -ChildPath ('{0}.json' -f $RegionName)

    Write-Host "saving blob $filename"

    Out-File -FilePath (($filename).ToLower()) -InputObject ($region.IpRange.subnet | convertto-json)

    Set-AzStorageBlobContent -File $filename -Container 'regionblobs' -Context $con -Force

}