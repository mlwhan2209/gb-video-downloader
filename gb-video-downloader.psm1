
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
