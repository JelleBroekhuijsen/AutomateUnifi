Param(
	[parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
	[string]$keyvaultName
)

function Get-RandomCharacters {
	param(
		[parameter(Mandatory=$true)]
		[int]$length,
		[parameter(Mandatory=$true)]
		[string]$characters
	)

	[array]$random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
	$private:ofs = ""

	return [string]$characters[$random]
}

function New-ScrambledString {     
	param(
		[parameter(Mandatory=$true)]
		[string]$inputString
	)
	
	[array]$scrambledString = $inputString.ToCharArray() | Get-Random -Count $inputString.ToCharArray().Length      
	$private:ofs = ""

	return [string]$scrambledString 
}

function New-SecretValue {
	Param(
		[parameter(Mandatory=$false)]
		[ValidateRange(0, [int]::MaxValue)]
		[int]$lettersCount = 4,

		[parameter(Mandatory=$false)]
		[string]$letters = 'abcdefghiklmnoprstuvwxyz',
		
		[parameter(Mandatory=$false)]
		[ValidateRange(0, [int]::MaxValue)]
		[int]$capitalLettersCount = 2,
		
		[parameter(Mandatory=$false)]
		[string]$capitalLetters = 'ABCDEFGHKLMNOPRSTUVWXYZ',

		[parameter(Mandatory=$false)]
		[ValidateRange(0, [int]::MaxValue)]
		[int]$numberCount = 4,
		
		[parameter(Mandatory=$false)]
		[string]$numbers = '1234567890',

		[parameter(Mandatory=$false)]
		[ValidateRange(0, [int]::MaxValue)]
		[int]$specialCharactersCount = 2,
		
		[parameter(Mandatory=$false)]
		[string]$specialCharacters = '!%&=?@#*+'
	)

	[string]$newRandomString = ""

	if($lettersCount -ne 0){
		$newRandomString += Get-RandomCharacters -length $lettersCount -characters $letters
	}
	if($capitalLettersCount -ne 0){
		$newRandomString += Get-RandomCharacters -length $capitalLettersCount -characters $capitalLetters
	}
	if($numberCount -ne 0){
		$newRandomString += Get-RandomCharacters -length $numberCount -characters $numbers
	}
	if($specialCharactersCount -ne 0){
		$newRandomString += Get-RandomCharacters -length $specialCharactersCount -characters $specialCharacters
	}
	
	if($newRandomString -eq ""){
		throw "No random string generated"
	}

	[string]$newSecretValue = New-ScrambledString $newRandomString

	return [string]$newSecretValue
} 

# fetch keyvault url
$keyvault = Get-AzKeyVault -Name $keyvaultName
if($null -eq $keyvault){
	throw "No keyvault found with name $keyvaultname"
}
Write-Output "Using keyvault: $($keyvault.VaultName)"

#generate vm password
$vmPasswordSecretName = 'vmPassword'
$vmPassword = New-SecretValue | ConvertTo-SecureString -AsPlainText -Force

#set vmpassword in keyvault
try{
	$result = Set-AzKeyVaultSecret -VaultName $keyvault.VaultName -Name $vmPasswordSecretName -SecretValue $vmPassword -ErrorAction Stop
	Write-Output "##vso[task.setvariable variable=vmPassword;issecret=true]$($result.SecretValueText)"
	Write-Output "Added VSTS variable 'vmPassword' ('$($vmPassword.getType().name)')"
}
catch{
	Write-Error "Set-AzKeyvaultSecret threw an error: $($error[0])"
}

#generate KEK
$keyEncryptionKeySecretName = 'keyEncryptionKey'

#set kek in keyvault
try{
	$result = Add-AzKeyVaultKey -Name $keyEncryptionKeySecretName -VaultName $keyvault.VaultName -Destination Software -Size 4096 -ErrorAction Stop
	Write-Output "##vso[task.setvariable variable=kekUri]$($result.id)"
	Write-Output "Added VSTS variable 'kekUri' ('$($result.id.getType().name)') with value '$($result.id)'"
}
catch{
	Write-Error "Add-AzKeyVaultKey threw an error: $($error[0])"
}

