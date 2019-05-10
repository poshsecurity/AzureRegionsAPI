using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

try {
    $baseURL = 'https://azureregions.azurewebsites.net/api/GetRegionFile?Code={0}&Region={1}'
    $authCode = $ENV:AdminAuth
    #$regionFiles = @('Standard', 'China', 'Germany')
    $regionFiles = @('Standard')
    foreach ($regionFile in $regionFiles) {
        $fileURL = $baseURL -f $authCode, $regionFile
        $apiResponse = invoke-webrequest $fileURL -UseBasicParsing -Method GET
        Push-OutputBinding -Name $regionFile -Value $apiResponse
    }
    $status = [HttpStatusCode]::OK
    $Body = 'success'
} catch {
    $status = [HttpStatusCode]::BadRequest
    $Body = "failed $_"
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    Body = $body
})
