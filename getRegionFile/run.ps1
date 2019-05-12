using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host '[getRegionFile] PowerShell HTTP trigger function processed a request.'

# Interact with query parameters or the body of the request.
$region = $Request.Query.Region.tolower()
if (-not $region) {
    $region = $Request.Body.Region.tolower()
}

Write-Host '[getRegionFile] Region = $region'

if (@('standard', 'china', 'germany') -contains $region) {

    switch ($region) {
        'china' {
            Write-Host '[getRegionFile] Downloading... Windows Azure Datacenter IP Ranges in China'
            $microsoftDownloadsURL = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=42064'
        }

        'germany' {
            Write-Host '[getRegionFile] Downloading... Windows Azure Datacenter IP Ranges in Germany'
            $microsoftDownloadsURL = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=54770'
        }

        Default {
            Write-Host '[getRegionFile] Downloading... Microsoft Azure Datacenter IP Ranges'
            $microsoftDownloadsURL = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=41653'
        }
    }

    try {
        $downloadPage = Invoke-WebRequest -UseBasicParsing -Uri $microsoftDownloadsURL
    }
    catch {
        $status = [HttpStatusCode]::BadRequest
        $body = 'Error fetching Download Page'
    }

    $downloadLink = ($downloadPage.Links | Where-Object -FilterScript {$_.outerHTML -match 'Click here' -and $_.href -match '.xml'}).href[0]
    Write-Host '[getRegionFile] Downloading and creating XML object'
    try {
        $XMLFile = Invoke-WebRequest -UseBasicParsing -Uri $downloadLink
    }
    catch {
        $status = [HttpStatusCode]::BadRequest
        $body = 'Error fetching XML file'
    }

    Write-Host '[getRegionFile] Saving to blob storage'
    try {
        Push-OutputBinding -Name ($region.toLower()) -Value ("$XMLFile") -Clobber
    }
    catch {
        $status = [HttpStatusCode]::BadRequest
        $body = 'Error saving file'
    }

    $status = [HttpStatusCode]::OK
    $body = 'Success'
}
else {
    $status = [HttpStatusCode]::BadRequest
    $body = 'Please pass a valid region on the query string or in the request body.'
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode  = $status
        Body        = $body
        contentType = 'text/plain'
    })
