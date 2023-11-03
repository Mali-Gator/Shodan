# Import the list of keywords from the CSV file
$keywords = Import-Csv -Path "input_keywords.csv"

# Create an empty array to store the search results
$results = @()

# Set the API key
$api_key = "[SHODAN API KEY]"

# Iterate through the list of keywords
foreach ($keyword in $keywords) {

  #Debug which keyword is being queried
  Write-Output "Searching for keyword: $keyword"

  # Send a request to the Shodan API to search for hosts that have the keyword in their data
  $response = Invoke-WebRequest -Uri "https://api.shodan.io/shodan/host/search?key=$api_key&query=$($keyword.keyword)"
  
  #Debug the response status code
  Write-Output "Response status code: $($response.StatusCode)"

  $data = $response.Content | ConvertFrom-Json

  # Add the current keyword to the search results
  $data.matches | Add-Member -MemberType NoteProperty -Name "Keyword" -Value $keyword.keyword

  #Debug the number of matches for each keyword
  Write-Output "Number of matches: $($data.matches.Count)"

  # Add the search results to the array
  $results += $data.matches

  # Pause the script for 1.5 second
  Start-Sleep -Seconds 1.5
}


# Export the search results to a CSV file
$results | Select-Object -Property Keyword, ip_str, port, @{Name="hostname"; Expression={$_.hostnames[0]}} | Export-Csv -Path "Shodan_Keyword_results.csv" -NoTypeInformation
