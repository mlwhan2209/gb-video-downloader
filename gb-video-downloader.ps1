
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
        'name' = "$($entry.name)"
    }
    ## this is helpful for looking at bombcast list ##
    if ($($entry.premium) -eq "True"){
        Write-Output "`n$i. $($entry.name) (premium) `n$($entry.deck)`n"
    }
    else {
        Write-Output "`n$i. $($entry.name) `n$($entry.deck)`n" 
    }
}

Write-Output ("You are selecting the range of videos you want. If you just want a single video, keep both numbers the same")
$lowerBound = read-host ("What # do you want to start at?")
$upperBound = read-host ("What # do you want to end at?")
$choices = $lowerBound..$upperBound

foreach ($selectedNumber in $choices){
	$selectedNumber
	read-host ("wait")
    $choice = $entryData[$selectedNumber-1]
    $var = Invoke-GiantBombAPI -SearchType "video/$($choice.guid)"
    $fileName = "./$($var.results.name -replace '\s','' -replace '/','-' -replace ':','').mp4" 
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
