using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "[saveRegionFileToBlobStorage] PowerShell HTTP trigger function processed a request."

try {
    $baseURL = 'https://azureregions.azurewebsites.net/api/GetRegionFile?Code={0}&Region={1}'
    $authCode = $ENV:AdminAuth
    $regionFiles = @('Standard', 'China', 'Germany')
    foreach ($regionFile in $regionFiles) {
        Write-Host "[saveRegionFileToBlobStorage] Processing $regionFile"
        $fileURL = $baseURL -f $authCode, $regionFile
        $apiResponse = invoke-webrequest $fileURL -UseBasicParsing -Method GET
        Write-Host "[saveRegionFileToBlobStorage] Saving file $regionFile"
        Push-OutputBinding -Name $regionFile -Value ("$apiResponse") -Clobber
    }
    $status = [HttpStatusCode]::OK
    $Body = 'success'
} catch {
    $status = [HttpStatusCode]::BadRequest
    $Body = "failed $_"
}

Write-Host "[saveRegionFileToBlobStorage] Output HTTP Response"

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    Body = $body
})
