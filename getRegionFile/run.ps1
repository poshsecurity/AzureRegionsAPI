using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$region = $Request.Query.Region.tolower()
if (-not $region) {
    $region = $Request.Body.Region.tolower()
}

Write-Host "Region = $region"

if (@('standard', 'china', 'germany') -contains $region) {

    switch ($Region) {
        'china' {
            Write-Host 'Downloading... Windows Azure Datacenter IP Ranges in China'
            $MicrosoftDownloadsURL = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=42064'
        }

        'germany' {
            Write-Host 'Downloading... Windows Azure Datacenter IP Ranges in Germany'
            $MicrosoftDownloadsURL = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=54770'
        }

        Default {
            Write-Host 'Downloading... Microsoft Azure Datacenter IP Ranges'
            $MicrosoftDownloadsURL = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=41653'
        }
    }

    try {
        $DownloadPage = Invoke-WebRequest -UseBasicParsing -Uri $MicrosoftDownloadsURL
    } catch {
        $status = [HttpStatusCode]::BadRequest
        $body = "Error fetching Download Page"
    }

    $DownloadLink = ($DownloadPage.Links | Where-Object -FilterScript {$_.outerHTML -match 'Click here' -and $_.href -match '.xml'}).href[0]
    Write-Host 'Downloading and creating XML object'
    try {
        $XMLFile = Invoke-WebRequest -UseBasicParsing -Uri $DownloadLink
    } catch {
        $status = [HttpStatusCode]::BadRequest
        $body = "Error fetching XML file"
    }
    
    Write-Host 'Saving to blob storage'
    try {
        Push-OutputBinding -Name $Region -Value ("$XMLFile") -Clobber
    } catch {
        $status = [HttpStatusCode]::BadRequest
        $body = "Error sacing file"
    }

    $status = [HttpStatusCode]::OK
    $body = "Success"
}
else {
    $status = [HttpStatusCode]::BadRequest
    $body = "Please pass a region on the query string or in the request body."
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    Body = $body
    $contentType = 'text/plain'
})
