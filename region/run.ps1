using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

try {
    $Subscriptions = (Get-AzContext -ListAvailable).count
    $status = [HttpStatusCode]::OK
    $body = "There are $Subscriptions Subscriptions"
} catch {
    $status = [HttpStatusCode]::BadRequest
    $body = "error. $_"
}


# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    Body = $body
})
