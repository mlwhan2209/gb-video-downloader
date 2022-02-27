
<#
.SYNOPSIS
This will invoke the GB API in an easily configurable way

.DESCRIPTION
Using preset variables for the base uri and api key makes
it so we don't need to repeat code throughout the main script.
The easy to use parameters make it so we can modify this function 
to invoke whatever endpoint in the GB API that we want.

.PARAMETER searchFilter
This not a mandatory parameter
This should commonly be wrote as -Filters "<string>"
This is used to return requests as JSON and 
Allow users to easily add what kind of filter 
they need for results

.PARAMETER search
This search parameter is mandatory
This should commonly be wrote as -SearchType "<string>"
This is used to distinguish between different types of 
GB API endpoints we want to hit. 

.EXAMPLE
Invoke-GiantBombAPI -Filters "&sort=desc" -SearchType "video_shows"

.NOTES
In your -Filters paramater, make sure you start the string with & 
as the 1st filter actually applied to every request is to return 
as json
#>
function Invoke-GiantBombAPI {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('SearchType')][string]$search,

        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Filters')][string]$searchFilter
    )

    ### grabbing API, setting up URL ###
    $GiantBombBaseUri = "https://www.giantbomb.com/api"
    $Uri = "$GiantBombBaseUri/{search}/{apikey}{filters}"  
    [xml]$configFile = get-content .\config.xml 
    $key = "?api_key=" + $configFile.configuration.add.value

     ### we always want to return as JSON ###
     ### even if the user has no added filters ###
    if (!$searchFilter){
        $filters = "&format=json" 
    }
    ### if the user does have a filter, ###
    ### we want to add it to the json filter ###
    else {
        $filters = "&format=json$searchFilter"  
    }

    $TempUri = $Uri -replace "\{search\}", $search -replace "\{apikey\}", $key -replace "\{filters\}", $filters 
    Invoke-RestMethod -Uri $TempUri -Method Get
}

<#
.SYNOPSIS
This will invoke the GB API search route  in an easy little function you can use 

.DESCRIPTION
The function hides all the bs you don't need to allow the user to just put their
exact search they want into the function call

.PARAMETER Search 
This a mandatory parameter
This should commonly be wrote as -Search "<string>"
This is used to return requests as JSON and 
Allow users to easily search for the video type they want  

.EXAMPLE
Invoke-GiantBombVideoSearch -Search "flight club"
Invoke-GiantBombVideoSearch -Search "digital combat simiulator"

.NOTES
This function is tricky. Giant Bomb's search API only allows 10 results to return per page
at the same time, you might get 500 hits on your search. So you can't rotate
through all of these results without blowing up their API with 900 requests in an hour
just from going through all the pages
#>
function Invoke-GiantBombVideoSearch {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('SearchQuery')][string]$search
    )
    
    $var = Invoke-GiantBombAPI -SearchType "search" -Filters "&query=$search&resources=video"

    ## grab total number of pages to make sure we loop through all results ##
    [int]$pageNumbers = $var.number_of_total_results / 100
    $i = 0
    while ($i -le $pageNumbers) {
        $i++
        $newpage = Invoke-GiantBombAPI -SearchType "search" -Filters "&query=$search&offset=$($i)00&resources=video" 
        $var.results += $newpage.results
    }
    
    $var.results = $var.results | Sort-Object {$_.name}  -Unique

    ## loop through each entry found ##
    $entryData = @()
    $i = 0
    foreach ($entry in $var.results[$var.results.length..0]){
        $i++
        $entryData += New-Object PsObject -property @{
            'guid' = "$($entry.guid)"
            'name' = "$($entry.name)"
        }
        Write-Output "`n$i. $($entry.name) `n$($entry.deck)`n"
    }

    Write-Output "Select videos you want seperated by a comma. Press enter when finished."
    #Externally set input value as string
    [string[]] $choices= @()
    #Get the input from the user
    $choices = READ-HOST "Enter List of videos"
    #splitting the list of input as array by Comma & Empty Space
    $choices = $choices.Split(',').Split(' ')

    [xml]$configFile = get-content .\config.xml 
    $key = "?api_key=" + $configFile.configuration.add.value

    $path = read-host ("What path do you want to download this to? ex: D:/Media/TV/Breaking Bad/Season 01/")
    foreach ($selectedNumber in $choices){
        $choice = $entryData[$selectedNumber-1]
        $var = Invoke-GiantBombAPI -SearchType "video/$($choice.guid)"
        $fileName = "$path/$($var.results.name -replace '\s','' -replace '/','-' -replace ':','').mp4" 
        if ($var.results.hd_url){
            Write-Output "Downloading HD version of $($var.results.name)"
            Invoke-WebRequest -URI "$($var.results.hd_url)$key" -Outfile $fileName
        }
        elseif ($var.results.high_url) {
            Write-Output "Downloading High version of $($var.results.name)"
            Invoke-WebRequest -URI "$($var.results.high_url)$key" -Outfile $fileName
        }
        elseif ($var.results.low_url) {
            Write-Output "Downloading Low version of $($var.results.name)"
        }
        else {
            Write-Output "All URL's empty :(. Is something broke?"
        }
    }

}
