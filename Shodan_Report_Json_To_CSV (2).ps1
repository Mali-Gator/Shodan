param (
    [Parameter(Mandatory=$true)]
    [string]$jsonFilePath,
    
    [Parameter(Mandatory=$true)]
    [string]$csvOutputPath
)

function ConvertTo-FlatObject {
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Object,

        [string]$ParentKey = ""
    )

    $results = @()

    foreach ($key in $Object.PSObject.Properties.Name) {
        $value = $Object.$key
        $newKey = if ($ParentKey) { "$ParentKey.$key" } else { $key }

        if ($value -is [PSCustomObject]) {
            $results += ConvertTo-FlatObject -Object $value -ParentKey $newKey
        } elseif ($value -is [System.Collections.IEnumerable] -and $value -isnot [string]) {
            $index = 0
            foreach ($item in $value) {
                if ($item -is [PSCustomObject]) {
                    $results += ConvertTo-FlatObject -Object $item -ParentKey "$newKey`[$index`]"
                } else {
                    $results += [PSCustomObject]@{"$newKey`[$index`]" = $item}
                }
                $index++
            }
        } else {
            $results += [PSCustomObject]@{$newKey = $value}
        }
    }

    return $results
}

# Load the JSON file
$jsonContent = Get-Content -Path $jsonFilePath -Raw | ConvertFrom-Json

# Flatten the JSON content
$flattenedData = $jsonContent | ForEach-Object {
    ConvertTo-FlatObject -Object $_
}

# Convert the flattened data to CSV and save
$flattenedData | Export-Csv -Path $csvOutputPath -NoTypeInformation

Write-Output "CSV file has been saved to $csvOutputPath"
