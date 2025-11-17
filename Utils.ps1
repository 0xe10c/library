function Get-IpAddressGeoLocation {
    <#
    .SYNOPSIS
    Gets geolocation data for a given IP address using free batch API endpoint from ip-api.com

    .DESCRIPTION
    The website ip-api.com provides a free API endpoint that accepts batches of up to 100 IP addresses, returning
    geolocation information for each IP submitted IP address. The endpoint is rate-limited at 15 queries per minute
    per IP address.

    .PARAMETER IPAddress
    IP address(es) to query.  May be passed in as singletons, arrays, or via objects which have an IPAddress property.
    
    .EXAMPLE
    "8.8.8.8" | Get-IpAddressGeolocation

    status      : success
    country     : United States
    countryCode : US
    region      : VA
    regionName  : Virginia
    city        : Ashburn
    zip         : 20149
    lat         : 39.03
    lon         : -77.5
    timezone    : America/New_York
    isp         : Google LLC
    org         : Google Public DNS
    as          : AS15169 Google LLC
    query       : 8.8.8.8

    .EXAMPLE
    @("8.8.8.8", "8.8.4.4") | Get-IpAddressGeolocation

    status      : success
    country     : United States
    countryCode : US
    region      : VA
    regionName  : Virginia
    city        : Ashburn
    zip         : 20149
    lat         : 39.03
    lon         : -77.5
    timezone    : America/New_York
    isp         : Google LLC
    org         : Google Public DNS
    as          : AS15169 Google LLC
    query       : 8.8.8.8

    status      : success
    country     : United States
    countryCode : US
    region      : VA
    regionName  : Virginia
    city        : Ashburn
    zip         : 20149
    lat         : 39.03
    lon         : -77.5
    timezone    : America/New_York
    isp         : Google LLC
    org         : Google Public DNS
    as          : AS15169 Google LLC
    query       : 8.8.4.4


    .EXAMPLE
    Resolve-DnsName reddit.com | Get-IpAddressGeolocation
    status      : success
    country     : United States
    countryCode : US
    region      : CA
    regionName  : California
    city        : San Francisco
    zip         : 94107
    lat         : 37.7618
    lon         : -122.399
    timezone    : America/Los_Angeles
    isp         : Fastly, Inc.
    org         : Fastly, Inc
    as          : AS54113 Fastly, Inc.
    query       : 2a04:4e42:200::396

    status      : success
    country     : United States
    countryCode : US
    region      : CA
    regionName  : California
    city        : San Francisco
    zip         : 94107
    lat         : 37.7618
    lon         : -122.399
    timezone    : America/Los_Angeles
    isp         : Fastly, Inc.
    org         : Fastly, Inc
    as          : AS54113 Fastly, Inc.
    query       : 2a04:4e42:400::396

    <snip>
    #>
    param (
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]$IPAddress
    )
    
    begin {
        $queryAddresses = @()
        $maxBatchSize = 100
        $maxRequestsPerMinute = 15
        $uri = "http://ip-api.com/batch"
    }
    process {
        $queryAddresses += $IPAddress
    }
    end {

        $results = @()
        $requestCount = 0;
        $numBatches = [math]::Ceiling($queryAddresses.Count / $maxBatchSize)
        for ($i = 0; $i -lt $numBatches -and $requestCount -lt $maxRequestsPerMinute; $i++) {
            $postbody = $queryAddresses[(0 + ($maxBatchSize * $i))..(99 + $($maxBatchSize * $i))] | ConvertTo-Json -AsArray
            $results += Invoke-RestMethod -Method Post -Body $postbody -Uri $uri
            $requestCount++
        }

        Write-Debug "Number of requests: $($requestCount)"

        return $results
    }
}