# Import the list of IP address ranges from the CSV file
$ip_ranges = Import-Csv -Path "input_ip_addresses.csv"

# Create an empty array to store the search results
$results = @()

# Set the API key
$api_key = "[INSERT API KEY HERE]"

# Iterate through the list of IP address ranges
foreach ($ip_range in $ip_ranges) {

  #Debug which IP address range is being queried
  Write-Output "Searching for IP address range: $ip_range"

  # Send a request to the Shodan API to search for hosts within the specified IP address range
  $response = Invoke-WebRequest -Uri "https://api.shodan.io/shodan/scan?key=$api_key&query=$($ip_range.ip_range)"
  
  # Check if the request was successful
  if ($response.StatusCode -eq 200) {
    # Convert the response content to a JSON object
    $data = $response.Content | ConvertFrom-Json

    # Add the current IP address range to the search results
    $data.matches | Add-Member -MemberType NoteProperty -Name "IP Address Range" -Value $ip_range.ip_range

    #Debug the number of matches for each IP address range
    Write-Output "Number of matches: $($data.matches.Count)"

    # Add the search results to the array
    $results += $data.matches
  } else {
    Write-Output "Request failed with status code: $($response.StatusCode)"
  }

  # Pause the script for 1.5 second
  Start-Sleep -Seconds 1.5
}

# Export the search results to a CSV file
$results | Select-Object -Property IP Address Range, ip_str, port, @{Name="hostname"; Expression={$_.hostnames[0]}} | Export-Csv -Path "Shodan_IP_results.csv" -NoTypeInformation