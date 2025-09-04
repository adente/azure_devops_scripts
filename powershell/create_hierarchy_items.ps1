$organization = "https://dev.azure.com/<org>"
$project = "<project>"
$level1Type = "Epic"
$level2Type = "Feature"
$level3Type = "User Story"

# Execute 
# 'az login --tenant <tenantId>'
# AND
# 'az account get-access-token --resource 499b84ac-1321-427f-aa17-267ca6975798 --query "accessToken" -o tsv'
# Before executing the script

az devops configure --defaults organization=$organization project=$project

# Create 10 Level1
for ($z = 1; $z -le 10; $z++) {
    $level1Title = "$level1Type $z"
    $level1 = az boards work-item create `
        --title "$level1Title" `
        --type $level1Type `
        --output json | ConvertFrom-Json

    $level1Id = $level1.id
    Write-Host "Created $level1Type with ID: $level1Id"

    # Create 10 Level2 under the Level1
    for ($i = 1; $i -le 10; $i++) {
        $level2Title = "$level2Type $z.$i"
        $level2 = az boards work-item create `
            --title "$level2Title" `
            --type $level2Type `
            --output json | ConvertFrom-Json

        $level2Id = $level2.id
        Write-Host "  Created $level2Type $z.$i with ID: $level2Id"

        # Link Level2 to Level1
        az boards work-item relation add `
            --id $level2Id `
            --relation-type "Parent" `
            --target-id $level1Id | Out-Null

        Write-Host "  Linked $level2Type $level2Id with ${$level1Type}: $level1Id"

        # Create 10 Level3 under each Level2
        for ($j = 1; $j -le 10; $j++) {
            $level3Title = "$level3Type $z.$i.$j"
            $level3 = az boards work-item create `
                --title "$level3Title" `
                --type "$level3Type" `
                --output json | ConvertFrom-Json

            Write-Host "    Created $level3Type $z.$i.$j with ID: $($level3.id)"

            # Link Level3 to Level2
            az boards work-item relation add `
                --id $level3.id `
                --relation-type "Parent" `
                --target-id $level2Id | Out-Null

            Write-Host "    Linked $level3Type $($level3.id) with ${$level2Type}: $level2Id"
        }
    }
}
