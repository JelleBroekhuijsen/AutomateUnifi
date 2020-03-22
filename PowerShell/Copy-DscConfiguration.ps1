param(
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$storageAccountName,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$resourceGroupName,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$dscFileName,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$adoDefaultWorkingDirectory
)

$containerName = 'dscwork'

$storageAccount = Get-AzStorageAccount -Name $storageAccountName -ResourceGroup $resourceGroupName
if($null -eq $storageAccount){
    throw "Storage account not found"
}

$dscFile = Get-ChildItem -path $adoDefaultWorkingDirectory -Filter $dscFileName -Recurse
if($null -eq $dscFile){
    throw "Unable to find file: $($dscFileName)"
}

try{
    $blob = New-AzStorageContainer -Name $containerName -Permission Blob -Context $storageaccount.context -ErrorAction Stop
}
catch{
    $blob = Get-AzStorageContainer -Name $containerName -Context $storageaccount.context
}

if($null -eq $blob){
    throw "Failed to retrieve storage container: $containerName"
}

try{
    Write-Output "Uploading file $($dscFile.FullName)"
    $result = Set-AzStorageBlobContent -Container $blob.name -File $dscFile.FullName -Context $storageaccount.context -Force -ErrorAction Stop
    Write-Output "##vso[task.setvariable variable=dscSourceUrl]$($result.ICloudBlob.Uri.AbsoluteUri)"
    Write-Output "Added VSTS variable 'dscSourceUrl' ('$($result.ICloudBlob.Uri.AbsoluteUri.getType().name)') with value '$($result.ICloudBlob.Uri.AbsoluteUri)'"
}
catch{
    Write-Error "Failed to upload file to blob, error: $($error[0])"
}
