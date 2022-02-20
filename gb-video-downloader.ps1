
Import-Module ./gb-video-downloader.psm1 -Force

[xml]$configFile = get-content .\config.xml
$key = "?api_key=" + $configFile.configuration.add.value

### grab 100 results from page 1 and 2 of giant bomb shows ###
$var = Invoke-GiantBombAPI -Filters "&sort=desc" -SearchType "video_shows"
$pageTwo = Invoke-GiantBombAPI -Filters "&sort=desc&offset=100" -SearchType "video_shows" 
$var.results += $pageTwo.results 

[int]$i = 0
$guid_array = @()
foreach ($entry in $var.results){
    $i++
    $guid_array += New-Object PsObject -property @{
        'guid' = $entry.guid
        'title' = $entry.title
        'deck' = $entry.deck
        }
    Write-Output "$i. $($entry.title)`n$($entry.deck)`n"
}


$selected_number = Read-Host "Which show would you like to download? Type in the number"
$choice = $guid_array[$selected_number-1]
$var = Invoke-GiantBombAPI -SearchType "video_show/$($choice.guid)"

### capture string api_video_url from variable ###
### do video show search using captured string ###
$pattern = "videos/\?filter=(.*)"
$api_videos_url = [regex]::match($var.results.api_videos_url, $pattern).Groups[1].Value
$video_show = $api_videos_url.replace('%3A',':')
$show = Invoke-GiantBombAPI -Filters "&filter=$video_show" -SearchType "videos"

## grab total number of pages to make sure we loop through all results ##
[int]$pageNumbers = $show.number_of_total_results / 100
$i = 0
while ($i -le $pageNumbers) {
    $i++
    $newpage = Invoke-GiantBombAPI -Filters "&filter=$video_show&offset=$($i)00" -SearchType "videos"
    $show.results += $newpage.results
}

## loop through each entry found ##
$entryData = @()
$i = 0
foreach ($entry in $show.results[$show.results.length..0]){
    $i++
    $entryData += New-Object PsObject -property @{
        'guid' = "$($entry.guid)"
    }
    ## this is helpful for looking at bombcast list ##
    if ($($entry.premium) -eq "True"){
        Write-Output "`n$i. $($entry.name) (premium) `n$($entry.deck)`n"
    }
    else {
        Write-Output "`n$i. $($entry.name) `n$($entry.deck)`n" 
    }
}

$selected_number = Read-Host "Which episode would you like to download? Type in the number"
$choice = $entryData[$selected_number-1]
$var = Invoke-GiantBombAPI -SearchType "video/$($choice.guid)"
foreach ($entry in $var.results){
    $fileName = "./$($entry.name -replace '\s','' -replace '/','-' -replace ':','').mp4" 
    if ($entry.hd_url){
        Write-Output "Downloading HD version of $($entry.name)"
        Invoke-WebRequest -URI "$($entry.hd_url)$key" -Outfile $fileName
    }
    elseif ($entry.high_url) {
        Write-Output "Downloading High version of $($entry.name)"
        Invoke-WebRequest -URI "$($entry.high_url)$key" -Outfile $fileName
    }
    elseif ($entry.low_url) {
        Write-Output "Downloading Low version of $($entry.name)"
        Invoke-WebRequest -URI "$($entry.low_url)$key" -Outfile $fileName
    }
    else {
        Write-Output "All URL's empty :(. Is something broke?"
    }
}
