``` mermaid
graph LR
    A[Build Job] --> B1[Release Pipeline] 
    subgraph Release Pipeline
    B1[Deploy ARM] --> B2[Process output] --> B3[Deploy ARM]
    end
    B3 --> C1[Deployed solution]  
```

``` mermaid
sequenceDiagram
    participant A as ADO Release Agent
    participant B as ARM job
    participant C as PowerShell job
    participant D as Azure PowerShell job
    activate A
    A->>B: Deploy keyvault.json
    deactivate A
    activate B
    Note right of A: -solutionprefix "$(solutionPrefix)"<br>-adoAadObjectId "$(adoAadObjectId)"<br>-jllAadObjectId "$(jllAadObjectId)"
    B->>A: Returns ARM-output
    deactivate B
    activate A
    Note left of B: "$(keyvaultOutput)"
    A->>C: Run Set-PipelineVariables.ps1
    deactivate A
    activate C
    Note right of A: -armOutputString "$(keyVaultOutput)"
    C->>A: Sets pipeline variable
    deactivate C
    activate A 
    Note left of C:  "$(keyVaultName)"
    A->>D: Run New-VmPasswordAndKek.ps1
    deactivate A
    activate D
    Note right of A: -keyvaultName "$(keyVaultName)"
    D->>A: Sets pipeline variables
    deactivate D
    activate A
    Note left of D: "$(vmPassword)"<br>"$(keyVaultUrl)"<br>"$(kekUrl)"
    A->>B: Deploy storage.json
    deactivate A
    activate B
    B->>A: Returns ARM-output
    deactivate B
    activate A
    Note left of B: "$(storageOutput)"
    A->>C: Run Set-PipelineVariables.ps1
    deactivate A
    activate C    
    Note right of A: -armOutputString "$(storageOutput)"
     C->>A: Sets pipeline variables
    deactivate C
    activate A 
    Note left of C:  "$(storageAccountName)"<br>"$(storageAccountResourceGroup)"
    A->>D: Run Copy-DscConfiguration.ps1
    deactivate A
    activate D
    Note right of A: -storageAccountName "$(storageAccountName)"<br>-resourceGroupName "$(storageAccountResourceGroup)"<br>-dscFileName "$(dscFileName)"<br>-adoDefaultWorkingDirectory "$(System.DefaultWorkingDirectory)"
    D->>A: Sets pipeline variable 
    deactivate D
    activate A
    Note left of D: "$(dscSourceUrl)"
    A->>B: Deploy automation.json
    deactivate A
    activate B
    Note right of A: -solutionprefix "$(solutionPrefix)"<br>-dscFilename "$(dscFilename)"<br>-dscSourceUrl "$(dscSourceUrl)"
    B->>A: returns ARM-output
    deactivate B
    activate A
    Note left of B: "$(automationOutput)"
    A->>C: Run Set-PipelineVariables.ps1
    deactivate A
    activate C    
    Note right of A: -armOutputString "$(automationOutput)"
     C->>A: Sets pipeline variables
    deactivate C
    activate A 
    Note left of C:  "$(automationAccountName)"
    A->>B: Deploy virtualmachine.json
    deactivate A
    activate B
    Note right of A: -automationAccountName "$(automationAccountName)"<br>-storageAccountName "$(storageAccountName)"<br>-adminPassword "$(vmPassword)"<br>-keyVaultUrl "$(keyVaultUrl)"<br>-kekUrl "$(kekUrl)"<br>-keyVaultName "$(keyVaultName)"<br>-solutionprefix "$(solutionPrefix)"<br>-subnetResourceId "$(subnetResourceId)"
    deactivate B
```
``` mermaid
graph TD
    A[Deploy Keyvault] --> B[Generate Secrets] 
    B --> C[Deploy Storage]
    C --> D[Upload DSC Script]
    D --> E[Deploy Automation<br>- import modules<br>- create configuration<br>- compile configuration]
    E --> F[Deploy VM<br>- apply configution]
```